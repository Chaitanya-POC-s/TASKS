

# Some Considerations 

# To Test Nested Objectr i have used Object.Json File as the sample . This is the IMDS response which is a complex nested json file
# To use -NoProxy have to use Powershell version 5 and above


#region Functions
####################################################################################################################################

function ConvertTo-Hashtable {
 [CmdletBinding()]
 [OutputType('hashtable')]
 param (
 [Parameter(ValueFromPipeline)]
 $InputObject
 )
 
 process {
 ## Return null if the input is null. This can happen when calling the function
 ## recursively and a property is null
 if ($null -eq $InputObject) {
 return $null
 }
 
 ## Check if the input is an array or collection. If so, we also need to convert
 ## those types into hash tables as well. This function will convert all child
 ## objects into hash tables (if applicable)
 if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
 $collection = @(
 foreach ($object in $InputObject) {
 ConvertTo-Hashtable -InputObject $object
 }
 )
 
 ## Return the array but don't enumerate it because the object may be pretty complex
 Write-Output -NoEnumerate $collection
 } elseif ($InputObject -is [psobject]) { ## If the object has properties that need enumeration
 ## Convert it to its own hash table and return it
 $hash = @{}
 foreach ($property in $InputObject.PSObject.Properties) {
 $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
 }
 $hash
 } else {
 ## If the object isn't an array, collection, or other object, it's already a hash table
 ## So just return it.
 $InputObject
 }
 }
}


Function Flatten-Object { 
    [CmdletBinding()]Param (
        [Parameter(ValueFromPipeLine = $True)][Object[]]$Objects,
        [String]$Separator = ".", [ValidateSet("", 0, 1)]$Base = 1, [Int]$Depth = 5, [Int]$Uncut = 1,
        [String[]]$ToString = ([String], [DateTime], [TimeSpan]), [String[]]$Path = @()
    )
    $PipeLine = $Input | ForEach {$_}; If ($PipeLine) {$Objects = $PipeLine}
    If (@(Get-PSCallStack)[1].Command -eq $MyInvocation.MyCommand.Name -or @(Get-PSCallStack)[1].Command -eq "<position>") {
        $Object = @($Objects)[0]; $Iterate = New-Object System.Collections.Specialized.OrderedDictionary
        If ($ToString | Where {$Object -is $_}) {$Object = $Object.ToString()}
        ElseIf ($Depth) {$Depth--
            If ($Object.GetEnumerator.OverloadDefinitions -match "[\W]IDictionaryEnumerator[\W]") {
                $Iterate = $Object
            } ElseIf ($Object.GetEnumerator.OverloadDefinitions -match "[\W]IEnumerator[\W]") {
                $Object.GetEnumerator() | ForEach -Begin {$i = $Base} {$Iterate.($i) = $_; $i += 1}
            } Else {
                $Names = If ($Uncut) {$Uncut--} Else {$Object.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames}
                If (!$Names) {$Names = $Object.PSObject.Properties | Where {$_.IsGettable} | Select -Expand Name}
                If ($Names) {$Names | ForEach {$Iterate.$_ = $Object.$_}}
            }
        }
        If (@($Iterate.Keys).Count) {
            $Iterate.Keys | ForEach {
                Flatten-Object @(,$Iterate.$_) $Separator $Base $Depth $Uncut $ToString ($Path + $_)
            }
        }  Else {$Property.(($Path | Where {$_}) -Join $Separator) = $Object}
    } ElseIf ($Objects -ne $Null) {
        @($Objects) | ForEach -Begin {$Output = @(); $Names = @()} {
            New-Variable -Force -Option AllScope -Name Property -Value (New-Object System.Collections.Specialized.OrderedDictionary)
            Flatten-Object @(,$_) $Separator $Base $Depth $Uncut $ToString $Path
            $Output += New-Object PSObject -Property $Property
            $Names += $Output[-1].PSObject.Properties | Select -Expand Name
        }
        $Output | Select ([String[]]($Names | Select -Unique))
    }
}; Set-Alias Flatten Flatten-Object

########################################################################################################################################

[array]$DropDownArrayItems = "Select Option","Nested Object","Connect Remote Computer","Execute Locally"
[array]$DropDownArray = $DropDownArrayItems 

# This Function Returns the Selected Value and Closes the Form

function Return-DropDown {
    if ($DropDown.SelectedItem -eq $null){
        $DropDown.SelectedItem = $DropDown.Items[0]
        $script:Choice = $DropDown.SelectedItem.ToString(),$textbox.Text,$nested.Text
        $Form.Close()
    }
    else{
        $script:Choice = $DropDown.SelectedItem.ToString() ,$textbox.Text,$nested.Text
        $Form.Close()
    }
}

function toggle{
    if($DropDown.SelectedIndex -eq 1){
         $nested.enabled = $true
         $textbox.Text = "Enter Search value"
         $textbox.Enabled = $true
    }
    elseif($DropDown.SelectedIndex -eq 2){
        $textbox.Text = "Enter IP Address"
        $textbox.Enabled = $true
    }
     elseif($DropDown.SelectedIndex -eq 3){
        $textbox.Enabled = $false
    }
    
    else{
        $nested.Enabled = $false
    }
}

function UserInput{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void][System.Windows.Forms.Application]::EnableVisualStyles()

    $Form = New-Object System.Windows.Forms.Form
    $Form.StartPosition   = "CenterScreen"
    $Form.FormBorderStyle = 'Fixed3D'
    $Form.width = 600
    $Form.height = 400
    $Form.Text = ”Task”

    $Form.ClientSize  = '600,400'
    $Form.BackColor   = "#ffffff"

    $DropDown = new-object System.Windows.Forms.ComboBox
    $DropDown.Location = new-object System.Drawing.Size(150,10)
    $DropDown.Size = new-object System.Drawing.Size(130,30)

    ForEach ($Item in $DropDownArray) {
     [void] $DropDown.Items.Add($Item)
    }

    $DropDown.add_TextChanged({toggle})
    
    $Form.Controls.Add($DropDown)

    $DropDownLabel = new-object System.Windows.Forms.Label
    $DropDownLabel.Location = new-object System.Drawing.Size(10,10) 
    $DropDownLabel.size = new-object System.Drawing.Size(80,20) 
    $DropDownLabel.Text = "Select Task:"
    $Form.Controls.Add($DropDownLabel)

    $Button = new-object System.Windows.Forms.Button
    $Button.Location = new-object System.Drawing.Size(300,10)
    $Button.Size = new-object System.Drawing.Size(100,20)
    $Button.Text = "Execute"
    $Button.Add_Click({Return-DropDown})
    $form.Controls.Add($Button)
    $form.ControlBox = $false

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(420,10)
    $CancelButton.Size = New-Object System.Drawing.Size(75,20)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$form.Close()})
    $form.Controls.Add($CancelButton)


    $Label2 = new-object System.Windows.Forms.Label
    $Label2.Location = new-object System.Drawing.Size(10,40) 
    $Label2.size = new-object System.Drawing.Size(100,40) 
    $Label2.Text = "Enter Value"
    $Form.Controls.Add($Label2)

    $textbox = new-object System.Windows.Forms.TextBox
    $textbox.Location = new-object System.Drawing.Size(150,40)
    $textbox.Size = new-object System.Drawing.Size(130,30)
    $textbox.Text = "Enter value"
    $form.Controls.Add($textbox)
    $form.ControlBox = $false

    $nested = new-object System.Windows.Forms.TextBox
    $nested.Location = new-object System.Drawing.Size(150,60)
    $nested.Size = new-object System.Drawing.Size(350,200)
    $nested.Height = 250
    $nested.Text = "Enter Nested Object"
    $nested.Multiline = $true
    $nested.Scrollbars = "Vertical"
    $nested.Enabled  = $false 
    $form.Controls.Add($nested)
    $form.ControlBox = $false

   
   
    $Form.Add_Shown({$Form.Activate()})
    [void] $Form.ShowDialog()


    return $script:choice
}



####################################################################################################################################
#endregion


$options = UserInput
$scriptPath = $PSScriptRoot


if($options[0] -eq 'Nested Object') {

        Write-Host $textbox.Text
 
        $jsonConfigFile = $scriptPath + "\output.json"

        #$json = Get-Content $jsonConfigFile |  ConvertFrom-Json | Flatten-Object -Depth 10 |  ConvertTo-Hashtable

        $json = $options[2] |  ConvertFrom-Json | Flatten-Object -Depth 10 |  ConvertTo-Hashtable

        $results =   $json.GetEnumerator() | Where-Object { $_.Key -match $options[1] }

        $results | Out-GridView -OutputMode Single -Title $options[1]
   
 
    }elseif($options[0] -eq 'Execute Locally')
{

    $IMDS = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -NoProxy -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64

   
    $IMDS |  ConvertFrom-Json | Flatten-Object -Depth 10 |  ConvertTo-Hashtable | Out-GridView -OutputMode Single -Title $options[0]

}else {


    
    Enable-PSRemoting -SkipNetworkProfileCheck -Force

    $Cred = Get-Credential

    $result = Invoke-Command –ComputerName  $options[1] -Credential  $Cred –ScriptBlock { 
    
    Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -NoProxy -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64
    
    }

    $result |  ConvertFrom-Json | Flatten-Object -Depth 10 |  ConvertTo-Hashtable | Out-GridView -OutputMode Single -Title $options[0]



}



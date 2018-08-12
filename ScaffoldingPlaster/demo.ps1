
write-warning "This is a walkthrough demo"
return

#https://github.com/powershell/plaster
find-module plaster

get-command -Module plaster
Get-PlasterTemplate

help New-PlasterManifest

$new = "c:\work\plastermanifest.xml"
$params = @{
    Path = $new 
    TemplateName = "MyTool" 
    TemplateType = "Item" 
    Title = "My Tool" 
    Description = "Scaffold a PowerShell command" 
    Author = "Jeff Hicks" 
    Tags = "function" 
    TemplateVersion = "0.0.1"
}
New-PlasterManifest @params 
Get-PlasterTemplate -Path c:\work -Recurse

psedit $new

#parameters
<#
Name
Text
Choice
Default values
parameters as variables
#>

#content
<#
message
file
templatefile
#>
#built in plaster Variables

<#
<parameters>
    <parameter name='Name' type='text' prompt='Enter the name of your function.'/>
    <parameter name='Version' type='text' prompt='What is the function version?' default='0.1.0'/>
    <parameter name='OutputType' type='text' prompt='What type of output is expected' default="[PSCustomObject]"/>
    <parameter name="ShouldProcess" type="choice" prompt="Do you need to support -WhatIf ?>" default='1'>
        <choice label="&amp;Yes" help="Adds SupportsShouldProcess" value="Yes" />
        <choice label="&amp;No" help="Does not add SupportsShouldProcess" value="No" />
    </parameter>
  </parameters>
  <content>
  <message>
  
************************************************
  Creating an outline for ${PLASTER_PARAM_Name}
************************************************
   
   </message>
   <!-- template sources are relative to manifest -->
   <templateFile source='myfunction.txt' destination='${PLASTER_PARAM_Name}.ps1'/>
   <message>Your function, '$PLASTER_PARAM_Name', has been saved to '$PLASTER_DestinationPath\$PLASTER_PARAM_Name.ps1'</message>

  </content>
#>
Invoke-Plaster -TemplatePath c:\work -DestinationPath c:\work 

#open new function in an editor
#there are Limitations

invoke-item .\myTemplates

#mytemplates has been copied to Programfiles
#Get-PlasterTemplate -IncludeInstalledModules | tee -Variable t

Get-PlasterTemplate -Recurse -Path .

$modPath = "c:\Scripts\PSMagic"

Invoke-Plaster -TemplatePath .\myTemplates\myProject -destinationpath $modPath
#add a command
Invoke-Plaster -TemplatePath .\myTemplates\myFunction -DestinationPath $modPath

#you can also skip interactive
$hash = @{
  TemplatePath = ".\mytemplates\myfunction"
  DestinationPath = $modPath
  #these are template parameters
  Name = "Set-Magic"
  Version = "0.1.0"
  OutputType = "none"
  ShouldProcess = "yes"
  Help = "no"
  Computername = "yes"
  Force = $True
  NoLogo = $True
}

Invoke-Plaster @hash
#open new project
psedit $modpath

#reset demo
# del $modpath -Recurse -force

#get help
start https://github.com/PowerShell/Plaster/blob/master/docs/en-US/about_Plaster_CreatingAManifest.help.md
start https://overpoweredshell.com/Working-with-Plaster/
start https://leanpub.com/powershell-conference-book
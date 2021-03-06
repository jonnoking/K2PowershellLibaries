Function Get-K2EnvironmentLibraryTemplatesAsXMLTest
{
<#
   .Synopsis
    This function Gets Environment Library values and returns as XML from the k2 server according to parameters
   .Description
    This function Gets Environment Library values and returns as XML according to parameters. 
	The XML will be in the following format:
	<Templates>
  <Template TemplateId="CFAEF87A-FF85-47D4-8BA0-E3C93EFD8D5F" TemplateName="Administration" IsDefaultTemplate="True" TemplateDescription="Default Template">
    <Environments>
      <Environment EnvironmentId="1BDA9DED-B8F9-404D-A8D9-801A195D16F9" EnvironmentName="Development" EnvironmentDescription="Development" IsDefaultEnvironment="True">
        <EnvironmentFields>
          <EnvironmentField FieldName="autoportal" Value="http://autoportal.denallix.com/" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="blahbalh" Value="http://portal" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="Category Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="Category Server"></EnvironmentField>
          <EnvironmentField FieldName="Forms Web Server" Value="http://localhost" fieldTypeName="Miscellaneous Field"></EnvironmentField>
          <EnvironmentField FieldName="Job Requisition Site" Value="http://portal.denallix.com/JobRequisitions/" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="Live" Value="http://portal.denallix.com/sites/Live" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="Mail Server" Value="mail.denallix.com" fieldTypeName="Mail Server"></EnvironmentField>
          <EnvironmentField FieldName="Portal" Value="http://portal.denallix.com" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="sdfsdf" Value="" fieldTypeName="Miscellaneous Field"></EnvironmentField>
          <EnvironmentField FieldName="ServiceObject Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="ServiceObject Server"></EnvironmentField>
          <EnvironmentField FieldName="SmartObject Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="SmartObject Server"></EnvironmentField>
          <EnvironmentField FieldName="Web Service URL" Value="http://k2workspace" fieldTypeName="Web Service URL"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Management Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="Workflow Management Server"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5252" fieldTypeName="Workflow Server"></EnvironmentField>
        </EnvironmentFields>
      </Environment>
      <Environment EnvironmentId="1BDA9DED-B8F9-404D-A8D9-E3C93EFD8D5F" EnvironmentName="Production" EnvironmentDescription="Production" IsDefaultEnvironment="False">
        <EnvironmentFields>
          <EnvironmentField FieldName="autoportal" Value="http://autoportal.denallix.com/" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="blahbalh" Value="" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="Category Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="Category Server"></EnvironmentField>
          <EnvironmentField FieldName="Forms Web Server" Value="" fieldTypeName="Miscellaneous Field"></EnvironmentField>
          <EnvironmentField FieldName="Job Requisition Site" Value="http://portal.denallix.com/JobRequisitions/" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="Live" Value="" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="Mail Server" Value="mail.denallix.com" fieldTypeName="Mail Server"></EnvironmentField>
          <EnvironmentField FieldName="Portal" Value="http://portal.denallix.com/" fieldTypeName="SharePoint Site URL"></EnvironmentField>
          <EnvironmentField FieldName="sdfsdf" Value="" fieldTypeName="Miscellaneous Field"></EnvironmentField>
          <EnvironmentField FieldName="ServiceObject Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="ServiceObject Server"></EnvironmentField>
          <EnvironmentField FieldName="SmartObject Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="SmartObject Server"></EnvironmentField>
          <EnvironmentField FieldName="Web Service URL" Value="http://k2workspace" fieldTypeName="Web Service URL"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Management Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" fieldTypeName="Workflow Management Server"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Server" Value="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5252" fieldTypeName="Workflow Server"></EnvironmentField>
        </EnvironmentFields>
      </Environment>
    </Environments>
  </Template>
  <Template TemplateId="366491da-99c1-44f2-bd80-35ee0d71476c" TemplateName="HR" IsDefaultTemplate="False" TemplateDescription="">
    <Environments>
      <Environment EnvironmentId="feb6174a-6de3-4301-a607-538e1d2eea98" EnvironmentName="Development" EnvironmentDescription="" IsDefaultEnvironment="False">
        <EnvironmentFields>
          <EnvironmentField FieldName="Category Server" Value="" fieldTypeName="Category Server"></EnvironmentField>
          <EnvironmentField FieldName="Mail Server" Value="" fieldTypeName="Mail Server"></EnvironmentField>
          <EnvironmentField FieldName="ServiceObject Server" Value="" fieldTypeName="ServiceObject Server"></EnvironmentField>
          <EnvironmentField FieldName="SmartObject Server" Value="" fieldTypeName="SmartObject Server"></EnvironmentField>
          <EnvironmentField FieldName="Web Service URL" Value="" fieldTypeName="Web Service URL"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Management Server" Value="" fieldTypeName="Workflow Management Server"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Server" Value="" fieldTypeName="Workflow Server"></EnvironmentField>
        </EnvironmentFields>
      </Environment>
      <Environment EnvironmentId="09677aae-bf4f-432a-a5e6-191ffc9be839" EnvironmentName="Production" EnvironmentDescription="" IsDefaultEnvironment="False">
        <EnvironmentFields>
          <EnvironmentField FieldName="Category Server" Value="" fieldTypeName="Category Server"></EnvironmentField>
          <EnvironmentField FieldName="Mail Server" Value="" fieldTypeName="Mail Server"></EnvironmentField>
          <EnvironmentField FieldName="ServiceObject Server" Value="" fieldTypeName="ServiceObject Server"></EnvironmentField>
          <EnvironmentField FieldName="SmartObject Server" Value="" fieldTypeName="SmartObject Server"></EnvironmentField>
          <EnvironmentField FieldName="Web Service URL" Value="" fieldTypeName="Web Service URL"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Management Server" Value="" fieldTypeName="Workflow Management Server"></EnvironmentField>
          <EnvironmentField FieldName="Workflow Server" Value="" fieldTypeName="Workflow Server"></EnvironmentField>
        </EnvironmentFields>
      </Environment>
    </Environments>
  </Template>
</Templates>
	.Example
        Get-K2EnvironmentLibraryTemplatesAsXML
		Get-K2EnvironmentLibraryTemplatesAsXML -SCconnectionString "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555"
   .Parameter $SCconnectionString
        Connection string to the K2 Environment Library server
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param(	[Parameter(Mandatory=$false)][string]$SCconnectionString= "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555",
		[Parameter(Mandatory=$false)][string]$TemplateName="*"
)

Write-debug "** Get-K2EnvironmentLibraryTemplatesAsXML()"

	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
	
	
	$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
	$environmentSettingsManager.ConnectToServer($SCconnectionString) | out-null;
    $environmentSettingsManager.InitializeSettingsManager() | out-null;
    $environmentSettingsManager.Disconnect() | out-null;


	[xml]$xml = $environmentSettingsManager.EnvironmentTemplates | New-XML -RootTag Templates -ItemTag Template -Attribute TemplateId,TemplateName,IsDefaultTemplate,TemplateDescription -ChildItems Environments 
	Write-Verbose $xml.OuterXML
	$environmentSettingsManager.EnvironmentTemplates | foreach-object {
		
		
		$CurrentTemplateName = $_.TemplateName
		if(($TemplateName -eq "*") -or ($TemplateName -eq "$CurrentTemplateName"))
		{
		
	        Write-Debug "$CurrentTemplateName";
	        Write-Debug("==================");
			
			$EnvironmentsXML = Get-K2EnvironmentLibrariesAsXML -TemplateName $CurrentTemplateName -SCconnectionString $SCconnectionString
			
			$xml.SelectSingleNode("/Templates/Template[@TemplateName='$CurrentTemplateName']").InnerXml = $EnvironmentsXML.OuterXml
		}
		else
		{
			#Template node not required - delete from XML
			$nodeToRemove = $xml.SelectSingleNode("/Templates/Template[@TemplateName='$CurrentTemplateName']")
			$nodeToRemoveFrom = $xml.SelectSingleNode("/Templates")
			$nodeToRemoveFrom.RemoveChild($nodeToRemove)
		}
    }
	$xml.OuterXml
	Write-debug "** Get-K2EnvironmentLibraryTemplatesAsXML() -Finished"
        

}



##################
#
# A simple case to create a template for a new team with a set of environments and default fields
# then export it to an xml file so that the server data can be manipulated
# two formats for XML 
# 1) With all templates
# 2) With just the Env Libs
#
##################
$NewTemplateName = "RedTeam"
#Will fail first time
Remove-K2EnvironmentLibraryTemplate -TemplateName $NewTemplateName

Add-K2EnvironmentLibraryTemplate -TemplateName "$NewTemplateName" -TemplateDescription "This is for the $NewTemplateNames server configuration values for each environment"
Add-K2EnvironmentLibrary -TemplateName "$NewTemplateName" -EnvironmentName "$NewTemplateName.Staging" -EnvironmentDescription "This is for the $NewTemplateNames staging environment"
Add-K2EnvironmentLibrary -TemplateName "$NewTemplateName" -EnvironmentName "$NewTemplateName.Farm1" -EnvironmentDescription "This is for the $NewTemplateNames server config values that match Farm1 Environment"
Add-K2EnvironmentLibrary -TemplateName "$NewTemplateName" -EnvironmentName "$NewTemplateName.Farm2" -EnvironmentDescription "This is for the $NewTemplateNames server config values that match Farm2 Environment"
Add-K2EnvironmentLibrary -TemplateName "$NewTemplateName" -EnvironmentName "$NewTemplateName.Enterprise" -EnvironmentDescription "This is for the $NewTemplateNames server config values that match the Enterprise Environment"
[xml]$Allk2templatesxml = Get-K2EnvironmentLibraryTemplatesAsXML
$Allk2templatesxml.Save(".\AllTemplates.xml")
[xml]$k2RedTeamEnvLibsxml = Get-K2EnvironmentLibrariesAsXML -TemplateName $NewTemplateName
$k2RedTeamEnvLibsxml.Save(".\$NewTemplateName.xml")
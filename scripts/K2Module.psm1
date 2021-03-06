#Misc
Add-Type -TypeDefinition @"
   // Enum for bitwise comparison of permisions
   [System.Flags]
   public enum K2SmartObjectPermission
   {
      None=0,
      Publish=1,
      Delete=2
   }
"@

Add-Type -TypeDefinition @"
   // Enum for K2 security settings
   public enum K2SecuritySettings
   {
      ResolveNestedGroups=0,
      ADCache=1,
      LDAPPath=2,
      IgnoreForeignPrincipals=3,
      IgnoreUserGroups=4,
      MultiDomain=5,
      OnlyUseSecurityGroup=6,
	  DataSources=7
   }
"@

Function Read-Activities()
{
   [CmdletBinding()]
    Param ($directory="$pwd\")

    ###write-verbose "... Listing all activities in all processes in $directory"

    [Reflection.Assembly]::LoadWithPartialName(“SourceCode.Workflow.Authoring”) | out-null
    $output = ""
    $nl = [Environment]::NewLine
    "Process Name,Activity Name,Action Name"
    
    $fileEntries = Get-ChildItem "$directory*.kprx" |
    foreach { 
        $fileName = $_.Name

        [SourceCode.Workflow.Authoring.Process]$proc = [SourceCode.Workflow.Authoring.Process]::Load("$directory$fileName");
        $proc.Activities | 
        ForEach {
            $activityName = $_.Name
            
            [bool]$printActivity = $true;
                    
            $_.Events | 
            ForEach {
                if ($_.Actions.Count -gt 0)
                {
                    $eventName=$_.Name
                    if ($printActivity)
                    {
                       # write-verbose "Activity: $actName", 
                        $printActivity = $false;
                    }
                    $_.Actions | 
                    ForEach {
                        $actionName = $_.Name
                        $output =  "$output$fileName,$activityName,$actionName$nl"
                        
                    }
                }  
            }  
        }
    }
    
    "$output"
       
}

Function Set-K2WorklistItemActioned
{
<#
   .Synopsis
    This function will action a worklist item (useful if it is set not to action from worklist)
   .Description
	This function will action a worklist item (useful if it is set not to action from worklist)
	If no parameters are provided it will default to localhost:5252 and prompt you for a sn and an action
	   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#> 
[CmdletBinding()]
   Param([parameter(Mandatory=$true)] [string]$sn, 
   [parameter(Mandatory=$true)] [string]$action, 
   [parameter(Mandatory=$false)] [string]$k2Host="localhost", 
   [parameter(Mandatory=$false)] [int]$k2HostPort=5252, 
   [parameter(Mandatory=$false)] [string]$k2ConnectionString
   )
   [Reflection.Assembly]::LoadWithPartialName(“SourceCode.Workflow.Client”) | out-null
	if ($k2ConnectionString -eq $null)
	{
		$k2ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2HostPort"
	}
	$k2con = New-Object SourceCode.Workflow.Client.Connection
	$k2con.Open($k2Host, $k2ConnectionString);
	
	$worklistItem = $k2con.OpenWorklistItem($sn);
	$worklistItem.Actions["$action"].Execute();
	$k2con.Dispose();

}

#Connectivity
Function Open-K2ServerConection
{
<#
   .Synopsis
    This function is depriciated. Use either Open-K2WorkflowClientConnectionVerboseError or Open-K2WorkflowClientConnectionThrowError
   .Description
        This function is depriciated. Use either Open-K2WorkflowClientConnectionVerboseError or Open-K2WorkflowClientConnectionThrowError
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param($k2con,
	$k2Host="localhost",
	$k2WorkflowPort=5252)

	Open-K2WorkflowClientConnectionVerboseError $k2con $k2Host $k2WorkflowPort
}

Function Open-K2WorkflowClientConnectionVerboseError
{
<#
   .Synopsis
    This function opens a connection to the k2 wf server according to parameters
   .Description
    This function opens a connection to the k2 wf server according to parameters. It will not throw an error if the connection open fails
   .Example
        Open-K2WorkflowClientConnectionVerboseError $k2con "DLX" 5555
   .Parameter $k2con
   	    Required the instansiated but not open connection 
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2WorkflowPort
        Defaults to 5252
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param($k2con,
	$k2Host="localhost",
	$k2WorkflowPort=5252)

	trap {write-verbose "..Failed-Try again"; "error"; continue}
	Open-K2WorkflowClientConnectionThrowError $k2con $k2Host $k2WorkflowPort
}

Function Open-K2WorkflowClientConnectionThrowError
{
<#
   .Synopsis
    This function opens a connection to the k2 wf server according to parameters
   .Description
    This function opens a connection to the k2 wf server according to parameters. It will throw an error if the connection open fails
   .Example
        Open-K2WorkflowClientConnectionThrowError $k2con "DLX" 5252
   .Parameter $k2con
   	    Required the instansiated but not open connection 
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2WorkflowPort
        Defaults to 5252
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param($k2con,
	$k2Host="localhost",
	$k2WorkflowPort=5252)

	$k2con.Open($k2Host, "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2WorkflowPort");
		
}

Function Open-K2SMOManagementConnectionVerboseError
{
<#
   .Synopsis
    This function opens a connection to the k2 smo server according to parameters
   .Description
    This function opens a connection to the k2 smo server according to parameters. It will not throw an error if the connection open fails
   .Example
        Open-K2SMOManagementConnectionVerboseError $k2con "DLX" 5555
   .Parameter $k2SMOServer
   	    an instansiated object of class [SourceCode.SmartObjects.Management.SmartObjectManagementServer] 
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2SMOManagementPort
        Defaults to 5555
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param([SourceCode.SmartObjects.Management.SmartObjectManagementServer]$k2SMOServer,
	$k2Host="localhost",
	$k2SMOManagementPort=5555)

	trap {write-verbose "..Failed-Try again"; "error"; continue}
	Open-K2SMOManagementConnectionThrowError $k2SMOServer $k2Host $k2SMOManagementPort
}

Function Get-K2SMOManagementConnectionThrowError
{
<#
   .Synopsis
    This function opens a connection to the k2 wf server according to parameters
   .Description
    This function opens a connection to the k2 wf server according to parameters. It will throw an error if the connection open fails
   .Example
        Get-K2SMOManagementConnectionThrowError $k2con "DLX" 5555
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $$k2SMOManagementPort
        Defaults to 5555
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param([Parameter(Position=0)][string]$k2Host="localhost",
	[Parameter(Position=1)][int]$k2SMOManagementPort=5555)

	Write-debug "** SourceCode.SmartObjects.Management"
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.SmartObjects.Management”) | out-null
	
	Write-Debug "SmartObjectManagementServer"
	[SourceCode.SmartObjects.Management.SmartObjectManagementServer]$k2SMOServer = New-Object SourceCode.SmartObjects.Management.SmartObjectManagementServer

	Write-Debug "Creating the connection"
	$k2SMOServer.CreateConnection();
	
	Write-Debug "Opening the connection"
	$k2SMOServer.Connection.Open("Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2SMOManagementPort");

	$IsConnected = $k2SMOServer.Connection.IsConnected
	Write-Debug	 "Is the SmartObjectManagementServer Connected? $IsConnected"
	Write-Output $k2SMOServer
}

Function Open-K2SMOServiceManagementConnectionThrowError
{
<#
   .Synopsis
    This function opens a connection to the K2 WF server according to parameters
   .Description
    This function opens a connection to the K2 WF server according to parameters. It will throw an error if the connection open fails
   .Example
        Open-K2SMOServiceManagementConnectionThrowError $k2con "DLX" 5555  
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2SMOManagementPort
        Defaults to 5555
   .Notes
		AUTHOR: Paul Kelly, K2
		#Requires -Version 2.0
#>  
	[CmdletBinding()]
	Param([Parameter(Position=0)][string]$k2Host="localhost",
	[Parameter(Position=1)][int]$k2SMOManagementPort=5555)

	Write-Debug "** SourceCode.SmartObjects.Management"
	[Reflection.Assembly]::LoadWithPartialName("SourceCode.SmartObjects.Management") | Out-Null

	Write-Debug "ServiceManagementServer"
	[SourceCode.SmartObjects.Services.Management.ServiceManagementServer]$k2ServiceManagementServer = New-Object SourceCode.SmartObjects.Services.Management.ServiceManagementServer

	Write-Debug "Creating the connection"
	$k2ServiceManagementServer.CreateConnection();

	Write-Debug "Opening the connection"
	$k2ServiceManagementServer.Connection.Open("Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2SMOManagementPort");

	$IsConnected = $k2ServiceManagementServer.Connection.IsConnected
	Write-Debug	 "Is the ServiceManagementServer Connected? $IsConnected"
	Write-Output $k2ServiceManagementServer
}

Function Test-K2Connection
{
   [CmdletBinding()]
   param($k2Connection)
	trap {write-debug "$error[0]"; write-Output $false; continue}
	[bool]$IsConnected = $k2Connection.Connection.IsConnected
	Write-Verbose	 "Test-K2Connection: K2Server Connected? $IsConnected"
	Write-Output $IsConnected
}

Function Test-K2Server
{
<#
   .Synopsis
    This function tests to see if the K2 server is up
   .Description
    This function tests to see if the K2 server is up according to parameters. 
	It will throw an error if the connection fails is not up after a configured time
	It will return as soon as it opens a connection to the K2 workflow server is made succcessfully
	This is used to test if the k2 sever is up and then continue with other
	function that need a working k2 server.
   .Example
        Test-K2Server 
		Test-K2Server -SecondsToWaitForResponse 5 -SecondsToWaitBeforeTest 10 -SecondsToWaitBeforeRetrying 1 -verbose
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2WorkflowPort
        Defaults to 5252
   .Parameter  $SecondsToWaitForResponse
        Defaults to 100. This should really be called $numberOfAttemptsToRetry
		It signifies the number of times to retry if last connection failed
   .Parameter  $SecondsToWaitBeforeTest
        Defaults to 10
		When the K2 server is restarted it normaally takes about 5-8 seconds before 
		a workflow connection is available. If we wait for 10 seconds before checking, then less likely
		that £Error.Count is incremented
   .Parameter  $SecondsToWaitBeforeRetrying
        Defaults to 1
		How long to wait before re-trying
   .Notes
		AUTHOR: Lee Adams, K2
		#Requires -Version 2.0
#>  
   [CmdletBinding()]
Param(
[string]$k2Host="localhost", 
[int]$k2WorkflowPort=5252, 
[int]$SecondsToWaitForResponse=100, 
[int]$SecondsToWaitBeforeTest=10, 
[int]$SecondsToWaitBeforeRetrying=1
)
Write-debug "** Test-K2Server()"
write-verbose "Testing the K2 server - This may take a while to register assemblies"
[Reflection.Assembly]::LoadWithPartialName(“SourceCode.Workflow.Client”) | out-null

	$totalWaitTime= $SecondsToWaitBeforeTest + ($SecondsToWaitBeforeRetrying * $SecondsToWaitForResponse)
	Write-Verbose "**** Trying to open a connection for $totalWaitTime seconds to allow time for the K2 service to start up"
	$x=0
	$success =$false
	$k2con = New-Object SourceCode.Workflow.Client.Connection
	
	sleep $SecondsToWaitBeforeTest
	while (($x -lt $SecondsToWaitForResponse) -and (!$success))
	{
		$success = $true
		$error.clear();
		$errorMsg="";
		
		$errorMsg = Open-K2WorkflowClientConnectionVerboseError $k2con $k2Host $k2WorkflowPort
		If($errorMsg -eq "error")
		{
			$success = $false
		}
			
		sleep $SecondsToWaitBeforeRetrying;
		$x++ ;
	}
	If ($Success)
	{
		write-verbose "* K2 server is up - now closing the connection *"
		$k2con.Dispose()
	}
	else
	{
		Throw (New-Object System.Management.Automation.RuntimeException "K2 server never responded")
	}
}

Function Restart-K2Server()
{
<#
   .Synopsis
    This function restarts the k2 server and wait until it is responding before returning control
   .Description
    This function restarts the k2 server and wait until it is responding before returning control.
    
    It uses the SourceCode.Workflow.Client to keep retrying to open a connection every second, until it suceeds
    It defaults to localhost and port 5252 and retries the k2server up to 100 times.
    Parameters can be provided for all 3 if required
    It can also prompt the user if they want to do this.
   .Example
        RestartK2ServerAndWait -Prompt $true
   .Example
        RestartK2ServerAndWait "dlx" 5252 25 $false
   .Parameter $k2Host
            Defaults to localhost, not entirely sure it is useful to override this.
   .Parameter $k2WorkflowPort
            Defaults to 5252
   .Parameter $SecondsToWaitForResponse
        How long do you want to wait before the script errors. Defaults to 100
   .Parameter $Prompt
        Are you absolutely sure you want to do this? Defaults to not prompting.
        Comes in useful as sometimes Service Broker dlls are in use by the server and sometimes they are not.
        If True it will also check if broker tools are running and prompt the user to shut them down
   .ConsoleMode $ConsoleMode
        Set this to true if this the K2 server is a windows 7 dev machine
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>
   [CmdletBinding()]
Param(
[bool]$WaitUntilRestart=$true,
[string]$k2Host="localhost", 
[int]$k2WorkflowPort=5252, 
[int]$SecondsToWaitForResponse=100, 
[bool]$Prompt=$false, 
[bool]$ConsoleMode=$false)


    $EnvironmentChoice=0
    If($Prompt -eq $true) 
    {
        $title = "Restart K2 server?"
        $message= "Would you like to restart the K2 server?"
        $options =@('&Yes','&No')
        $PromptOptions = [System.Management.Automation.Host.ChoiceDescription[]]($options)
        $EnvironmentChoice = $host.ui.PromptForChoice($title, $message, $PromptOptions, 0) 
    }
    If(($EnvironmentChoice -eq 0)) 
    {        
        $blackPearlServiceName="K2 blackpearl Server"
		
		if ($ConsoleMode -eq $true)
		{
			$a = get-process "K2HostServer"

			if ($a -ne $null)
			{
				
				Write-debug "**** Console Window running"
				stop-process $a.id -force
				# Anoyingly the next line will not work as the process is killed by k2 still seems to be up
				wait-process $a.id -erroraction:silentlycontinue

			}
			throw "Not Implemented"
###			$args = '-color:Green'
###			$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
###			Start-Process -Credential $cred  "C:\Program Files (x86)\K2 blackpearl\Host Server\Bin\K2HostServer.exe" $args
			
###			Write-Host "**** Console Window now started"
			
		}
		else
		{
			$blackPearlServiceStatus=Test-Service $blackPearlServiceName
			If ($blackPearlServiceStatus -eq "Running")
			{
				write-verbose "**** STOPPING and restarting K2 Server at '$k2Host'"
				Restart-Service -displayname $blackPearlServiceName -EA "Stop"
			}
			elseif ($blackPearlServiceStatus -eq "Stopped")
			{
				write-verbose "**** Starting K2 Server at '$k2Host'"
				Start-Service -displayname $blackPearlServiceName -EA "Stop"
			}
			else
			{
				$message="The K2 server is $blackPearlServiceStatus. Not sure how to handle it when it is not Stopped or Running"
				Throw $message
			}
		}
        write-verbose "**** restart successful******"
		if($WaitUntilRestart)
		{
			Test-K2Server -k2Host $k2Host -k2WorkflowPort $k2WorkflowPort
		}

    }
    If($Prompt)
    {
        If((Get-Process "SmartObject Service Tester" -EA SilentlyContinue) -ne $null) {Read-Host "SmO Tester running. It is advisable to shut it down. Press Enter when done."}
        If((Get-Process "BrokerManagement" -EA SilentlyContinue) -ne $null) {Read-Host "BrokerManagement.exe running. It is advisable to shut it down. Enter when done."}
    }
}

#Settings Discovery
Function Test-K2BlackPearlDirectorys
{
	$K2BlackPearlDirectory=(Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\SourceCode\BlackPearl\BlackPearl Host Server\").InstallDir 
    If (Test-IsNullOrEmpty($K2BlackPearlDirectory))  
    {
		#Returns the setting if it is found
    Test-Directory -K2BlackPearlDirectory "D:\Program Files\K2 blackpearl\Host Server\"
    Test-Directory -K2BlackPearlDirectory "D:\Program Files (x86)\K2 blackpearl\Host Server\"
    Test-Directory -K2BlackPearlDirectory "C:\Program Files\K2 blackpearl\Host Server\"
    Test-Directory -K2BlackPearlDirectory "C:\Program Files (x86)\K2 blackpearl\Host Server\"
	}
	else
	{
		$K2BlackPearlDirectory
	}
}

Function Set-K2BlackPearlDirectory
{
	
	$K2BlackPearlDirectory= Test-K2BlackPearlDirectorys 
	If (Test-IsNullOrEmpty($K2BlackPearlDirectory))  
    {
		Write-Host "Please Type in the path for the K2 Blackpearl directory. E.g. Z:\Program Files (x86)\K2 blackpearl"
		$K2BlackPearlDirectory=Get-ValidDirectory
	}
	If(!$K2BlackPearlDirectory.EndsWith("\"))
    {
		$K2BlackPearlDirectory="$K2BlackPearlDirectory\"
	}
    $K2BlackPearlDirectory=$K2BlackPearlDirectory.Replace("\Host Server","\").Replace("\\", "\")
	if(Test-Path variable:global:Global_K2BlackPearlDir)
	{
		$Global_K2BlackPearlDir = "$K2BlackPearlDirectory"
	}
	else
	{
		New-Variable -Name Global_K2BlackPearlDir -Value "$K2BlackPearlDirectory" -Scope "Global" -option ReadOnly
	}
}
#Use msbuild projects for Service broker deployment

Function Get-CategoryServer
{
<#
   .Synopsis
    This function TODO
   .Description
    This function TODO
   .Example
        Open-K2WorkflowClientConnectionThrowError $k2con "DLX" 5555
   .Parameter $k2con
   	    Required the instansiated but not open connection 
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2WorkflowPort
        Defaults to 5252
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param([Parameter(Position=0)][string]$k2Host="localhost",
	[Parameter(Position=1)][int]$k2SMOManagementPort=5555)

	Write-debug "** SourceCode.SmartObjects.Management"
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.Categories.Client”) | out-null
	
	Write-Debug "SmartObjectManagementServer"
	[SourceCode.Categories.Client.CategoryServer]$k2SMOServer = New-Object SourceCode.Categories.Client.CategoryServer

	Write-Debug "Creating the connection"
	$k2SMOServer.CreateConnection();
	
	Write-Debug "Opening the connection"
	$k2SMOServer.Connection.Open("Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2SMOManagementPort");

	$IsConnected = $k2SMOServer.Connection.IsConnected
	Write-Debug	 "Is the SmartObjectManagementServer Connected? $IsConnected"
	Write-Output $k2SMOServer
}

Function Delete-SmartObject
{
<#
   .Synopsis
    This function Delete-SmartObject from the k2 server according to parameters
   .Description
    This function Delete-SmartObject according to parameters.
   .Example
        Publish-K2SMOsFromServiceInstance "DLX" 5555
   .Parameter $k2con
   	    Required the instansiated but not open connection 
   .Parameter $k2Host
        Defaults to "localhost"[SourceCode.SmartObjects.Management.SmartObjectManagementServer]
   .Parameter  $k2WorkflowPort
        Defaults to 5252[SourceCode.Categories.Client.CategoryServer]
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param(	[Parameter(Mandatory=$true)][string]$SmartObjectName,
	[Parameter(Mandatory=$false)]$SmartObjectManagementServer,
	[Parameter(Mandatory=$false)]$CategoryManagementServer,
	[Parameter(Mandatory=$false)][string]$k2Host="localhost",
	[Parameter(Mandatory=$false)][int]$k2ManagementPort=5555
)

Write-debug "** Delete-SmartObject()"

if (!(Test-K2Connection $SmartObjectManagementServer))
{
	$SmartObjectManagementServer = Get-K2SMOManagementConnectionThrowError $k2Host $k2ManagementPort
}
[SourceCode.SmartObjects.Management.SmartObjectExplorer]$smartObjects = $SmartObjectManagementServer.GetSmartObjects($SmartObjectName);

	$smartObjects.SmartObjects | ForEach-Object {

		$SmartObjectManagementServer.DeleteSmartObject($_.Guid, $true);

        if (!(Test-K2Connection $CategoryManagementServer))
		{
			$CategoryManagementServer = Get-CategoryServer $k2Host $k2ManagementPort
		}
		
		Write-Debug "$SmartObjectType"
        $CategoryManagementServer[2].DeleteCategoryData($_.Guid.ToString(), [SourceCode.Categories.Client.CategoryServer+dataType]::SmartObject);

    }
}

Function New-K2Packages()
{
<#
   .Synopsis
    This function creates K2 Deployment packages including an msbuild file according to parameters
   .Description
	Finds all .k2proj files in a given directory structure and calls New-K2Package to package them into a output directory structure
    This function requires K2Deploy.msbuild and K2Field.Utilities.Build 
	(available from http://www.k2underground.com/groups/k2_build_and_deploy_msbuild_tasks/default.aspx)
	K2Deploy.msbuild requires changing to match the following 
	<K2Deploy 
			Server="$(Computername)"
			Port="$(Port)"
			ProjectPath="$(K2Project)"
			OutputPath="$(OutputPath)" />
   .Example
        New-K2Packages    "dlx" 5555 "..\..\K2Shared\trunk\" "C:\deployment"
        New-K2Packages    -K2ServerWithAllEnvSettings localhost -SourceCodePathToDiscoverK2ProjFiles C:\tfs\K2.Shared -DeploymentPath C:\tfs\K2.Shared\Deployment
		
   .Parameter     $K2ServerWithAllEnvSettings
        Required. This should be a centralised backed up K2 server which has had all environments added to its env library
		All the settings for all the servers should be populated e.g. MailServer for Live a different setting that the dev or test
   .Parameter     $K2HostServerPort
        defaults to 5555
   .Parameter     $SourceCodePathToDiscoverK2ProjFiles
        Required. The Path to the sourcecode repository for your project where every k2proj file will have a deployment package created
   .Parameter      $DeploymentPath
        Required. The root directory where the project's deployment package will be created.
		It must be a directory and works without the final backslash
		Currently the deployment package is hard coded to K2 Deployment Package.msbuild within each sub directory created
		Subdirectories will have the same name as each .k2proj file found
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
   #>
   [CmdletBinding()]
	Param(
    [parameter(Mandatory=$true)]               
    [ValidateNotNullOrEmpty()]   
	[string]$K2ServerWithAllEnvSettings,

	[int]$K2ServerPortWithAllEnvSettings=5555,

    [parameter(Mandatory=$true)]               
    [ValidateNotNullOrEmpty()]    
    [String] $SourceCodePathToDiscoverK2ProjFiles,
   
    [parameter(Mandatory=$true)]               
    [ValidateNotNullOrEmpty()]    
    [String] $DeploymentPath

	)
	
	Write-Verbose "*** New-K2Packages - Starts"
	$CURRENTDIR=pwd
	###trap {write-host "error"+ $error[0].ToString() + $error[0].InvocationInfo.PositionMessage  -Foregroundcolor Red; cd "$CURRENTDIR"; read-host 'There has been an error'; break}

	Write-Verbose "*Finds all .k2proj files in a given directory structure and calls New-K2Package to package them into a output directory structure"
	Get-ChildItem -Path $SourceCodePathToDiscoverK2ProjFiles -Recurse -Include *.k2proj | ForEach-Object {
		$K2ProjName=$_.BaseName
	
		Write-Debug "* About to create Output directory $DeploymentPath\$K2ProjName"
		new-item $DeploymentPath\$K2ProjName -force -type Directory | out-null

		Write-Debug "* About to build $_ to $DeploymentPath\$K2ProjName"
		Write-Debug "New-K2Package $K2ServerWithAllEnvSettings $K2ServerPortWithAllEnvSettings $_ $DeploymentPath\$K2ProjName"

		New-K2Package $K2ServerWithAllEnvSettings $K2ServerPortWithAllEnvSettings $_ $DeploymentPath\$K2ProjName
	}
	Write-Verbose "*** 4.BuildAndPackage - Ends"

}

Function New-K2Package()
{
<#
   .Synopsis
    This function creates a K2 Deployment package including an msbuild file according to parameters
   .Description
    This function requires K2Deploy.msbuild and K2Field.Utilities.Build 
	(available from http://www.k2underground.com/groups/k2_build_and_deploy_msbuild_tasks/default.aspx)
	K2Deploy.msbuild requires changing to match the following 
	<K2Deploy 
			Server="$(Computername)"
			Port="$(Port)"
			ProjectPath="$(K2Project)"
			OutputPath="$(OutputPath)" />
   .Example
        New-K2Package    "dlx" 5555 "..\..\K2Shared\trunk\SmO\K2Shared.SmO.k2proj" ".\k2 blackpearl\msbuild\All"
        New-K2Package    -K2ServerWithAllEnvSettings dlx -K2Project "..\..\K2Shared\trunk\SmO\K2Shared.SmO.k2proj" -OutputPath ".\k2 blackpearl\msbuild\All"
		
   .Parameter     $K2ServerWithAllEnvSettings
        Required. This should be a centralised backed up K2 server which has had all environments added to its env library
		All the settings for all the servers should be populated e.g. MailServer for Live a different setting that the dev or test
   .Parameter     $K2HostServerPort
        defaults to 5555
   .Parameter     $K2Project
        Required. The k2proj file for the project you wish to build a deployment package for. Must end in .k2proj
   .Parameter      $OutputPath
        Required. The place where the project's deployment package will be created.
		It must be a directory and works without the final backslash
		Currently the deployment package is hard coded to K2 Deployment Package.msbuild
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
   #>
   [CmdletBinding()]
   Param([parameter(Mandatory=$true)] [string]$K2ServerWithAllEnvSettings,  
   [int]$K2HostServerPort=5555, 
   [parameter(Mandatory=$true)] [string]$K2Project, 
   [parameter(Mandatory=$true)] [string]$OutputPath)
   
   Write-Debug "New-K2Package"
   Write-Verbose "*** CREATE PACKAGE AGAINST $K2ServerWithAllEnvSettings settings port: $K2HostServerPort "
   Write-Verbose "*** ABOUT TO Create package for project $K2Project to using $Global_FrameworkPath\MSBUILD outputting here: $OutputPath"	
   
   $K2FieldUtilitiesBuildFolder = "K2Field.Utilities.Build"
   $K2FieldUtilitiesBuildFile = "K2Deploy.msbuild"
   
	& $Global_FrameworkPath\MSBUILD "$Global_MsbuildPath$K2FieldUtilitiesBuildFolder\$K2FieldUtilitiesBuildFile"   /p:Computername=$K2ServerWithAllEnvSettings /p:Port=$K2HostServerPort /p:K2Project=$K2Project /p:OutputPath=$OutputPath

	Write-Verbose "*** Create package for $K2Project - DONE!"
	Write-Verbose "***********************************"
}

Function Publish-K2ServiceType
{
<#
   .Synopsis
    This function deploys a service type according to parameters
   .Description
    This function deploys a service type according to the following parameters
   .Example
        
        Publish-K2ServiceType "c:\WINDOWS\Microsoft.NET\Framework64\v3.5" "C:\installs\RegisterServiceType.msbuild" "localhost" 5555 "5e846dec-170d-4492-bb8c-f1b64600b4e4" "DynamicWebService.ServiceBroker" "Dynamic Web Service" "example desc" "DynamicWebService.ServiceBroker" ".\k2 blackpearl\ServiceBroker\DynamicWebService.dll"
         
   .Parameter     $NetFrameworkPath
        Defaults to "c:\WINDOWS\Microsoft.NET\Framework64\v3.5"
   .Parameter     $MSBUILDCONFIG
        The full path to the RegisterServiceType.msbuild file
   .Parameter     $K2SERVER
        defaults to DLX
   .Parameter     $K2SERVERPORT
        defaults to 5555
   .Parameter      $SERVICETYPESYSTEMNAME
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter     $SERVICETYPEGUID
        Required. This Guid does not have to be the same from environment to environment
        but it helps for the deployServiceInstance scripts to know what the service type GUID is, 
        plus there is no harm in explicitly setting this guid.
   .Parameter      $SERVICETYPESYSTEMNAME
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter      $SERVICETYPEDISPLAYNAME
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter     $SERVICETYPEDESCRIPTION
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter     $SERVICETYPECLASSNAME 
        Required. It is very important to get this correct. If wrong it will STILL LOOK LIKE IT WORKS
        BUT you will get errors when running methods. If unsure what this value should be, register it
        manually and look at the xml (in the database if neccessary)
   .Parameter     $assembliesSourcePath
        The relative or absolute path to the .dll excluding the full assembly name. Everything gets copied
   .Parameter     $assembliesTargetPath
        Required. 
        Where to put it. Normally in the pf\blackpearl\ServiceBroker or a subdirectory off this.
   .Parameter     $serviceTypeAssemblyName
        Required. 
        The full assembly name of the dll.
   .Parameter     $CopyOnly
        Defaults to false. Whether to just copy the dll. Useful in load balanced environments
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
   #>
   [CmdletBinding()]
   Param([string]$NetFrameworkPath="c:\WINDOWS\Microsoft.NET\Framework64\v3.5", 
   [parameter(Mandatory=$true)] [string]$MSBUILDCONFIG, 
   [string]$K2SERVER="dlx", 
   [int]$K2HOSTSERVERPORT=5555,
   [parameter(Mandatory=$true)] [string]$SERVICETYPEGUID, 
   [parameter(Mandatory=$true)] [string]$SERVICETYPESYSTEMNAME, 
   [parameter(Mandatory=$true)] [string]$SERVICETYPEDISPLAYNAME, 
   [parameter(Mandatory=$true)] [string]$SERVICETYPEDESCRIPTION, 
   [parameter(Mandatory=$true)] [string]$SERVICETYPECLASSNAME, 
   [parameter(Mandatory=$false)] [string]$assembliesSourcePath="",
   [parameter(Mandatory=$true)] [string]$assembliesTargetPath,
   [parameter(Mandatory=$true)] [string]$serviceTypeAssemblyName, 
   [parameter(Mandatory=$false)] [bool]$CopyOnly=$false)

	write-debug  "**Publish-K2ServiceType()"
	
	write-debug  "Replacing {BlackPearlDir} with the global variable of $Global_K2BlackPearlDir"
    $assembliesTargetPath=$assembliesTargetPath.Replace("{BlackPearlDir}", "$Global_K2BlackPearlDir")
    $assembliesTargetPath=$assembliesTargetPath.Replace("\\", "\")
    If(!$assembliesTargetPath.EndsWith("\"))
    {
        $assembliesTargetPath="$AssemblyTargetFullPath\"
    }
    $AssemblyTargetFullPath="$assembliesTargetPath$serviceTypeAssemblyName"

    # ----- About to register ServiceType
    Write-verbose "**** COPYING DLL for: $SERVICETYPEDISPLAYNAME"
    ###if (!(Test-Path -path $assembliesTargetPath)) {New-Item $assembliesTargetPath -Type Directory}
    If($assembliesSourcePath -eq "")
	{
		write-debug "set to not copy assemblies."
	}
    elseif($assembliesSourcePath.EndsWith("\*"))
    {
        #Do nothing this is the prefered format
    }
    elseif($assembliesSourcePath.EndsWith("\"))
    {
        $assembliesSourcePath="$assembliesSourcePath*"
    }
    else ###(!$assembliesSourcePath.EndsWith("\"))
    {
        $assembliesSourcePath="$assembliesSourcePath\*"
    }
    If($assembliesSourcePath -ne "")
    {
        write-debug "Copy-Files $assembliesSourcePath $assembliesTargetPath $true $true $true"
        Copy-Files $assembliesSourcePath $assembliesTargetPath $true $true $false -verbose ###-debug
    }
	
	if ($CopyOnly)
	{
		Write-Debug "Only set to copy files"
		
	}
	else
	{
	    Write-Verbose "**** ABOUT TO REGISTER SERVICE TYPE"
		
			
	    write-debug "& $NetFrameworkPath\MSBUILD $MSBUILDCONFIG /p:K2SERVER=$K2SERVER /p:K2HostServerPort=$K2HOSTSERVERPORT /p:ServiceTypeGuid=$SERVICETYPEGUID /p:ServiceTypeSystemName=$SERVICETYPESYSTEMNAME /p:ServiceTypeDisplayName=$SERVICETYPEDISPLAYNAME /p:ServiceTypeDescription=$SERVICETYPEDESCRIPTION /p:ServiceTypeAssemblyPath=$AssemblyTargetFullPath /p:ServiceTypeClassName=$SERVICETYPECLASSNAME "
	    $OutPut = & $NetFrameworkPath\MSBUILD $MSBUILDCONFIG /p:K2SERVER=$K2SERVER /p:K2HostServerPort=$K2HOSTSERVERPORT /p:ServiceTypeGuid=$SERVICETYPEGUID /p:ServiceTypeSystemName=$SERVICETYPESYSTEMNAME /p:ServiceTypeDisplayName=$SERVICETYPEDISPLAYNAME /p:ServiceTypeDescription=$SERVICETYPEDESCRIPTION /p:ServiceTypeAssemblyPath=$AssemblyTargetFullPath /p:ServiceTypeClassName=$SERVICETYPECLASSNAME
	    $OutPut = [string]::join("`n", $OutPut)
		write-debug "finished"
	    If ($OutPut.Contains("0 Error(s)"))
	    {
			write-debug "deploy succeeded"
			$OutPut = " Msbuild reports that the service Type $SERVICETYPEDISPLAYNAME Deployed successfully $OutPut"
	        
	        $colour="Green"
	        If (!($OutPut.Contains("0 Warning(s)")))
	        {
				Write-warning "***With Warnings: $OutPut"
	        }
			else
			{
				Write-Verbose "$OutPut" 
			}
	    }
	    else
	    {
			write-debug "deploy failed"
			$message="There was an error deploying the service Type '$SERVICETYPEDISPLAYNAME': $OutPut"
	        Throw $message
	    }
	}
    Write-Debug "**Publish-K2ServiceType() - Finished"
}

Function Publish-K2ServiceInstance
{
<#
   .Synopsis
    This function deploys a service instance via msbuild and a custom deployment project according to parameters
   .Description
    This function deploys a service instance according to the following parameters
   .Example
        Publish-K2ServiceInstance "c:\WINDOWS\Microsoft.NET\Framework64\v3.5"  "DLX" 5555 "900a3faf-8765-4a32-8a1d-b02008e06003"  "8e7610de-76ae-433e-9efa-eddcdd12848f" systemName displayName description "true" "SqlConnectionString|SmartObjectConnectionString" "Data Source=dlx;Initial Catalog=K2ProcessData;Integrated Security=SSPI;|Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555;" "true|true" "|" 
   .Parameter $NetFrameworkPath
        Defaults to "c:\WINDOWS\Microsoft.NET\Framework64\v3.5",
   .Parameter $K2SERVER
        Defaults to "dlx"
   .Parameter          $K2HOSTSERVERPORT
        Defaults to 5555
   .Parameter          $SERVICETYPEGUID
        Required. This must match an existing service type guid
   .Parameter          $SERVICEINSTANCEGUID
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter          $SERVICEINSTANCESYSTEMNAME
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter          $SERVICEINSTANCEDISPLAYNAME
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter          $SERVICEINSTANCEDESCRIPTION
        Required. The value you would enter if Registering through the SmartObject service tester
   .Parameter          $CONFIGIMPERSONATE
        Required. The text 'true' or 'false', as if Registering through the SmartObject service tester
   .Parameter         $CONFIGKEYNAMES
        Required. A list of delimited names. These names should be identical to the names you are asked
        to provide when Registering through the SmartObject service tester.
   .Parameter          $CONFIGKEYVALUES
        Required. A list of delimited values. These valuess should be identical to the values you provide 
        when Registering through the SmartObject service tester.
    .Parameter         $CONFIGKEYSREQUIRED
        Required. Usually true|true. These boolean should be the same as the values that are reported against 
        each name when Registering through the SmartObject service tester.
    .Parameter 
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()] 
    Param(  [string]$NetFrameworkPath="c:\WINDOWS\Microsoft.NET\Framework64\v3.5",
   	    [parameter(Mandatory=$true)] [string]$MSBUILDCONFIG, 
            [string]$K2SERVER="dlx", 
            [int]$K2HOSTSERVERPORT=5555,
            [parameter(Mandatory=$true)] [string]$SERVICETYPEGUID,
            [parameter(Mandatory=$true)] [string]$SERVICEINSTANCEGUID,
            [parameter(Mandatory=$true)] [string]$SERVICEINSTANCESYSTEMNAME,
            [parameter(Mandatory=$true)] [string]$SERVICEINSTANCEDISPLAYNAME,
            [parameter(Mandatory=$true)] [string]$SERVICEINSTANCEDESCRIPTION,
            [parameter(Mandatory=$true)] [string]$CONFIGIMPERSONATE,
            [parameter(Mandatory=$true)] [string]$CONFIGKEYNAMES,
            [parameter(Mandatory=$true)] [string]$CONFIGKEYVALUES,
            [parameter(Mandatory=$true)] [string]$CONFIGKEYSREQUIRED, 
            [string]$CONFIGKEYDELIMITER="|")

    
    Write-Debug "**Publish-K2ServiceInstance() - Start"
   $CONFIGKEYVALUES=$CONFIGKEYVALUES.Replace("=", "{[equals]}" ).Replace(";","{[semicolon]}")
                 
    Write-Verbose "** ABOUT TO REGISTER SERVICEINSTANCE"
    Write-Debug "$NetFrameworkPath\MSBUILD $MSBUILDCONFIG /p:K2SERVER=$K2SERVER /p:K2HostServerPort=$K2HOSTSERVERPORT /p:ServiceTypeGuid=$SERVICETYPEGUID /p:ServiceInstanceGuid=$SERVICEINSTANCEGUID /p:ServiceInstanceSystemName=$SERVICEINSTANCESYSTEMNAME /p:ServiceInstanceDisplayName=$SERVICEINSTANCEDISPLAYNAME /p:ServiceInstanceDescription=$SERVICEINSTANCEDESCRIPTION /p:ConfigImpersonate=$CONFIGIMPERSONATE /p:ConfigKeysRequired=$CONFIGKEYSREQUIRED /p:ConfigKeyNames=$CONFIGKEYNAMES  /p:ConfigKeyValues=$CONFIGKEYVALUES  /p:ConfigKeyDelimiter=$CONFIGKEYDELIMITER  "
    $OutPut = & $NetFrameworkPath\MSBUILD $MSBUILDCONFIG /p:K2SERVER=$K2SERVER /p:K2HostServerPort=$K2HOSTSERVERPORT /p:ServiceTypeGuid=$SERVICETYPEGUID /p:ServiceInstanceGuid=$SERVICEINSTANCEGUID /p:ServiceInstanceSystemName=$SERVICEINSTANCESYSTEMNAME /p:ServiceInstanceDisplayName=$SERVICEINSTANCEDISPLAYNAME /p:ServiceInstanceDescription=$SERVICEINSTANCEDESCRIPTION /p:ConfigImpersonate=$CONFIGIMPERSONATE /p:ConfigKeysRequired=$CONFIGKEYSREQUIRED /p:ConfigKeyNames=$CONFIGKEYNAMES  /p:ConfigKeyValues=$CONFIGKEYVALUES  /p:ConfigKeyDelimiter=$CONFIGKEYDELIMITER  
    $OutPut = [string]::join("`n", $OutPut)
	
	write-debug "**finished registering service instance"
    If ($OutPut.Contains("0 Error(s)"))
    {
		write-debug "deploy succeeded"
		$OutPut = " Msbuild reports that the service Instance '$SERVICEINSTANCEDISPLAYNAME' Deployed successfully: $OutPut"
        
        If (!($OutPut.Contains("0 Warning(s)")))
        {
			Write-warning "***With Warnings: $OutPut"
        }
		else
		{
			Write-Verbose "$OutPut" 
		}
    }
    else
    {
		write-debug "deploy failed"
		$message="There was an error deploying the service Instance '$SERVICEINSTANCEDISPLAYNAME': $OutPut"
        Throw $message
    }
    Write-Debug "**Publish-K2ServiceInstance() - Finished"
}

Function Publish-K2SMOsFromServiceInstance
{
<#
   .Synopsis
    This function Publish-K2SMOsFromServiceInstance k2 server according to parameters
   .Description
    This function Publish-K2SMOsFromServiceInstance k2 wf server according to parameters.
   .Example
        Publish-K2SMOsFromServiceInstance "DLX" 5555
   .Parameter $k2con
   	    Required the instansiated but not open connection 
   .Parameter $k2Host
        Defaults to "localhost"
   .Parameter  $k2WorkflowPort
        Defaults to 5252
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param([parameter(Mandatory=$true)] [Guid]$ServiceTypeGUID,
		[parameter(Mandatory=$true)] [Guid]$ServiceInstanceGUID,
	$k2Host="localhost",
	$k2SMOManagementPort=5555,
	[bool]$forceOverwriteExistingSMOs=$true,
	[bool]$determinGUIDFromName=$true
)

Write-debug "** Publish-K2SMOsFromServiceInstance()"
write-verbose "Publishing K2 SMOs From Service Instance- This may take a while to register assemblies"
Write-debug "** SourceCode.SmartObjects.Authoring"
[Reflection.Assembly]::LoadWithPartialName(“SourceCode.SmartObjects.Authoring”) | out-null



###	[SourceCode.SmartObjects.Management.SmartObjectManagementServer]$SmartObjectManagementServer = New-Object SourceCode.SmartObjects.Management.SmartObjectManagementServer
	###Open-K2SMOManagementConnectionThrowError -$k2SMOServer $SmartObjectManagementServer -k2Host $k2Host -k2SMOManagementPort $k2SMOManagementPort
	
	###Write-Debug "SmartObjectManagementServer"
	###[SourceCode.SmartObjects.Management.SmartObjectManagementServer]$SmartObjectManagementServer= New-Object SourceCode.SmartObjects.Management.SmartObjectManagementServer

	###Write-Debug "Creating the connection"
	###$SmartObjectManagementServer.CreateConnection();
	
	###Write-Debug "Opening the connection"
	###$SmartObjectManagementServer.Connection.Open("Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2SMOManagementPort");


	$SmartObjectManagementServer = Get-K2SMOManagementConnectionThrowError $k2Host $k2SMOManagementPort
	#Wierd powershell behaviour when returning a overloaded class. It returns an array of which the item we need is the third element
	$IsConnected = $SmartObjectManagementServer[2].Connection.IsConnected
	Write-Debug	 "Is the SmartObjectManagementServer Connected? $IsConnected"
	
	[SourceCode.SmartObjects.Management.ServiceExplorerLevel]$ServiceExplorerLevelFull = [SourceCode.SmartObjects.Management.ServiceExplorerLevel]::Full
	Write-Debug "$ServiceExplorerLevelFull"
	
	
	[String]$ServiceExplorerXML = $SmartObjectManagementServer[2].GetServiceExplorer();

	Write-Debug "Creating service explorer"
    [SourceCode.SmartObjects.Authoring.ServiceExplorer]$serviceExplorer = [SourceCode.SmartObjects.Authoring.ServiceExplorer]::Create($ServiceExplorerXML);
	##ServiceExplorer serviceExplorer = ServiceExplorer.Create(this._smoManagementServer.GetServiceExplorer(ServiceExplorerLevel.Full));
	
	
	Write-Debug "Creating service type"
    [SourceCode.SmartObjects.Authoring.Service]$service = $serviceExplorer.Services[$ServiceTypeGUID];
	
	
	Write-Debug "Creating service Instance"
    [SourceCode.SmartObjects.Authoring.ServiceInstance]$serviceInstance = $service.ServiceInstances[$ServiceInstanceGUID];
    
	
	Write-Debug "looping through service objects"
    $serviceInstance.ServiceObjects | ForEach-Object {
	
		Write-Debug "$($_.DisplayName)"
        [SourceCode.SmartObjects.Authoring.SmartObjectDefinition]$smo = [SourceCode.SmartObjects.Authoring.SmartObjectDefinition]::Create($_);
		$smo.Guid = Get-DeterministicGUIDfromString "$($_.DisplayName)"
		$smo.Metadata.Guid = $smo.Guid;
        $smo.Name = [SourceCode.SmartObjects.Authoring.SmartObjectDefinition]::GetNameFromDisplay($_.Name);
        $smo.Metadata.DisplayName = $_.DisplayName;
		If ($forceOverwriteExistingSMOs)
		{
			Delete-SmartObject -SmartObjectManagementServer $SmartObjectManagementServer[2] -SmartObjectName $smo.Name
		}
        $SmartObjectManagementServer[2].PublishSmartObject($smo.ToSmartObjectDeployXml(), $service.DisplayName);
    }
	
	Write-Debug "End Publish-K2SMOsFromServiceInstance"
}

Function Publish-K2ServiceBrokers
{
	<#
   .Synopsis
    This function deploys a list of Service Types and Service Instances
   .Description
    This function deploys a list of Service Types and Service Instances as configured in an XML File.
    
	Sample XML File: TODO

    It uses the above functions to accomplish this TODO: dependencies.
   .Example
        TODO:
   .Example
        TODO:
		
   .Parameter     $NetFrameworkPath
        Defaults to the discovered global setting probably "c:\WINDOWS\Microsoft.NET\Framework64\v3.5"
   .Parameter $Environment
            The environment to deploy to. Uses the XML config to check k2 connection settings and also config sections for environment specific settings.
			If left empty it will prompt
   .Parameter $RestartK2Server
            Defaults to true. Normally needs restarting if files are to be copied
   .Parameter $RootFilePath
        Location of XML file and releative location of service assemblies will use this
	.ManifestFileName
		The name of the XML file including .xml extension
	.ServiceBrokerMsbuildSubDirectory
		The location of required msbuild project, which must be compiled and built first
   .ConsoleMode $ConsoleMode
        Set this to true if this the K2 server is a windows 7 dev machine
        Comes in useful as sometimes Service Broker dlls are in use by the server and sometimes they are not.
        If True it will also check if broker tools are running and prompt the user to shut them down
   .Parameter $CopyOnly
        Defaults to false. Use for load balance node. False on every node except the last one.
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
	#>
		[CmdletBinding()]
		Param(
		
		[parameter(Mandatory=$false)]  
		[string]$NetFrameworkPath=$Global_FrameworkPath35, 
		  
		[String] $Environment,
	 
		[bool]$RestartK2Server=$true,
		$RootFilePath="$null", 
		$ManifestFileName="$null", 
		$ManifestFileRootNode="EnvironmentMetaData",
		$ServiceBrokerMsbuildSubDirectory="..\K2Field.Utilities.ServiceObjectBuilder\MSBuild Folder",
		[Bool]$ConsoleMode=$false,
		[Bool]$prompt=$false,
		[Bool]$CopyOnly=$false
		)
		Write-Debug "Deploy Service Brokers"
		$CURRENTDIR=pwd
		###trap {write-host "error"+ $error[0].ToString() + $error[0].InvocationInfo.PositionMessage  -Foregroundcolor Red; cd "$CURRENTDIR"; read-host 'There has been an error'; break}

		###$ErrorActionPreference ="Stop"
		$ManifestFile="$RootFilePath$ManifestFileName"
		Write-Verbose "** Finding manifest file @ $ManifestFile"

		if($NetFrameworkPath -eq $null)
		{
			Write-Debug "passed in netframe path is null. adding global variable"
            Add-GlobalVariables
            $NetFrameworkPath=$Global_FrameworkPath35
		}
		elseif($NetFrameworkPath -eq "")
		{
			Write-Debug "passed in netframe path is empty. adding global variable"
            Add-GlobalVariables
            $NetFrameworkPath=$Global_FrameworkPath35
            
		}
		else
		{
			Write-Debug "passed in netframe path:  $NetFrameworkPath"
		}
        Write-Debug "NetFrameworkPath is now $NetFrameworkPath"

		If (test-path $ManifestFile) 
		{   
			Write-Verbose "** Manifest file found"
        
			$xml = [xml](get-content $ManifestFile)
			If(($Environment -eq $null) -or ($Environment -eq "") )
			{
        
				Write-Verbose "** No Environment passed in"
				"Environment not passed in, ask the user"
        
				$Environment=Get-EnvironmentFromUser($xml)
			}
			else
			{
				Write-Verbose "**Environment passed in = '$Environment'"
        
			}
        
			$K2SERVER= $xml.$ManifestFileRootNode.Environments.$Environment.K2Host
			$K2HOSTSERVERPORT= $xml.$ManifestFileRootNode.Environments.$Environment.K2HostPort
    
			write-verbose "** copying msbuild files to $Global_MsbuildPath"
			write-debug "Copy-Item $RootFilePath$ServiceBrokerMsbuildSubDirectory\* $Global_MsbuildPath -recurse -force"
			Copy-Item "$RootFilePath$ServiceBrokerMsbuildSubDirectory\*" $Global_MsbuildPath -recurse -force
			write-verbose "** finished copying msbuild files"
    
			If($RestartK2Server -eq $null)
			{
				$RestartK2Server=$true
				[bool]$prompt=$true
			}
			else
			{
				###[bool]$prompt=$false
			}
			if ($RestartK2Server)
			{
				write-debug "Restart-K2Server -WaitUntilRestart $true -Prompt $prompt -ConsoleMode $ConsoleMode"
				Restart-K2Server -WaitUntilRestart $true -Prompt $prompt -ConsoleMode $ConsoleMode
			}
		    
			$delimiter="|"

			@($xml.SelectSingleNode("//ServiceTypes").ChildNodes) | ForEach-Object {
				 write-verbose "Reading Service Type details:"
		 
				 write-debug "deploy:$($_.deploy)  sysname:$($_.systemName)    $($_.guid)    dname:$($_.displayName)   InnerText:$($_.InnerText)  assembly:$($_.assemliesSourcePath)"
				 If([System.Convert]::ToBoolean($_.deploy))
				 {
					$CopySource=$_.assemliesSourcePath;
					$CopySource="$RootFilePath$CopySource"
					if ($_.assembliesSourcePath -ne "")
					{
				
						write-verbose "copy the source from $CopySource"
					}
					else
					{

						write-verbose "DO NOT copy the source from $CopySource"
					}
					Write-verbose "** Deploying Service Type $_.displayName to $K2SERVER port $K2HOSTSERVERPORT"
					write-debug "running Publish-K2ServiceType $NetFrameworkPath $RootFilePath$ServiceBrokerMsbuildSubDirectory\RegisterServiceType.msbuild $K2SERVER $K2HOSTSERVERPORT $($_.guid) $($_.systemName) $($_.displayName) $($_.description) $($_.className) $CopySource $($_.assembliesTargetPath) $($_.serviceTypeAssemblyName) $CopyOnly"
					Publish-K2ServiceType $NetFrameworkPath "$RootFilePath$ServiceBrokerMsbuildSubDirectory\RegisterServiceType.msbuild" $K2SERVER $K2HOSTSERVERPORT $_.guid $_.systemName $_.displayName $_.description $_.className "$CopySource" $_.assembliesTargetPath $_.serviceTypeAssemblyName $CopyOnly
				 }
				 else
				 {
					Write-verbose "** Skipping Service Type   $($_.displayName) as it is configured not to deploy"
				 }
				 $ServiceTypeGUID=$_.guid
         		if ($CopyOnly)
				{
					Write-Debug "only copy dlls so skipping registration"
				}
				else
				{
					 $_.SelectNodes("ServiceInstance") | 
					 foreach { 
						#For every service instance Get the config name values pairs
						$ServiceInstanceKeyValues="";
						$ServiceInstanceKeyRequiredList="";
						$ServiceInstanceKeyNames="";
	            
						If([System.Convert]::ToBoolean($_.deploy))
						{
							write-debug "** Getting Config values for  $($_.systemName)"
	                
							$_.SelectSingleNode("Environment[@name='$Environment']").Config| 
							 foreach { 
								write-debug "Config: $($_.Name) Value:  $($_.value)"
								$ServiceInstanceKeyValue=$_.value
								$ServiceInstanceKeyRequired=$_.keyRequired
								$ServiceInstanceKeyName=$_.name
								write-debug "** Found Config values for $ServiceInstanceKeyName value is $ServiceInstanceKeyValue"
								$ServiceInstanceKeyValues="$ServiceInstanceKeyValues$delimiter$ServiceInstanceKeyValue";
								$ServiceInstanceKeyRequiredList="$ServiceInstanceKeyRequiredList$delimiter$ServiceInstanceKeyRequired";
								$ServiceInstanceKeyNames="$ServiceInstanceKeyNames$delimiter$ServiceInstanceKeyName";
	                    
							 }#end loop config namevalues
	                 
							 $ServiceInstanceKeyValues=$ServiceInstanceKeyValues.Replace("{BlackPearlDir}", "$Global_K2BlackPearlDir")
							 $ServiceInstanceKeyValues=$ServiceInstanceKeyValues.TrimStart($delimiter);
							 $ServiceInstanceKeyRequiredList=$ServiceInstanceKeyRequiredList.TrimStart($delimiter);
							 $ServiceInstanceKeyNames=$ServiceInstanceKeyNames.TrimStart($delimiter);
							 write-debug "ServiceInstanceKeyRequired: $ServiceInstanceKeyRequiredList ListOfNames: $ServiceInstanceKeyNames"
	                 
					 		########################
							########################
							 Write-Verbose "* Deploying Service Instance  $($_.displayName)"
							 ###Param(                        $K2SERVER $K2HOSTSERVERPORT  $SERVICETYPEGUID, $SERVICEINSTANCEGUID,$SERVICEINSTANCESYSTEMNAME,$SERVICEINSTANCEDISPLAYNAME,$SERVICEINSTANCEDESCRIPTION, $CONFIGIMPERSONATE,$CONFIGKEYNAMES,$CONFIGKEYVALUES,                               $CONFIGKEYSREQUIRED)
							 write-debug "Publish-K2ServiceInstance    $NetFrameworkPath  $RootFilePath$ServiceBrokerMsbuildSubDirectory\RegisterServiceInstance.msbuild $K2SERVER $K2HOSTSERVERPORT $ServiceTypeGUID  $($_.guid)                  $($_.systemName)         $($_.displayName)               $($_.description)               true $ServiceInstanceKeyNames $ServiceInstanceKeyValues $ServiceInstanceKeyRequiredList $delimiter"
							 Publish-K2ServiceInstance    $NetFrameworkPath  "$RootFilePath$ServiceBrokerMsbuildSubDirectory\RegisterServiceInstance.msbuild" $K2SERVER $K2HOSTSERVERPORT $ServiceTypeGUID      $_.guid                  $_.systemName         $_.displayName               $_.description               $_.impersonate $ServiceInstanceKeyNames $ServiceInstanceKeyValues $ServiceInstanceKeyRequiredList $delimiter
							 If([System.Convert]::ToBoolean($_.deploySMO))
							{
								Publish-K2SMOsFromServiceInstance $ServiceTypeGUID $_.guid $K2SERVER $K2HOSTSERVERPORT
							}
							 #######################
							 #######################
						 }
						 else
						 {
							write-verbose "** Skipping Service Instance $($_.systemName) as it is configured not to deploy"
						 }   #If Deploy
					 }   #endloop Service Instance
				} #end if not copy only
			}   #endloop Service Type
		}
		else
		{
			Throw "You must have a ServiceBroker Manifest XML file at $ManifestFile"
		}
	}
	
Function Update-K2ServiceInstance
{
<#
   .Synopsis
    This function refreshes the specified Service Instance
   .Description
    This function refreshes the specified Service Instance. 
   .Example
        Update-K2ServiceInstance "cae95540-aed0-465a-8879-63ca26dbfbb7"    
   .Parameter $serviceGuid
        Guid of the service
   .Parameter  $serviceInstanceServer
        ServiceManagementServer to utilise
   .Notes
		AUTHOR: Paul Kelly, K2
		Requires -Version 2.0
#>  
	[CmdletBinding()]
	Param (
		[Parameter(Position=0)][guid]$serviceGuid,
		[Parameter(Position=1)][string]$k2Server = "localhost",
		[Parameter(Position=2)][string]$k2ServerPort = 5555
	)	
	Begin
	{
		[Reflection.Assembly]::LoadWithPartialName("SourceCode.SmartObjects.Services.Management") | Out-Null
		$serviceInstanceServer = Open-K2SMOServiceManagementConnectionThrowError $k2Server $k2ServerPort
	}
	Process
	{
		$stop = $false
		$retries = 0	
		Write-Host "Refreshing service $serviceGuid"	
		do {
			try {
				$serviceInstanceServer[2].RefreshServiceInstance($serviceGuid) | Out-Null
				Write-Verbose "Refresh complete"
				$stop = $true
			}     
			catch {			
				if ($retries -gt 1)
				{
					Write-Error "Could not refresh after 2 retries."
					$stop = $true
				}
				else
				{
					Write-Warning "Refresh failed, trying again"
					$retries++
				}
			}		
		}
		while ($stop -eq $false)	
	}	
	End 
	{
		$serviceInstanceServer[2].Connection.Close()
	}	
}

#Automation of Permissions
Function New-K2PermissionsDataTable
{
<#
   .Synopsis
    This is a private function used by the EnvLib functions
   .Description
    This function prepares and returns a datatable containing permissions
	.Example
        New-K2PermissionsDataTable
    .Parameter $objectMappingNames
        Required.
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding()]
 	Param($objectMappingNames)
	
			
	$dtActions = New-Object System.Data.DataTable ####| out-null
    $dtActions.Columns.Add("UsersGroups") | out-null;
    foreach ($kvp in $objectMappingNames.Keys)
    {
        $dtActions.Columns.Add($kvp, [System.Type]::GetType("System.Boolean")) | out-null;
    }
    $dtActions.Columns.Add("Type", [System.Type]::GetType("System.String")) | out-null;
	###Powershell does some interesting automatic unrolling of collections that implement 
	###IEnumerable. The comma operator will wrap your table in a single-object array,
	###so when it gets automatically unrolled it will return back to the table. 
	###http://stackoverflow.com/questions/11562634/powershell-returning-data-tables-without-rows-in-functions
    return ,$dtActions
}

Function New-K2SmartObjectPermissionsDataTable 
{
<#
   .Synopsis
    This is a private function used by the SmO functions
   .Description
    This function prepares and returns a datatable containing permissions
	.Example
        New-K2SmartObjectPermissionsDataTable 
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding()]
	Param()

	#Proper way to do this is to make a connection to the SmartObject management server and execture the GetSystemActions method
	#this is what the workspace does
	#however all this does is generate a Dictionary<String, String> with publish and deploy KVPs
	#tradeoff decision is just to build this manually and cut down the number of connections/parameters
	#Given that we are coding both publish and delete permissions and will need to refactor anyway if the API changes/extra permissions are added
	$systemActions = New-Object 'System.Collections.Generic.Dictionary[String,String]' 
    $systemActions.Add("publish", "Publish SmartObject") | out-null
    $systemActions.Add("delete", "Delete SmartObject") | out-null
	
	$dtK2SmOPermissions = New-K2PermissionsDataTable -objectMappingNames $systemActions
	
	###Powershell does some interesting automatic unrolling of collections that implement 
	###IEnumerable. The comma operator will wrap your table in a single-object array,
	###so when it gets automatically unrolled it will return back to the table. 
	###http://stackoverflow.com/questions/11562634/powershell-returning-data-tables-without-rows-in-functions
    return ,$dtK2SmOPermissions
}

function Set-K2ServerPermissions
{
<#
   .Synopsis
    This function updates and adds K2 permissions from an xml structure
   .Description
     This function updates and adds K2 permissions from a structure that looks like the following.
    <Users><User admin='true' canimpersonate='true' export='true' >DENALLIX\Administrator</User><User admin='true' canimpersonate='true' export='true' >DENALLIX\mike</User></Users>
	Sample XML schema: TODO
	
    It uses the above functions to accomplish this TODO: dependencies.
   .Example
        Set-K2ServerPermissions "localhost" 5555 "<Users><User admin='true' canimpersonate='true' export='true' >DENALLIX\Administrator</User><User admin='true' canimpersonate='true' export='true' >DENALLIX\mike</User></Users>" -verbose ###-debug
   .Parameter $k2host
            The name of the K2 host server
   .Parameter $k2HostPort
            Defaults to true. Normally needs restarting if files are to be copied
   .Parameter $PermissionSet
        XML looking like the structure above
	.Parameter $ignoreLabel    
        Defaults to the true. When true, this assumes that K2: is the only Security label and will strip any other labels off.
		Use this when your xml file users do not contain a security label
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
	#>
	[CmdletBinding()]
 	Param([string]$k2host="localhost",
    [int]$k2HostPort=5555,  
    [xml]$PermissionSet,
    [bool]$ignoreLabel=$true
    )
	 [Reflection.Assembly]::LoadWithPartialName(“SourceCode.Workflow.Management”) | out-null
    
	 ##TODO: Horrible hack to search ignoring case!
	 [string]$permissionsetstring=$PermissionSet.InnerXml.ToString().ToLower()
	 $PermissionSet=$permissionsetstring
	 $conn = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2HostPort"
	 
	 $managementServer = New-Object SourceCode.Workflow.Management.WorkflowManagementServer
	 $managementServer.CreateConnection() | Out-Null
	 $managementServer.Connection.Open($conn) | Out-Null
	  
	 $adminPermissions = $managementServer.GetAdminPermissions()
	 $newAdminPermissions = New-Object SourceCode.Workflow.Management.AdminPermissions
	 
	 
	 #To add permissions we must first get the existing permissions
	 #We then search the existing permissions and see if it matches a node in the XML
	 #If it matches we do nothing, as we will add all the new and existing xml nodes in below
	 #if it doesn't match we add the permission to the permissions collection
	 $adminPermissions | 
 	foreach {
		$currentExistingUser =  $_.UserName.ToLower()
		Write-Debug "Found existing permission for $currentExistingUser"

		if ($ignoreLabel -eq $true)
		{ #If script is set to ignore the security label, then strip it off
			$pos = $currentExistingUser.IndexOf(":")
			$currentExistingUser = $currentExistingUser.Substring($pos+1)
			Write-Debug "Stripped off label : $currentExistingUser"
		}

		$nodeList = $PermissionSet.SelectNodes("//text()[contains(.,'$currentExistingUser')]");
		if ($nodeList.Count -gt 0)
		{
			Write-Verbose "Found user $currentExistingUser in new xml permission set. Not adding them in, as they will be added below"
		}
		else
		{
			Write-Verbose "Could not find user $currentExistingUser in new xml permission set, so Adding them back in"

			$newAdminPermissions.Add($_)
		}
	}
	
	#Now add All new and existing users in the XML
	$nodelist = $PermissionSet.selectnodes("/users/user") # XPath is case sensitive
	foreach ($user in $nodelist)
	{
		$adminPermission = New-Object SourceCode.Workflow.Management.AdminPermission  
		[string]$currentUser = $user.InnerText
		Write-Debug "current new user: $currentUser"
		$adminPermission.UserName = $currentUser
		$adminPermission.Admin = [System.Convert]::ToBoolean($user.GetAttribute("admin"))
		$adminPermission.CanImpersonate = [System.Convert]::ToBoolean($user.GetAttribute("canimpersonate"))
		$adminPermission.Export = [System.Convert]::ToBoolean($user.GetAttribute("export"))
		Write-Verbose "Adding in user $currentUser"
		$newAdminPermissions.Add($adminPermission)    
	}    

	$rightsSet = $managementServer.UpdateAdminUsers($newAdminPermissions) 
	$managementServer.Connection.Dispose()
	Write-Verbose "Server rights set: $rightsSet"
}

Function Set-K2SharePointRestrictedWizards
{
<#
   .Synopsis
    This function Set-K2SharePointRestrictedWizards from the k2 server according to parameters
   .Description
    This function Set-K2SharePointRestrictedWizards according to parameters. It replicates the _layouts/K2/ManageRestrictedWizards.aspx functionality
   .Example
        Set-K2SharePointRestrictedWizards "<Save><Users><User name='K2:Domain\Username1'/><User name='K2:Domain\Username2'/></Users><Wizards><Wizard id='64'/></Wizards></Save>" "Data Source=localhost;Initial Catalog=K2WebDesigner;integrated security=sspi;Pooling=True" 
		Set-K2SharePointRestrictedWizards "<Save><Wizards><Wizard id='7'/></Wizards></Save>" "Data Source=localhost;Initial Catalog=K2WebDesigner;integrated security=sspi;Pooling=True" 
   .Parameter $saveData
   	    Required XML in the format
		<Save> 
			<Users> 
				<User name="K2:Domain\Username1"/> 
				<User name="K2:Domain\Username2"/> 
			</Users> 
			<Wizards> 
				<Wizard id="64"/> 
				<Wizard id="69"/> 
				<Wizard id="48"/> 
			</Wizards> 
		</Save> 

   .Parameter $SQLconnectionString
        Connection string to the K2 Database containing ProcessSaveEventRestrictions stored procedure
		either K2 or K2WebDesigner
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
   [CmdletBinding()]
Param(	[Parameter(Mandatory=$true)][xml]$saveData,
	[Parameter(Mandatory=$true)][string]$SQLconnectionString
)

Write-debug "** Set-K2SharePointRestrictedWizards()"

	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.WebDesigner.Framework”) | out-null
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.WebDesigner.Framework.SharePoint”) | out-null
	$framework = New-Object SourceCode.WebDesigner.Framework.SharePoint.Methods
	[string] $errorMessage = $framework.SaveWizardRestrictions($saveData.OuterXML, $SQLconnectionString);
	Write-Debug "ErrorMessage = '$errorMessage'"
	if ($errorMessage.Length -ne 0)
	{
		Write-Error $errorMessage
	}
}

Function Set-K2EnvironmentLibraryPermission
{
<#
   .Synopsis
    This function sets a single permission to an Environment library or Environment Library template depending on parameters
   .Description
    This function sets a single permission to an Environment library or Environment Library template depending on parameters
	If $TemplateEnvironmentID is provided it will attempt to find a Template or Environment Id that matches
	TODO: I have not tested what happens if it is not found
	Otherwise
	If both TemplateName and EnvironmentName are provided it will attempt to set permission
	on the Environment and will error if either names are not found
	If Only TemplateName is provided then it will attempt to set permissions on the template
	It will error if the template name is not found
	.Example
        
		#Give the administrators AD group read permission on Default Production environment
		Set-K2EnvironmentLibraryPermission -TemplateName "Default Template" -EnvironmentName "Production" -UserOrGroup "Group" -PermissionType "read" -UserOrGroupName "K2:DENALLIX\Administrators"
		
		
		#Remove Mike's permission on Default Production environment
		Set-K2EnvironmentLibraryPermission -TemplateName "Default Template" -EnvironmentName "Production" -UserOrGroup "User" -PermissionType "none" -UserOrGroupName "K2:DENALLIX\Mike"
		
		#Give the administrators AD group read permission on Default Template
		Set-K2EnvironmentLibraryPermissionTest -TemplateName "Default Template" -UserOrGroup "Group" -PermissionType "read" -UserOrGroupName "K2:DENALLIX\Administrators"
		
		#For when you aleady have the EnvironmentID 
		Set-K2EnvironmentLibraryPermission -$TemplateEnvironmentID "1BDA9DED-B8F9-404D-A8D9-801A195D16F9" -UserOrGroup "Group" -PermissionType "modify" -UserOrGroupName "K2:DENALLIX\Administrators"
		Set-K2EnvironmentLibraryPermission -$TemplateEnvironmentID "1BDA9DED-B8F9-404D-A8D9-801A195D16F9" -UserOrGroup "User" -PermissionType "modify" -UserOrGroupName "K2:DENALLIX\Anthony"

    .Parameter $TemplateEnvironmentID
        Required, if TemplateName and EnvironmentName are not provided.
		The ID of the environment to set permissions (if not know use following parameters)
    .Parameter $TemplateName
        Required, if $TemplateEnvironmentID is not provided.
    .Parameter $EnvironmentName
        Not Required. if this and  $TemplateEnvironmentID are not provided, it will add permissions at the template level
    .Parameter $ConnectionString
        If not provided it defaults to "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
    .Parameter $environmentManagementServer
        If not provided it is created by connecting using ConnectionString
    .Parameter $UserOrGroup
        Required. Must be either "User" or "Group". case sensitive.
    .Parameter $UserOrGroupName
        Required. The fully qualified name of the user or group. It must include the securtity label
    .Parameter $PermissionType
        Required. Must be either "read", "modify" or "none". "none" will remove. "modify" will also give "read". case sensitive.
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="TemplateEnvironmentNameSet")]
	Param(
	[Parameter(ParameterSetName="TemplateEnvironmentIdSet", Mandatory=$true, Position=0)][string]$TemplateEnvironmentID,
	[Parameter(ParameterSetName="TemplateEnvironmentNameSet", Mandatory=$true, Position=0)]$TemplateName,
	[Parameter(ParameterSetName="TemplateEnvironmentNameSet", Mandatory=$false, Position=1)]$EnvironmentName,	
	[Parameter(Mandatory=$false)][string]$ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(Mandatory=$false)]$environmentManagementServer=$null,
	[Parameter(Mandatory=$false)]$environmentSettingsManager=$null,
	[Parameter(Mandatory=$true)][ValidateSet('User','Group')][System.String]$UserOrGroup,
	[Parameter(Mandatory=$true)][System.String]$UserOrGroupName,
	[Parameter(Mandatory=$true)][ValidateSet('read','modify',"none")][System.String]$PermissionType)

	if ($environmentManagementServer -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentLibrary.Management”) | out-null
		$environmentManagementServer = New-Object SourceCode.EnvironmentLibrary.Management.EnvironmentLibraryManagementServer "$ConnectionString", $true
	}

	if ($TemplateEnvironmentID -eq $null)
	{
		if ($environmentSettingsManager -eq $null)
		{
			[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
			$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
		
			$environmentSettingsManager.ConnectToServer($ConnectionString) | out-null;
	    	$environmentSettingsManager.InitializeSettingsManager() | out-null;
	    	$environmentSettingsManager.Disconnect() | out-null;
		}
		if ($environmentSettingsManager.EnvironmentTemplates["$TemplateName"] -eq $null)
		{
			Write-Error("Template name provided '$TemplateName' does not exist on this server")
		}
		
		$CurrentEnvironmentTemplate = $environmentSettingsManager.EnvironmentTemplates["$TemplateName"]		
			
		if ($EnvironmentName -eq $null)
		{
			$TemplateEnvironmentID = $CurrentEnvironmentTemplate.TemplateId
		}
		else
		{
			if ($CurrentEnvironmentTemplate.Environments["$EnvironmentName"] -eq $null)
			{
				Write-Error("Environemt name provided '$EnvironmentName' does not exist on the Template '$TemplateName' ")
			}
			$TemplateEnvironmentID = $CurrentEnvironmentTemplate.Environments["$EnvironmentName"].EnvironmentID
		}
	}
	$objectMappingNames = $environmentManagementServer.GetObjectManagementNames();
	$dtK2EnvLibPermissions = New-K2PermissionsDataTable -objectMappingNames $objectMappingNames
				
	if($UserOrGroup -eq "User")
	{
	
		[System.Data.DataRow]$newUserRow = $dtK2EnvLibPermissions.NewRow();
		$newUserRow["UsersGroups"] = "$UserOrGroupName";
		$newUserRow["ObjectAction_ReadOnly"] = (("$PermissionType" -eq "read") -or ("$PermissionType" -eq "modify"));
		$newUserRow["ObjectAction_Modify"] = ("$PermissionType" -eq "modify");
		$newUserRow["Type"] = $UserOrGroup
		$dtK2EnvLibPermissions.Rows.Add($newUserRow);
		
		$environmentManagementServer.SaveObjectUserMappings($dtK2EnvLibPermissions, $TemplateEnvironmentID) | Out-Null;
		
	}
	else
	{
		$TemplateRoleMappings = $environmentManagementServer.GetObjectRoleMappings($dtK2EnvLibPermissions, $TemplateEnvironmentID);
		$TemplateRoleMappings.Rows.Clear();
		[System.Data.DataRow]$newGroupRow = $TemplateRoleMappings.NewRow();
		$newGroupRow["UsersGroups"] = "$UserOrGroupName";
		$newGroupRow["ObjectAction_ReadOnly"] = (("$PermissionType" -eq "read") -or ("$PermissionType" -eq "modify"));
		$newGroupRow["ObjectAction_Modify"] = ("$PermissionType" -eq "modify");
		$TemplateRoleMappings.Rows.Add($newGroupRow);
		
		$environmentManagementServer.SaveObjectRoleMappings($TemplateRoleMappings, $TemplateEnvironmentID) | Out-Null;
	}
}

Function Get-K2EnvironmentLibraryPermission
{
<#
   .Synopsis
    This function gets a single permission to an Environment library or Environment Library template depending on parameters
   .Description
    This function gets a single permission to an Environment library or Environment Library template depending on parameters
	If $TemplateEnvironmentID is provided it will attempt to find a Template or Environment Id that matches
	TODO: I have not tested what happens if it is not found
	Otherwise
	If both TemplateName and EnvironmentName are provided it will attempt to get permission
	on the Environment and will error if either names are not found
	If Only TemplateName is provided then it will attempt to get permissions on the template
	It will error if the template name is not found
	
	Return values
    one of "read", "modify" or "none". "none" means no rights. . case sensitive.
	
	.Example
        
		#Give the administrators AD group read permission on Default Production environment
		Set-K2EnvironmentLibraryPermission -TemplateName "Default Template" -EnvironmentName "Production" -UserOrGroup "Group" -PermissionType "read" -UserOrGroupName "K2:DENALLIX\Administrators"
		
		
		#Remove Mike's permission on Default Production environment
		Set-K2EnvironmentLibraryPermission -TemplateName "Default Template" -EnvironmentName "Production" -UserOrGroup "User" -PermissionType "none" -UserOrGroupName "K2:DENALLIX\Mike"
		
		#Give the administrators AD group read permission on Default Template
		Set-K2EnvironmentLibraryPermissionTest -TemplateName "Default Template" -UserOrGroup "Group" -PermissionType "read" -UserOrGroupName "K2:DENALLIX\Administrators"
		
		#For when you aleady have the EnvironmentID 
		Set-K2EnvironmentLibraryPermission -$TemplateEnvironmentID "1BDA9DED-B8F9-404D-A8D9-801A195D16F9" -UserOrGroup "Group" -PermissionType "modify" -UserOrGroupName "K2:DENALLIX\Administrators"
		Set-K2EnvironmentLibraryPermission -$TemplateEnvironmentID "1BDA9DED-B8F9-404D-A8D9-801A195D16F9" -UserOrGroup "User" -PermissionType "modify" -UserOrGroupName "K2:DENALLIX\Anthony"

    .Parameter $TemplateEnvironmentID
        Required, if TemplateName and EnvironmentName are not provided.
		The ID of the environment to set permissions (if not know use following parameters)
    .Parameter $TemplateName
        Required, if $TemplateEnvironmentID is not provided.
    .Parameter $EnvironmentName
        Not Required. if this and  $TemplateEnvironmentID are not provided, it will add permissions at the template level
    .Parameter $ConnectionString
        If not provided it defaults to "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
    .Parameter $environmentManagementServer
        If not provided it is created by connecting using ConnectionString
    .Parameter $UserOrGroupName
        Required. The fully qualified name of the user or group to locate. It must include the securtity label
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="TemplateEnvironmentNameSet")]
	Param(
	[Parameter(ParameterSetName="TemplateEnvironmentIdSet", Mandatory=$true, Position=0)][string]$TemplateEnvironmentID,
	[Parameter(ParameterSetName="TemplateEnvironmentNameSet", Mandatory=$true, Position=0)]$TemplateName,
	[Parameter(ParameterSetName="TemplateEnvironmentNameSet", Mandatory=$false, Position=1)]$EnvironmentName,	
	[Parameter(Mandatory=$false)][string]$ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(Mandatory=$false)]$environmentManagementServer=$null,
	[Parameter(Mandatory=$false)]$environmentSettingsManager=$null,
	[Parameter(Mandatory=$true)][System.String]$UserOrGroupName
	)
	if ($environmentManagementServer -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentLibrary.Management”) | out-null
		$environmentManagementServer = New-Object SourceCode.EnvironmentLibrary.Management.EnvironmentLibraryManagementServer "$ConnectionString", $true
	}

	if ($TemplateEnvironmentID -eq $null)
	{
		if ($environmentSettingsManager -eq $null)
		{
			[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
			$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
		
			$environmentSettingsManager.ConnectToServer($ConnectionString) | out-null;
	    	$environmentSettingsManager.InitializeSettingsManager() | out-null;
	    	$environmentSettingsManager.Disconnect() | out-null;
		}
		if ($environmentSettingsManager.EnvironmentTemplates["$TemplateName"] -eq $null)
		{
			Write-Error("Template name provided '$TemplateName' does not exist on this server")
		}
		
		$CurrentEnvironmentTemplate = $environmentSettingsManager.EnvironmentTemplates["$TemplateName"]		
			
		if ($EnvironmentName -eq $null)
		{
			$TemplateEnvironmentID = $CurrentEnvironmentTemplate.TemplateId
		}
		else
		{
			if ($CurrentEnvironmentTemplate.Environments["$EnvironmentName"] -eq $null)
			{
				Write-Error("Environemt name provided '$EnvironmentName' does not exist on the Template '$TemplateName' ")
			}
			$TemplateEnvironmentID = $CurrentEnvironmentTemplate.Environments["$EnvironmentName"].EnvironmentID
		}
	}
	$objectMappingNames = $environmentManagementServer.GetObjectManagementNames();
	$dtK2EnvLibPermissions = New-K2PermissionsDataTable -objectMappingNames $objectMappingNames
		
	#[Parameter(Mandatory=$true)][ValidateSet('read','modify',"none")][System.String]$PermissionType)
	$dtNewK2EnvLibPermissions = $environmentManagementServer.GetObjectUserMappings($dtK2EnvLibPermissions, $TemplateEnvironmentID)
	$containsUserOrGroup = $dtNewK2EnvLibPermissions.Select("UsersGroups = '$UserOrGroupName'")	
				
	if($containsUserOrGroup.Count -eq 0)
	{
		#[Parameter(Mandatory=$true)][ValidateSet('read','modify',"none")][System.String]$PermissionType)
		$dtNewK2EnvLibPermissions = $environmentManagementServer.GetObjectRoleMappings($dtK2EnvLibPermissions, $TemplateEnvironmentID)
		$containsUserOrGroup = $dtNewK2EnvLibPermissions.Select("UsersGroups = '$UserOrGroupName'")	
		
	}	
	$retVal = "none"
	if($containsUserOrGroup -ne 0)
	{
		if([System.String]::IsNullOrEmpty($containsUserOrGroup[0]["ObjectAction_Modify"]) -ne $true)
		{##If modify is not null or empty
			if([System.Convert]::ToBoolean($containsUserOrGroup[0]["ObjectAction_Modify"]) -eq $true)
			{
				$retVal = "modify"
			}
		}
		elseif([System.String]::IsNullOrEmpty($containsUserOrGroup[0]["ObjectAction_ReadOnly"]) -ne $true)
		{
			if([bool]$containsUserOrGroup[0]["ObjectAction_ReadOnly"] -eq $true)
			{
				$retVal = "read"
			}
		}
	}
	$retVal
}

Function Get-K2SmartObjectPermission
{
<#
   .Synopsis
    This function gets a single permission for SmartObject Admin
   .Description
    This function gets a single permission for SmartObject Admin
	
	Return values
    one of "publish", "delete" or "none". "none" means no rights. . case sensitive.
	
	.Example
        
	.Parameter $ConnectionString
        If not provided it defaults to "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
    .Parameter $securityManagementServer
        If not provided it is created by connecting using ConnectionString
    .Parameter $UserOrGroupName
        Required. The fully qualified name of the user or group to locate. It must include the securtity label
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="ConnectionStringNameSet")]
	Param(
	[Parameter(ParameterSetName="ConnectionStringNameSet", Mandatory=$false, Position=0)][string]$ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(Mandatory=$false)]$securityManagementServer=$null,
	[Parameter(Mandatory=$true)][System.String]$UserOrGroupName
	)
	if ($securityManagementServer -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.Hosting.Client”) | out-null
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.SecurityManagementAPI”) | out-null
		$securityManagementServer = New-Object SourceCode.Hosting.Client.SecurityManagementAPI 
		$securityManagementServer.CreateConnection() | out-null
		$securityManagementServer.Connection.Open($ConnectionString) | out-null
	}
	
	$dtK2SmOPermissions = New-K2SmartObjectPermissionsDataTable ##-objectMappingNames $systemActions
		
	#[Parameter(Mandatory=$true)][ValidateSet('read','modify',"none")][System.String]$PermissionType)
	$dtK2SmOPermissions = $securityManagementServer.GetApplicationRoleMappings($dtK2SmOPermissions , "SmartObjects", "SmartObjects");
	$containsUserOrGroup = $dtK2SmOPermissions.Select("UsersGroups = '$UserOrGroupName'")	
				
	if($containsUserOrGroup.Count -eq 0)
	{
		$dtK2SmOPermissions.Clear();
		#[Parameter(Mandatory=$true)][ValidateSet('read','modify',"none")][System.String]$PermissionType)
		$dtK2SmOPermissions = $securityManagementServer.GetApplicationUserMappings($dtK2SmOPermissions , "SmartObjects", "SmartObjects");
		$containsUserOrGroup = $dtK2SmOPermissions.Select("UsersGroups = '$UserOrGroupName'")	
		
	}	
	[K2SmartObjectPermission]$retVal = [K2SmartObjectPermission]::None
	if($containsUserOrGroup.Count -ne 0)
	{
		if([System.String]::IsNullOrEmpty($containsUserOrGroup[0]["publish"]) -ne $true)
		{##If modify is not null or empty
			if([System.Convert]::ToBoolean($containsUserOrGroup[0]["publish"]) -eq $true)
			{
				$retVal = $retVal -bor [K2SmartObjectPermission]::Publish
			}
		}
		
		
		if([System.String]::IsNullOrEmpty($containsUserOrGroup[0]["delete"]) -ne $true)
		{
			if([bool]$containsUserOrGroup[0]["delete"] -eq $true)
			{
				$retVal = $retVal -bor [K2SmartObjectPermission]::Delete
			}
		}
	}
	$retVal
}

Function Set-K2SmartObjectPermission
{
<#
   .Synopsis
    This function sets a single SmartObject permission depending on parameters
   .Description
    This function sets a single SmartObject permission depending on parameters
	.Example
        
		#Give the administrators AD group publish permission 
		Set-K2SmartObjectPermission -UserOrGroup "Group" -PermissionType "Publish" -UserOrGroupName "K2:DENALLIX\Administrators"

	.Parameter $ConnectionString
        If not provided, it defaults to "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
    .Parameter $securityManagementServer
        If not provided it is created by connecting using ConnectionString
    .Parameter $UserOrGroup
        Required. Must be either "User" or "Group". case sensitive.
    .Parameter $UserOrGroupName
        Required. The fully qualified name of the user or group. It must include the securtity label
    .Parameter $PermissionType
        Required. A bitwise Enum of type [K2SmartObjectPermission] valid text values are "None", "Publish", "Delete", "Publish, Delete"
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	Param(
	[Parameter(Mandatory=$false)][string]$ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(Mandatory=$false)]$securityManagementServer=$null,
	[Parameter(Mandatory=$true)][ValidateSet('User','Group')][System.String]$UserOrGroup,
	[Parameter(Mandatory=$true)][System.String]$UserOrGroupName,
	[Parameter(Mandatory=$true)][K2SmartObjectPermission]$PermissionType)

	if ($securityManagementServer -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.Hosting.Client”) | out-null
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.SecurityManagementAPI”) | out-null
		$securityManagementServer = New-Object SourceCode.Hosting.Client.SecurityManagementAPI 
		$securityManagementServer.CreateConnection() | out-null
		$securityManagementServer.Connection.Open($ConnectionString) | out-null
	}

	$dtK2SmOPermissions = New-K2SmartObjectPermissionsDataTable 
				
	if($UserOrGroup -eq "User")
	{
		$dtK2SmOPermissions = $securityManagementServer.GetApplicationUserMappings($dtK2SmOPermissions , "SmartObjects", "SmartObjects");
	}
	else
	{
		$dtK2SmOPermissions = $securityManagementServer.GetApplicationRoleMappings($dtK2SmOPermissions , "SmartObjects", "SmartObjects");
	}
	
	$containsUserOrGroup = $dtK2SmOPermissions.Select("UsersGroups = '$UserOrGroupName'")	
	
	if($containsUserOrGroup.Count -eq 0)
	{
		#User does not already have rights
	
		[System.Data.DataRow]$newUserRow= $dtK2SmOPermissions.NewRow();
		$newUserRow["UsersGroups"] = "$UserOrGroupName";
		$newUserRow["publish"] = [System.Convert]::ToBoolean($PermissionType -band [K2SmartObjectPermission]::Publish);
		$newUserRow["delete"] = [System.Convert]::ToBoolean($PermissionType -band [K2SmartObjectPermission]::Delete);
		$newUserRow["Type"] = $UserOrGroup
		$dtK2SmOPermissions.Rows.Add($newUserRow);
	}
	else
	{
		#User already in table, so just update the values
		[System.Data.DataRow]$currentUserRow = $containsUserOrGroup[0];
		$currentUserRow["UsersGroups"] = "$UserOrGroupName";
		$currentUserRow["publish"] = [System.Convert]::ToBoolean($PermissionType -band [K2SmartObjectPermission]::Publish);
		$currentUserRow["delete"] = [System.Convert]::ToBoolean($PermissionType -band [K2SmartObjectPermission]::Delete);
		$currentUserRow["Type"] = $UserOrGroup
		
	}
	
	if($UserOrGroup -eq "User")
	{
		$securityManagementServer.SaveApplicationUserMappings($dtK2SmOPermissions , "SmartObjects", "SmartObjects") | Out-Null;
	}
	else
	{
		$securityManagementServer.SaveApplicationRoleMappings($dtK2SmOPermissions , "", "SmartObjects", "SmartObjects") | Out-Null;
	}
}
#Environment Library Maintenance
Function Get-K2EnvironmentLibrariesAsXML
{
<#
   .Synopsis
    This function Gets Environment Library values for a specified template and returns as XML from the k2 server according to parameters
   .Description
    This function Gets Environment Library values and returns as XML. If a templateName parameter is passed it will
	return the values for that template otherwise it will return the values for "Default Template"
	The XML will be in the following format:
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
	.Example
        Get-K2EnvironmentLibrariesAsXML
		Get-K2EnvironmentLibrariesAsXML -SCconnectionString "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" -TemplateName "HR"
   .Parameter $SCconnectionString
        Connection string to the K2 Environment Library server
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
[CmdletBinding()]
	Param(	[Parameter(Mandatory=$false)][string]$SCconnectionString= "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555",
			[Parameter(Mandatory=$false)][string]$TemplateName= "Default Template"
	)
	
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
	$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
	
	$environmentSettingsManager.ConnectToServer($SCconnectionString);
    $environmentSettingsManager.InitializeSettingsManager();
    $environmentSettingsManager.Disconnect();
	
	$CurrentEnvironmentTemplate = $environmentSettingsManager.EnvironmentTemplates["$TemplateName"]	
	if ($CurrentEnvironmentTemplate -eq $null)
	{
		Write-Error "Template Name: '$TemplateName' does not exist"
	}
	else
	{
	[xml]$EnvironmentsXML = $CurrentEnvironmentTemplate.Environments  | New-XML -RootTag Environments -ItemTag Environment -Attribute EnvironmentId,EnvironmentName,EnvironmentDescription,IsDefaultEnvironment -ChildItems EnvironmentFields 
					
	$CurrentEnvironmentTemplate.Environments | ForEach-Object {
			$environment  = $_;
			$EnvironmentName = $_.EnvironmentName
			Write-Debug "$EnvironmentName";
			Write-Debug("-----------------");
			$environmentInstance = $environmentSettingsManager.EnvironmentTemplates.FindEnvironment($environment.EnvironmentId);
			$environmentSettingsManager.ConnectToServer();
			$environmentSettingsManager.GetEnvironmentFields($environmentInstance) | out-null;
			$environmentSettingsManager.Disconnect() | out-null;
			
			[xml]$EnvironmentFieldXML = $environmentInstance.EnvironmentFields | New-XML -RootTag EnvironmentFields -ItemTag EnvironmentField -Attribute fieldType,fieldName,Value

		 	$environmentInstance.EnvironmentFields | ForEach-Object {
				$field = $_
				$fieldTypeID = $_.FieldTypeID
				$fieldName = $_.FieldName
				$fieldValue = $_.FieldValue
				$fieldTypeName  = $environmentSettingsManager.EnvironmentFieldTypes.GetItemById("$fieldTypeID").FieldName
				$selectNode = $EnvironmentFieldXML.SelectSingleNode("/EnvironmentFields/EnvironmentField[@FieldName='$fieldName']")
				$selectNode.SetAttribute("fieldTypeName", "$fieldTypeName");
	    }
						$EnvironmentsXML.SelectSingleNode("/Environments/Environment[@EnvironmentName='$EnvironmentName']").InnerXml = $EnvironmentFieldXML.OuterXml
		
	}
	$EnvironmentsXML
	}
}

Function Get-K2EnvironmentLibraryTemplatesAsXML
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
		$Template = $_
		$CurrentTemplateName = $_.TemplateName
		if(($TemplateName.CompareTo("*")) -or ($TemplateName.CompareTo("$CurrentTemplateName")))
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

Function Add-K2EnvironmentLibrary
{
<#
   .Synopsis
    This function Creates a New K2 Environment Instance
   .Description
    This function Creates a New K2 Environment Instance based on the parameters
	It checks for the existence of the environment first.
	It will add it to the selected template name, or to the default template if not selected
	It can take in an existing instatiated environmentSettings object, but if not supplied will use the provided connection string to attempt to 
	create a connection.
	Error checking (if template doe not exist or environment already exists) is provided so if this function throws an error, do not continue!
	nothing is written to screen as it will return an instatiated Environment Instance 
	.Example
        Add-K2EnvironmentLibrary -SCconnectionString "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" -TemplateId "3a76d329-6d51-418f-8dec-b0bad615bd63" -EnvironmentName "UAT" -EnvironmentDescription "Vaues for the User Acceptance Test environment" 
		$NewEnvironmentInstance = Add-K2EnvironmentLibrary -environmentSettingsManager $environmentSettingsManager -EnvironmentName $EnvironmentName -EnvironmentDescription $EnvironmentDescription -TemplateId $TemplateId
		Add-K2EnvironmentLibrary "PreProd" "Template does not exist" #Expected to error - template does not exist
		Add-K2EnvironmentLibrary "Production" #Expected to error - Default Template already has this environment
		Add-K2EnvironmentLibrary "UAT" #Adds UAT to default template
    .Parameter $EnvironmentName
        Required. The name of the environment to create. Will throw error if already exists
	.Parameter $TemplateId
        Required If TemplateName not supplied. 
   .Parameter $TemplateName
        if TemplateID and this parameter are not provided, then this will default to "Default Template". second paremeter if no named parameters provided
   .Parameter $ConnectionString
        will default to localhost on 5555 if this parameter and $environmentSettingsManager are both not provided
   .Parameter $environmentSettingsManager
		If provided, it must be an instatiated object of type SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager
   .Parameter $EnvironmentId 
		will be a random guid if not provided (this is preferable, as guids are not generally used and duplicate guids screw things up)
   .Parameter $IsDefault
		defaults to true
   .Parameter $EnvironmentDescription
		defaults to "Environment Description not provided"
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="TemplateNameSet")]
 	Param(
		[Parameter(Mandatory=$true, Position=0)][string]$EnvironmentName,
		[Parameter(ParameterSetName="TemplateIdSet", Mandatory=$true, Position=1)][string]$TemplateId,
		[Parameter(ParameterSetName="TemplateNameSet", Mandatory=$false, Position=1)][string]$TemplateName = "Default Template",	
		[Parameter(Mandatory=$false)][string]$ConnectionString = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
		[Parameter(Mandatory=$false)]$environmentSettingsManager = $null,
		[Parameter(Mandatory=$false)][string]$EnvironmentId = [guid]::NewGuid().ToString(),
		[Parameter(Mandatory=$false)][bool]$IsDefault = $true,
		[Parameter(Mandatory=$false)][bool]$ApplyTemplatePermissions = $true,
		[string]$EnvironmentDescription = "Environment Description not provided"
	)
	
	if ($environmentSettingsManager -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
		$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
		
		$environmentSettingsManager.ConnectToServer($ConnectionString) | out-null;
	    $environmentSettingsManager.InitializeSettingsManager() | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
			
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentLibrary.Management”) | out-null
			
    $environment = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentInstance "$EnvironmentId", "$EnvironmentName", "$EnvironmentDescription"
    $environment.IsDefaultEnvironment = $IsDefault;
	if ($TemplateId -eq $null)
	{
    	$environmentTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemByName($TemplateName);
	}
	else
	{
    	$environmentTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemById($TemplateId);
    }
	if ($environmentTemplate -eq $null)
	{
		Write-Error "Selected template does not exist"
		$environment = $null
	}
	else
	{
		$environmentSettingsManager.ConnectToServer() | out-null;
		$existingEnvironment =  $environmentTemplate.Environments.GetItemByName("$EnvironmentName")
		If($existingEnvironment -ne $null)
		{
			Write-Error "Environment by the name of '$EnvironmentName' already exists"
			$environment = $null
		}
		else
		{
		    $environmentTemplate.Environments.Add($environment) | out-null;
		    $environmentSettingsManager.Disconnect() | out-null;
		}
	}
    #There is a 4.5 bug in this functionality that only adds the first user and group
	#This is apparant when using the workspace
	if ($ApplyTemplatePermissions)
	{
		$environmentManagementServer = New-Object SourceCode.EnvironmentLibrary.Management.EnvironmentLibraryManagementServer "$ConnectionString", $true

		$objectMappingNames = $environmentManagementServer.GetObjectManagementNames();
		$dtK2EnvLibPermissions = New-K2PermissionsDataTable -objectMappingNames $objectMappingNames
		$TemplateObjectMappings = $environmentManagementServer.GetObjectUserMappings($dtK2EnvLibPermissions, $TemplateId);
		$environmentManagementServer.SaveObjectUserMappings($TemplateObjectMappings, $EnvironmentId) | out-null;
		
		$TemplateRoleMappings = $environmentManagementServer.GetObjectRoleMappings($dtK2EnvLibPermissions, $TemplateId);
		$environmentManagementServer.SaveObjectRoleMappings($TemplateRoleMappings, $EnvironmentId) | out-null;
	}
	
	$environment
	
}

Function Set-K2EnvironmentLibrariesFromXML
{
<#
   .Synopsis
    This function Gets Environment Library values from an XML file and adds it to a specified template onthe k2 server according to parameters
   .Description
    This function Sets Environment Library values and returns as XML. If a templateName parameter is passed it will
	return the values for that template otherwise it will return the values for "Default Template"
	N.B. The current version does not override existing environments
	N.B. The current version produces lots of errors which can be ignored
	The XML will need to be in the following format (generated from Get-K2EnvironmentLibrariesFromXML:
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
	.Example
        Set-K2EnvironmentLibrariesFromXML
		Set-K2EnvironmentLibrariesFromXML -SCconnectionString "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" -TemplateName "HR"
		
		#So if you have an existing set of env lib instances which you want to copy from one template to another (assumes the "RedTeam" template exists)
		$xmlToUse = Get-K2EnvironmentLibrariesAsXML -TemplateName "Default Template"
		Set-K2EnvironmentLibrariesFromXML -EnvironmentLibrariesXml $xmlToUse -TemplateName "RedTeam" -prependWithTemplateName $true

   .Parameter $k2host
        defaults to localhost - The K2 server where the environments need to be added
   .Parameter $k2HostPort
        defaults to 5555
   .Parameter $EnvironmentLibrariesXml
        The xml file in a format similar to the example in the description
   .Parameter $TemplateName
        The Template where the Environment should be added to - defaults to "Default Template"
   .Parameter $prependWithTemplateName
        defaults to false. If set to true the Environment will be dot notated with the template name
		This is useful for creating teams where string table entries should be isolated
		RedTeam.Development
		RedTeam.UAT
		BlueTeam.Development
		etc.
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="connectionstringSet")]
	param (
    [Parameter(ParameterSetName="connectionstringSet",  Mandatory=$false, Position=0)]
    [string]$SCconnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(ParameterSetName="hostandportSet", Mandatory=$true, Position=0)]
	[string]$k2Host,
    [Parameter(ParameterSetName="hostandportSet", Mandatory=$true, Position=1)]
    [int]$k2HostPort ,
    [Parameter(Mandatory=$true)][xml]$EnvironmentLibrariesXml,
	[Parameter(Mandatory=$false)][string]$TemplateName= "Default Template",
	[bool]$prependWithTemplateName=$false
    )
	
	Write-Verbose "Set-K2EnvironmentLibrariesFromXML - Start"
	
	if ($SCConnectionString -eq $null)
	{
		#If server and port are specified, they both become mandatory and SCconnectionString will no longer take the default
		$SCconnectionString = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2HostPort"
	}
	Write-Debug "Connect to the server using this connection string : '$SCconnectionString '."
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
	$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
	$environmentSettingsManager.ConnectToServer($SCconnectionString);
    $environmentSettingsManager.InitializeSettingsManager();
	#Testing has been slightly intermittent here, but it seems from the code I borrowed from
	#and from some tests that the disconnect is actually neccessary.
    $environmentSettingsManager.Disconnect();
	
	$CurrentEnvironmentTemplate = $environmentSettingsManager.EnvironmentTemplates["$TemplateName"]	
	if ($CurrentEnvironmentTemplate -eq $null)
	{
		#TODO: Maybe some options to create the template
		Write-Error "Template Name: '$TemplateName' does not exist"
	}
	else
	{
		$TemplateId = $CurrentEnvironmentTemplate.TemplateId
		Write-Verbose "Using template '$TemplateName' with ID:'$TemplateId'"
		#Loop through all the environments in the XML
		$nodelist = $EnvironmentLibrariesXml.selectnodes("/Environments/Environment") # XPath is case sensitive
		foreach ($environment in $nodelist)
		{
			$EnvironmentName = $environment.EnvironmentName
			Write-Verbose "Looping through Environments in XML - '$EnvironmentName'"
			if($prependWithTemplateName)
			{
				$EnvironmentName = "$TemplateName.$EnvironmentName"	
			}
			
			$EnvironmentID = $environment.EnvironmentID
			$EnvironmentDescription = $environment.EnvironmentDescription
			Write-Debug "$EnvironmentName";
				
			if ($CurrentEnvironmentTemplate.Environments["$EnvironmentName"] -ne $null)
			{
				Write-Error("Current version of this script does not overwrite libraries and Environments '$EnvironmentName' already exists. Please use Remove-K2EnviromentLibrary first")
			}
			else
			{
				
				Write-Verbose "Create the new Environment on the selected template"
				$NewEnvironmentInstance = Add-K2EnvironmentLibrary -environmentSettingsManager $environmentSettingsManager -EnvironmentName $EnvironmentName -EnvironmentDescription $EnvironmentDescription -TemplateId $TemplateId
				
				#Loop around the fields within the XML Environment node
				foreach ($environmentfield in $environment.EnvironmentFields.EnvironmentField)
				{
					
					$fieldTypeName = $environmentfield.FieldTypeName
					Write-Verbose "Looping through the fields within the XML Environment node - '$fieldTypeName'"
					$fieldName = $environmentfield.FieldName
					$fieldDescription = $environmentfield.FieldDescription
					$fieldValue = $environmentfield.Value
					
					#Get the field type (Category Server, Mail Server etc.)
					#[EnvironmentFieldType]
					$envFieldType = $environmentSettingsManager.EnvironmentFieldTypes.GetItemByFriendlyName($environmentfield.FieldTypeName);
					#Create an instance of this field Type
	            	[SourceCode.EnvironmentSettings.Client.EnvironmentField]$environmentFieldToAdd = $envFieldType.CreateFieldInstance();
					#Set all the values from the XML
					$environmentFieldToAdd.FieldName = $fieldName;
					$environmentFieldToAdd.FieldDescription = $fieldDescription;
		            $environmentFieldToAdd.Value = $fieldValue;
		            $environmentFieldToAdd.IsDefaultField = $true;

		            $environmentSettingsManager.ConnectToServer();
		            $environmentSettingsManager.GetEnvironmentFields($NewEnvironmentInstance);
					$EnvFieldValueToSave = $NewEnvironmentInstance.EnvironmentFields.GetItemByName("$fieldName")
					if ($EnvFieldValueToSave  -eq $null)
					{
						Write-Debug "field does not exists: '$fieldName' - adding it with value"
					
						$NewEnvironmentInstance.EnvironmentFields.Add($environmentFieldToAdd)
					}
					else
					{
						Write-Debug "setting the value of field : '$fieldName'  that already existed"
						$EnvFieldValueToSave.Value = $fieldValue;
						$EnvFieldValueToSave.SaveUpdate();
					}
					#Does not seem to work without the connect/disconnect
		            $environmentSettingsManager.Disconnect();
					
		    	}	
				###$NewEnvironmentInstance.SaveUpdate();
			}
		}
	}
	Write-Verbose "Set-K2EnvironmentLibrariesFromXML - Finished"
}

Function Add-K2EnvironmentLibraryTemplate
{
<#
   .Synopsis
    This function Creates a New K2 Environment Library Template
   .Description
    This function Creates a New K2 Environment Library Template based on the parameters
	It can take in an existing instatiated environmentSettings object, but if not supplied will use the provided connection string to attempt to 
	create a connection.
	Error checking (if template already exists) is provided so if this function throws an error, do not continue!
	nothing is written to screen as it will return an instatiated Environment Library Template
	.Example
        Add-K2EnvironmentLibraryTemplate -SCconnectionString "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=k2server.denallix.com;Port=5555" -TemplateName "RedTeam" -TemplateDescription "For the exclusive use of the redteam" 
		$newK2EnvironmentLibraryTemplate = Add-K2EnvironmentLibraryTemplate -environmentSettingsManager $environmentSettingsManager -TemplateName $TemplateName -TemplateDescription $TemplateDescription 
		Add-K2EnvironmentLibraryTemplate "NewPSTemplate" "NewPSDescription"
		Add-K2EnvironmentLibraryTemplate "Default Template" "NewPSDescription" # Should throw an error as it already exists
    .Parameter $TemplateName
        Required. The name of the Template to create. Will not create it and will throw an error if already exists
   .Parameter $TemplateDescription
		defaults to "Template Description not provided"
   .Parameter $TemplateName
        if TemplateID and this parameter are not provided, then this will default to "Default Template". second paremeter if no named parameters provided
   .Parameter $ConnectionString
        will default to localhost on 5555 if this parameter and $environmentSettingsManager are both not provided
   .Parameter $environmentSettingsManager
		If provided, it must be an instatiated object of type SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager
   .Parameter $IsDefault
		defaults to true
	.Parameter $TemplateId
        will be set to a random guid if not supplied. 
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding()]
 	Param(
		[Parameter(Mandatory=$true, Position=0)][string]$TemplateName = "Default Template",
		[Parameter(Mandatory=$false, Position=1)][string]$TemplateDescription = "Template Description not provided",	
		[Parameter(Mandatory=$false)][string]$ConnectionString = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
		[Parameter(Mandatory=$false)]$environmentSettingsManager = $null,
		[Parameter(Mandatory=$false)][bool]$IsDefault = $false,
		[Parameter(Mandatory=$false)][string]$TemplateId = [guid]::NewGuid().ToString()
	)
	
	if ($environmentSettingsManager -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
		$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
		
		$environmentSettingsManager.ConnectToServer($ConnectionString) | out-null;
	    $environmentSettingsManager.InitializeSettingsManager() | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
			
			
    $newTemplate = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentTemplate "$TemplateId", "$TemplateName", "$TemplateDescription"
    $newTemplate.IsDefaultTemplate = $IsDefault;
	
    $existingTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemByName($TemplateName);
	if ($existingTemplate -ne $null)
	{
		Write-Error "Selected template already exists"
		$newTemplate = $null
	}
	else
	{
		$environmentSettingsManager.ConnectToServer() | out-null;
	    $environmentSettingsManager.EnvironmentTemplates.Add($newTemplate) | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
    Write-Verbose "Returning the newly created template"	
	$newTemplate
	
}

Function Remove-K2EnvironmentLibraryTemplate
{
<#
   .Synopsis
    This function Removes existing an K2 Environment Library Template
   .Description
    This function Removes existing an K2 Environment Library Template based on the parameters
	It can take in an existing instatiated environmentSettings object, but if not supplied will use the provided connection string to attempt to 
	create a connection.
	It can take either the Template Name or the TemplateID
	Error checking (if template noes not already exists) is provided so if this function throws an error, do not continue!
	.Example
		Remove-K2EnvironmentLibraryTemplate -TemplateId "3a76d329-6d51-418f-8dec-b0bad615bd63"
		Remove-K2EnvironmentLibraryTemplate "NewPSTemplate2" 
		Remove-K2EnvironmentLibraryTemplate "NewPSTemplate2" # Should throw an error
    .Parameter $TemplateName
        Either this or TemplateId isRequired. The name of the Template to remove. Will throw an error if it does not exists
	.Parameter $TemplateId
        Either this or TemplateName isRequired. The ID of the Template to remove. Will throw an error if it does not exists
   .Parameter $ConnectionString
        will default to localhost on 5555 if this parameter and $environmentSettingsManager are both not provided
   .Parameter $environmentSettingsManager
		If provided, it must be an instatiated object of type SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="TemplateNameSet")]
 	Param(
		[Parameter(ParameterSetName="TemplateIdSet", Mandatory=$true, Position=0)][string]$TemplateId,
		[Parameter(ParameterSetName="TemplateNameSet", Mandatory=$true, Position=0)][string]$TemplateName,	
		[Parameter(Mandatory=$false)][string]$ConnectionString = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
		[Parameter(Mandatory=$false)]$environmentSettingsManager = $null
	)
	
	if ($environmentSettingsManager -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
		$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
		
		$environmentSettingsManager.ConnectToServer($ConnectionString) | out-null;
	    $environmentSettingsManager.InitializeSettingsManager() | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
		
	if ($TemplateName -ne $null)
	{
		Write-Verbose "Finding template by name: '$TemplateName'"
    	$existingTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemByName($TemplateName);
	}
	else #Delete by template id
	{
		Write-Verbose "Finding template by Id: '$TemplateId'"
    	$existingTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemById($TemplateId);
	}
	if ($existingTemplate -eq $null)
	{
		Write-Error "Failed to find the template to delete"
	}
	else
	{
		$environmentSettingsManager.ConnectToServer() | out-null;
	    $environmentSettingsManager.EnvironmentTemplates.Remove($existingTemplate) | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
}

Function Remove-K2EnvironmentLibrary
{
<#
   .Synopsis
    This function Removes existing an K2 Environment Library 
   .Description
    This function Removes existing an K2 Environment Library based on the parameters
	It can take in an existing instatiated environmentSettings object, but if not supplied will use the provided connection string to attempt to 
	create a connection.
	It can take either the Environment Library  Name or the Environment Library ID
	Error checking (if Environment Library does not already exists) is provided so if this function throws an error, do not continue!
	.Example
		Remove-K2EnvironmentLibrary -TemplateName "NewPSTemplate" -EnvironmentLibraryName "PreProd"
		Remove-K2EnvironmentLibrary "Production" "Default Template" #Deletes Production lib from default template 
		Remove-K2EnvironmentLibrary "EnvironmentDoesNotExist" "Default Template" #should error
    .Parameter $EnvironmentLibraryName
        Either this or EnvironmentLibraryId isRequired. The name of the EnvironmentLibrary to remove. Will throw an error if it does not exists
	.Parameter $EnvironmentLibraryId
        Either this or EnvironmentLibraryName isRequired. The ID of the EnvironmentLibrary to remove. Will throw an error if it does not exists
    .Parameter $TemplateName
		Required The name of the template to delte the library from. If it does not exist on the k2 server then an error will be thrown
    .Parameter $ConnectionString
        will default to localhost on 5555 if this parameter and $environmentSettingsManager are both not provided
   .Parameter $environmentSettingsManager
		If provided, it must be an instatiated object of type SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="EnvironmentLibraryNameSet")]
 	Param(
		[Parameter(ParameterSetName="EnvironmentLibraryIdSet", Mandatory=$true, Position=0)][string]$EnvironmentLibraryId,
		[Parameter(ParameterSetName="EnvironmentLibraryNameSet", Mandatory=$true, Position=0)][string]$EnvironmentLibraryName,	
		[Parameter(Mandatory=$true, Position=1)][string]$TemplateName,	
		[Parameter(Mandatory=$false)][string]$ConnectionString = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
		[Parameter(Mandatory=$false)]$environmentSettingsManager = $null
	)
	
	if ($environmentSettingsManager -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
		$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
		
		$environmentSettingsManager.ConnectToServer($ConnectionString) | out-null;
	    $environmentSettingsManager.InitializeSettingsManager() | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
	
	$existingTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemByName($TemplateName);
	
	if ($existingTemplate -eq $null)
	{
		Write-Error "Failed to find the template to delete from"
	}
		
	if ($EnvironmentLibraryName -ne $null)
	{
		Write-Verbose "Finding EnvironmentLibrary by name: '$EnvironmentLibraryName'"
    	$existingEnvironmentLibrary = $existingTemplate.Environments.GetItemByName($EnvironmentLibraryName);
	}
	else #Delete by EnvironmentLibrary id
	{
		Write-Verbose "Finding EnvironmentLibrary by Id: '$TemplateId'"
    	$existingEnvironmentLibrary = $existingTemplate.Environments.GetItemByName($EnvironmentLibraryId);
	}
	if ($existingEnvironmentLibrary -eq $null)
	{
		Write-Error "Failed to find the existing EnvironmentLibrary to delete"
	}
	else
	{
        $environment = $environmentSettingsManager.EnvironmentTemplates.FindEnvironment($existingEnvironmentLibrary.EnvironmentId);
		$environmentSettingsManager.ConnectToServer() | out-null;
	    $environment.EnvironmentTemplate.Environments.Remove($environment) | out-null;
	    $environmentSettingsManager.Disconnect() | out-null;
	}
}

Function Set-K2EnvironmentLibrariesTemplatesFromXML
{
<#
   .Synopsis
    This function Gets Environment Library templates values from an XML input and creates the specified templates onthe k2 server according to parameters
   .Description
    This function Sets Environment Library template valuess from an XML input. 
	CAUTION - If $OverwriteExistingTemplate is set to true (false by default), this will DELETE existing templates from the server
	The XML will need to be in the following format (generated from Get-K2EnvironmentLibrariesFromXML:
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
        
		#Remove the template created from this script (useful for running this multiple times)
		Remove-K2EnvironmentLibraryTemplate -TemplateName "Admin"
		#Get the XML is the correct format (imagine taking this xml from another developer's standalone machine)
		[xml]$xmlToUse = Get-K2EnvironmentLibraryTemplatesAsXML 
		#Hack the XML to change one of the template names
		$xmlToUse.SelectSingleNode("/Templates/Template[@TemplateName='Default Template']").TemplateName = "RedTeam"
		# Example of using this cmdlet with minimal parameters (defaults to localhost and 5555
		 Set-K2EnvironmentLibrariesTemplatesFromXML -EnvironmentLibraryTemplatesXml $xmlToUse
   .Parameter $SCconnectionString
        Connection string to the K2 Environment Library server. IF server, port and this parameter are NOT provided then it will default to:
		"Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
	.Parameter $k2Host
        IF k2Host is provided then k2HostPort becomes required.
	.Parameter $k2HostPort
        IF k2HostPort is provided then k2Host becomes required.
	.Parameter $EnvironmentLibraryTemplatesXml
        Required. The xml of templates matching the schema of the example in the description
	.Parameter $OverwriteExistingTemplate
        Defaults to false. If set to false, this function will not overwite existing templates
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
	[CmdletBinding(DefaultParameterSetName="connectionstringSet")]
	param (
    [Parameter(ParameterSetName="connectionstringSet",  Mandatory=$false, Position=0)]
    [string]$SCconnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(ParameterSetName="hostandportSet", Mandatory=$true, Position=0)]
	[string]$k2Host,
    [Parameter(ParameterSetName="hostandportSet", Mandatory=$true, Position=1)]
    [int]$k2HostPort,
    [Parameter(Mandatory=$true)]
    [xml]$EnvironmentLibraryTemplatesXml,
    [Parameter(Mandatory=$false)]
	[bool]$OverwriteExistingTemplate=$false
    )
	if ($SCConnectionString -eq $null)
	{
		#If server and port are specified, they both become mandatory and SCconnectionString will no longer take the default
		$SCconnectionString = "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=$k2Host;Port=$k2HostPort"
	}
	
    Write-Host $SCConnectionString
	 
	[Reflection.Assembly]::LoadWithPartialName(“SourceCode.EnvironmentSettings.Client”) | out-null
	$environmentSettingsManager = New-Object SourceCode.EnvironmentSettings.Client.EnvironmentSettingsManager $false, $false
	
	$environmentSettingsManager.ConnectToServer($SCconnectionString);
    $environmentSettingsManager.InitializeSettingsManager();
    $environmentSettingsManager.Disconnect();
	
	
	$templateNodeList = $EnvironmentLibraryTemplatesXml.selectnodes("/Templates/Template") # XPath is case sensitive
	foreach ($templateNode in $templateNodeList)
	{
		$TemplateName = $templateNode.TemplateName;
		$TemplateDes = $templateNode.TemplateName;
		$TemplateName = $templateNode.TemplateName;
		$CurrentEnvironmentTemplate = $environmentSettingsManager.EnvironmentTemplates.GetItemByName("$TemplateName")
		
		#  override  | exists  | result
		#     Y      |   Y     | delete existing and add new template
		#     Y      |   N     | add new template
		#     N      |   Y     | Error
		#     N      |   N     | add new template
		
		
		if ($CurrentEnvironmentTemplate -ne $null)
		{ 
			$ExistingTemplateName = $CurrentEnvironmentTemplate.TemplateName
			Write-Verbose "The environment template '$ExistingTemplateName' exists"
			if ($OverwriteExistingTemplate)
			{
				Remove-K2EnvironmentLibraryTemplate -TemplateName $ExistingTemplateName
			}
			else
			{
				Write-Error "The environment template '$ExistingTemplateName' exists and settings are not allowed to overwrite it - set $OverwriteExistingTemplate to true and run again"
				continue;
			}
		}
		Write-verbose "Now creating Template"
		$IsDefault = [System.Convert]::ToBoolean($templateNode.IsDefaultTemplate);
		Add-K2EnvironmentLibraryTemplate -TemplateName $TemplateName  -TemplateDescription $templateNode.TemplateDescription -IsDefault $IsDefault
		Set-K2EnvironmentLibrariesFromXML -TemplateName $TemplateName  -SCConnectionString $SCConnectionString -EnvironmentLibrariesXml $templateNode.Environments.OuterXML
	}
}

#User Manager Settings in workspace
Function Get-K2UserManagementRoleInitSetting
{
<#
   .Synopsis
    This function gets a value from the k2workspace management console - User Managers - $securityLabel - Settings
   .Description
    This function gets a value based on the [K2SecuritySettings]$SettingName parameter
	
	Return values
    a string value . case sensitive.
	
	.Example
        
		[string]$currentValue = Get-K2UserManagementRoleInitSetting -securityLabel "K2" -SettingName "ResolveNestedGroups" 
		$testValue = Get-K2UserManagementRoleInitSetting -SettingName "IgnoreForeignPrincipals" 

	.Parameter $ConnectionString
        If not provided it defaults to "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
    .Parameter $securityLabel
        defaults to "K2", but any security label can be provided.
	.Parameter $securityManagementServer
        If not provided it is created by connecting using ConnectionString
    .Parameter $SettingName
        Required. The name of the setting to get. Uses the K2SecuritySettings enum to restrict values
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
[CmdletBinding(DefaultParameterSetName="ConnectionStringNameSet")]
	Param(
	[Parameter(ParameterSetName="ConnectionStringNameSet", Mandatory=$false, Position=0)][string]$ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(Mandatory=$false)][string]$securityLabel="K2",
	[Parameter(Mandatory=$false)]$securityManagementServer=$null,
	[Parameter(Mandatory=$true)][K2SecuritySettings]$SettingName
	)
	if ($securityManagementServer -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.Hosting.Client”) | out-null
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.SecurityManagementAPI”) | out-null
		$securityManagementServer = New-Object SourceCode.Hosting.Client.SecurityManagementAPI 
		$securityManagementServer.CreateConnection() | out-null
		$securityManagementServer.Connection.Open($ConnectionString) | out-null
	}
	
	[xml]$roleinitsetting = $securityManagementServer.GetSecurityLabelItem("$securityLabel", "RoleInit");
	
	[string]$initSettingString = $roleinitsetting.roleprovider.init
	
    $initSettingString.Split(";")| ForEach {
    	Write-Debug "found setting with name value pair of: $_ "
		If($_.StartsWith("$SettingName"))
		{
			
    		Write-Debug "found setting: $_ "
			[int]$PosOfFirstEquals = $_.IndexOf("=")
			$_.substring($PosOfFirstEquals + 1)
			###continue;
		}
 	}
}

Function Set-K2UserManagementRoleInitSetting
{
<#
   .Synopsis
    This function sets a value to the k2workspace management console - User Managers - $securityLabel - Settings
   .Description
    This function sets a value based on the [K2SecuritySettings]$SettingName parameter
	
	.Example
		Set-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" -settingValue $firstNewValue 
	.Parameter $ConnectionString
        If not provided it defaults to "Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555"
    .Parameter $securityLabel
        defaults to "K2", but any security label can be provided.
	.Parameter $securityManagementServer
        If not provided it is created by connecting using ConnectionString
    .Parameter $SettingName
        Required. The name of the setting to get. Uses the K2SecuritySettings enum to restrict values
    .Parameter $SettingValue
        Required. The value of the setting to set. Uses a string rather than boolean
   .Notes
        AUTHOR: Lee Adams, K2
      #Requires -Version 2.0
#>  
[CmdletBinding(DefaultParameterSetName="ConnectionStringNameSet")]
	Param(
	[Parameter(ParameterSetName="ConnectionStringNameSet", Mandatory=$false, Position=0)][string]$ConnectionString="Integrated=True;IsPrimaryLogin=True;Authenticate=True;EncryptedPassword=False;Host=localhost;Port=5555",
	[Parameter(Mandatory=$false)][string]$securityLabel="K2",
	[Parameter(Mandatory=$false)]$securityManagementServer=$null,
	[Parameter(Mandatory=$true)][K2SecuritySettings]$SettingName,
	[Parameter(Mandatory=$true)][string]$SettingValue
	)
	if ($securityManagementServer -eq $null)
	{
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.Hosting.Client”) | out-null
		[Reflection.Assembly]::LoadWithPartialName(“SourceCode.SecurityManagementAPI”) | out-null
		$securityManagementServer = New-Object SourceCode.Hosting.Client.SecurityManagementAPI 
		$securityManagementServer.CreateConnection() | out-null
		$securityManagementServer.Connection.Open($ConnectionString) | out-null
	}
	
	[xml]$roleinitsetting = $securityManagementServer.GetSecurityLabelItem("$securityLabel", "RoleInit");
	
	[string]$initSettingString = $roleinitsetting.roleprovider.init
	$settingArray = $initSettingString.Split(";")
	[int]$i=0;
    $settingArray | ForEach {
    	Write-Debug "found setting with name value pair of: $_ "
		If($_.StartsWith("$SettingName"))
		{
			
    		Write-Debug "found setting: $_ "
			$settingArray[$i] = "$SettingName=$SettingValue"
			#continue;
		}
		$i++
 	}
	$roleinitsetting.roleprovider.init = $settingArray -join ";"
	Write-Debug $roleinitsetting.roleprovider.init
	
    $securityManagementServer.SetSecurityLabelItem("K2", "RoleInit", $roleinitsetting.OuterXML);
	Write-Debug $roleinitsetting.OuterXML
}

#Miscelaneous
export-modulemember -function Read-Activities
Export-ModuleMember -Function Set-K2WorklistItemActioned
#Connectivity
export-modulemember -function Open-K2ServerConection
export-modulemember -function Open-K2WorkflowClientConnectionVerboseError
export-modulemember -function Open-K2WorkflowClientConnectionThrowError
export-modulemember -function Open-K2SMOManagementConnectionVerboseError
Export-ModuleMember -Function Open-K2SMOServiceManagementConnectionThrowError	
export-modulemember -function Get-K2SMOManagementConnectionThrowError
export-modulemember -function Test-K2Server
export-modulemember -function Restart-K2Server
#Settings Discovery
export-modulemember -function Test-K2BlackPearlDirectorys
export-modulemember -function Set-K2BlackPearlDirectory
#Use msbuild projects for Service broker deployment
export-modulemember -function New-K2Package
export-modulemember -function New-K2Packages
export-modulemember -function Publish-K2ServiceType
export-modulemember -function Publish-K2ServiceInstance
export-modulemember -function Publish-K2ServiceBrokers
export-modulemember -function Publish-K2SMOsFromServiceInstance
Export-ModuleMember -Function Update-K2ServiceInstance
#Automation of permissions
Export-ModuleMember -Function Set-K2ServerPermissions
Export-ModuleMember -Function Set-K2SharePointRestrictedWizards
Export-ModuleMember -Function Set-K2EnvironmentLibraryPermission
Export-ModuleMember -Function Get-K2EnvironmentLibraryPermission
Export-ModuleMember -Function Get-K2SmartObjectPermission
Export-ModuleMember -Function Set-K2SmartObjectPermission
#Environment Library Maintenance
Export-ModuleMember -Function Get-K2EnvironmentLibrariesAsXML
Export-ModuleMember -Function Get-K2EnvironmentLibraryTemplatesAsXML
Export-ModuleMember -Function Add-K2EnvironmentLibrary
Export-ModuleMember -Function Set-K2EnvironmentLibrariesFromXML
Export-ModuleMember -Function Add-K2EnvironmentLibraryTemplate
Export-ModuleMember -Function Remove-K2EnvironmentLibraryTemplate
Export-ModuleMember -Function Remove-K2EnvironmentLibrary
Export-ModuleMember -Function Set-K2EnvironmentLibrariesTemplatesFromXML
#User Manager Settings in workspace
Export-ModuleMember -Function Get-K2UserManagementRoleInitSetting
Export-ModuleMember -Function Set-K2UserManagementRoleInitSetting

Set-K2BlackPearlDirectory

configuration DomainJoin 
{ 
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds
    ) 
    
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement

    $domainCreds = New-Object System.Management.Automation.PSCredential ("$domainName\$($adminCreds.UserName)", $adminCreds.Password)
   
    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature ADPowershell
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        } 

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $domainName
            Credential = $domainCreds
            DependsOn = "[WindowsFeature]ADPowershell" 
        }
   }
}






configuration GatewaySetup
{
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds,
		
		[Parameter(Mandatory)]
        [String]$gridName,
		
		[Parameter(Mandatory)]
        [String]$LUS,
		
		[Parameter(Mandatory)]
        [String]$tenant
    ) 

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        DomainJoin DomainJoin
        {
            domainName = $domainName 
            adminCreds = $adminCreds 
        }

        Script DownloadGridMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectDataGrid_x64_WT.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/eV4Ahpl_P0Sktt_rLDE_2w/EricomConnectDataGrid_x64_WT.msi"
                $dest = "C:\EricomConnectDataGrid_x64_WT.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadGridMSI"}}
      
        }
		
        Package InstallGridMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectDataGrid_x64_WT.msi"
            Name = "Ericom Connect Data Grid"
            ProductId = "E94F3137-AD33-434F-94B1-D34E12C02064"
            Arguments = ""
            LogPath = "C:\log-ecdg.txt"
            DependsOn = "[Script]DownloadGridMSI"
        }

	    Script DownloadSecureGatewayMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectSecureGateway.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/SkL3cdmCG0uy4x_3-2BFTg/EricomConnectSecureGateway.msi"
                $dest = "C:\EricomConnectSecureGateway.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadSecureGatewayMSI"}}
      
        }
		
        Package InstallSecureGatewayMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectSecureGateway.msi"
            Name = "Ericom Connect Secure Gateway"
            ProductId = "D52E3491-F0FC-4067-BBC4-F567C2D4CEF5"
            Arguments = ""
            LogPath = "C:\log-ecsg.txt"
            DependsOn = "[Script]DownloadSecureGatewayMSI"
        }


    }
}



configuration DesktopHost
{
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds,
		
		[Parameter(Mandatory)]
        [String]$gridName,
		
		[Parameter(Mandatory)]
        [String]$LUS,
		
		[Parameter(Mandatory)]
        [String]$tenant
    ) 


    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        DomainJoin DomainJoin
        {
            domainName = $domainName 
            adminCreds = $adminCreds 
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }
	
		 
	    Script DownloadGridMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectDataGrid_x64.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/9mKtbaJhwk_rlYv7yLFRXQ/EricomConnectDataGrid_x64.msi"
                $dest = "C:\EricomConnectDataGrid_x64.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadGridMSI"}}
      
        }
		
        Package InstallGridMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectDataGrid_x64.msi"
            Name = "Ericom Connect Data Grid"
            ProductId = "E94F3137-AD33-434F-94B1-D34E12C02064"
            Arguments = ""
            LogPath = "C:\log-ecdg.txt"
            DependsOn = "[Script]DownloadGridMSI"
        }
        
	    Script DownloadRemoteAgentMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectRemoteAgentClient_x64.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/sA5xpahFyEWLEGMSfHpp-g/EricomConnectRemoteAgentClient_x64.msi"
                $dest = "C:\EricomConnectRemoteAgentClient_x64.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadRemoteAgentMSI"}}
      
        }
		
        Package InstallRemoteAgentMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectRemoteAgentClient_x64.msi"
            Name = "Ericom Connect Remote Agent Client"
            ProductId = "91D821BA-94CA-4383-B5D8-709239F39553"
            Arguments = ""
            LogPath = "C:\log-ecrac.txt"
            DependsOn = "[Script]DownloadRemoteAgentMSI"
        }

	    Script DownloadAccessServerMSI
        {
            TestScript = {
                Test-Path "c:\EricomAccessServer64.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/ww2wz-NYAkSUE9KqU4IYLQ/EricomAccessServer64.msi"
                $dest = "C:\EricomAccessServer64.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadAccessServerMSI"}}
      
        }
		
        Package InstallAccessServerMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomAccessServer64.msi"
            Name = "Ericom Access Server"
            ProductId = "F340EF5E-D4D8-4FB8-AE87-11459D65ED7F"
            Arguments = ""
            LogPath = "C:\log-eas.txt"
            DependsOn = "[Script]DownloadAccessServerMSI"
        }

	
	
    }

}
configuration ApplicationHost
{
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds,
		
		[Parameter(Mandatory)]
        [String]$gridName,
		
		[Parameter(Mandatory)]
        [String]$LUS,
		
		[Parameter(Mandatory)]
        [String]$tenant
    ) 


    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        DomainJoin DomainJoin
        {
            domainName = $domainName 
            adminCreds = $adminCreds 
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }
	
		 
	    Script DownloadGridMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectDataGrid_x64.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/9mKtbaJhwk_rlYv7yLFRXQ/EricomConnectDataGrid_x64.msi"
                $dest = "C:\EricomConnectDataGrid_x64.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadGridMSI"}}
      
        }
		
        Package InstallGridMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectDataGrid_x64.msi"
            Name = "Ericom Connect Data Grid"
            ProductId = "E94F3137-AD33-434F-94B1-D34E12C02064"
            Arguments = ""
            LogPath = "C:\log-ecdg.txt"
            DependsOn = "[Script]DownloadGridMSI"
        }
        
	    Script DownloadRemoteAgentMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectRemoteAgentClient_x64.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/sA5xpahFyEWLEGMSfHpp-g/EricomConnectRemoteAgentClient_x64.msi"
                $dest = "C:\EricomConnectRemoteAgentClient_x64.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadRemoteAgentMSI"}}
      
        }
		
        Package InstallRemoteAgentMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectRemoteAgentClient_x64.msi"
            Name = "Ericom Connect Remote Agent Client"
            ProductId = "91D821BA-94CA-4383-B5D8-709239F39553"
            Arguments = ""
            LogPath = "C:\log-ecrac.txt"
            DependsOn = "[Script]DownloadRemoteAgentMSI"
        }

	    Script DownloadAccessServerMSI
        {
            TestScript = {
                Test-Path "c:\EricomAccessServer64.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/ww2wz-NYAkSUE9KqU4IYLQ/EricomAccessServer64.msi"
                $dest = "C:\EricomAccessServer64.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadAccessServerMSI"}}
      
        }
		
        Package InstallAccessServerMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomAccessServer64.msi"
            Name = "Ericom Access Server"
            ProductId = "F340EF5E-D4D8-4FB8-AE87-11459D65ED7F"
            Arguments = ""
            LogPath = "C:\log-eas.txt"
            DependsOn = "[Script]DownloadAccessServerMSI"
        }

	
	
    }

}




configuration EricomConnectServerSetup
{
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [PSCredential]$adminCreds,


        # Gateway external FQDN
        [String]$externalFqdn,
        

        # Grid Name
        [String]$gridName,

        # sql server 
        [String]$sqlserver,
        
        # sql database
        [String]$sqldatabase,
        
         # sql user 
        [String]$sqluser,
        
         # sql password 
        [String]$sqlpassword

    ) 

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xComputerManagement, xRemoteDesktopSessionHost, xSqlPs

   
    $localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

    $username = $adminCreds.UserName -split '\\' | select -last 1
    $domainCreds = New-Object System.Management.Automation.PSCredential ("$domainName\$username", $adminCreds.Password)

    $securePassword = ConvertTo-SecureString -String "W.A.Mozart35!!!" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ("$domainName\$username", $securePassword)

    if (-not $connectionBroker)   { $connectionBroker = $localhost }
    if (-not $webAccessServer)    { $webAccessServer  = $localhost }

    if ($sessionHostNamingPrefix)
    { 
        $sessionHosts = @( 0..($numberOfRdshInstances-1) | % { "$sessionHostNamingPrefix$_.$domainname"} )
    }
    else
    {
        $sessionHosts = @( $localhost )
    }

    if (-not $collectionName)         { $collectionName = "Desktop Collection" }
    if (-not $collectionDescription)  { $collectionDescription = "A sample RD Session collection up in cloud." }


    Node localhost
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        DomainJoin DomainJoin
        {
            domainName = $domainName 
            adminCreds = $adminCreds 
        }
	
       Script DownloadSQLMSI
       {
            TestScript = {
                Test-Path "C:\SQLEXPR_x64_ENU.exe"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/4PYgN5tyT0_qQC6aExom9w/SQLEXPR_x64_ENU.exe"
                $dest = "C:\SQLEXPR_x64_ENU.exe"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadSQLMSI"}}
      
        }
		
	   WindowsFeature installdotNet35 
	   {             
		    Ensure = "Present"
		    Name = "Net-Framework-Core"
		    Source = "\\neuromancer\Share\Sources_sxs\?Win2012R2"
	   }
       
       Script ExtractSQLInstaller
        {
            TestScript = {
                Test-Path "C:\SQLEXPR_x64_ENU\"
            }
            SetScript ={
                $dest = "C:\SQLEXPR_x64_ENU.exe"
                $arguments = '/q /x:C:\SQLEXPR_x64_ENU'
                $exitCode = (Start-Process -Filepath "$dest" -ArgumentList "$arguments" -Wait -Passthru).ExitCode
            }
            GetScript = {@{Result = "ExtractSQLInstaller"}}      
        }

        xSqlServerInstall installSqlServer
        {
            InstanceName = "ERICOMCONNECTDB"
            SourcePath = "C:\SQLEXPR_x64_ENU"
            Features= "SQLEngine"
            SqlAdministratorCredential = $credential
        }

	    Script DownloadGridMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectDataGrid_x64_WT.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/eV4Ahpl_P0Sktt_rLDE_2w/EricomConnectDataGrid_x64_WT.msi"
                $dest = "C:\EricomConnectDataGrid_x64_WT.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadGridMSI"}}
      
        }
		
        Package InstallGridMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectDataGrid_x64_WT.msi"
            Name = "Ericom Connect Data Grid"
            ProductId = "E94F3137-AD33-434F-94B1-D34E12C02064"
            Arguments = ""
            LogPath = "C:\log-ecdg.txt"
            DependsOn = "[Script]DownloadGridMSI"
        }
	
	    Script DownloadProcessingUnitServerMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectProcessingUnitServer.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/SJEcdw86E0CLwhOTAHoRIA/EricomConnectProcessingUnitServer.msi"
                $dest = "C:\EricomConnectProcessingUnitServer.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadProcessingUnitServerMSI"}}
      
        }
		
        Package InstallProcessingUnitServerMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectProcessingUnitServer.msi"
            Name = "Ericom Connect Processing Unit Server"
            ProductId = "4D24EBBE-380B-4E7D-8F1A-C1AD5B236E03"
            Arguments = ""
            LogPath = "C:\log-ecpus.txt"
            DependsOn = "[Script]DownloadProcessingUnitServerMSI"
        }


	    Script DownloadAdminWebServiceMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectAdminWebService.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/xyRW03bY30OSaHJxpgQxOA/EricomConnectAdminWebService.msi"
                $dest = "C:\EricomConnectAdminWebService.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadAdminWebServiceMSI"}}
      
        }
		
        Package InstallAdminWebServiceMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectAdminWebService.msi"
            Name = "Ericom Connect Admin Web Service"
            ProductId = "2048FBD6-BDC3-46E8-8018-61DDDC7F7623"
            Arguments = ""
            LogPath = "C:\log-ecaws.txt"
            DependsOn = "[Script]DownloadAdminWebServiceMSI"
        }

	    Script DownloadClientWebServiceMSI
        {
            TestScript = {
                Test-Path "C:\EricomConnectClientWebService.msi"
            }
            SetScript ={
                $source = "https://download.ericom.com/public/file/V8MjLB1gmU2ZwVSF79t0Og/EricomConnectClientWebService.msi"
                $dest = "C:\EricomConnectClientWebService.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadClientWebServiceMSI"}}
      
        }
		
        Package InstallClientWebServiceMSI
        {
            Ensure = "Present" 
            Path  = "C:\EricomConnectClientWebService.msi"
            Name = "Ericom Connect Client Web Service"
            ProductId = "A05F2AC6-0209-4BED-8671-5C168F2AEB7D"
            Arguments = ""
            LogPath = "C:\log-eccws.txt"
            DependsOn = "[Script]DownloadClientWebServiceMSI"
        }


    }
}
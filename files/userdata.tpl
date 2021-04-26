<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  # Allow WinRM Connection
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow

  # Set Default Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${winrm_instance_admin_password}")

  # Install Features and Roles
  Install-WindowsFeature -name RSAT -IncludeAllSubFeature -IncludeManagementTools

  # Install Chocolatey and Packages
  Set-ExecutionPolicy Unrestricted -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  choco install googlechrome -y

  # Disable IE Security Function
  function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
  }

  # Disable UAC Function
  function Disable-UserAccessControl {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 -Force
    Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green
  }

  # Disable IE Sec and UAC
  Disable-InternetExplorerESC
  Disable-UserAccessControl

  #Set Time Zone
  Set-TimeZone -Name "GMT Standard Time"

  $dns_ips="%{ for ip in dns_ip_addresses ~} ${ip}, %{ endfor ~}"
  $processed_dns_ips=$dns_ips.TrimEnd(', ')
  Set-DnsClientServerAddress –interfaceAlias Ethernet* –ServerAddresses ($processed_dns_ips)

  # Join EC2 Instance to Domain
  $domain = "${directory_domain_name}"
  $password = "${winrm_instance_admin_password}" | ConvertTo-SecureString -asPlainText -Force
  $username = "$domain\${winrm_instance_admin_username}"
  $credential = New-Object System.Management.Automation.PSCredential($username,$password)
  Add-Computer -DomainName $domain -Credential $credential
  Restart-Computer
</powershell>
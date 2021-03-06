###############################
#
# Tests to get/set UserManager settings
# Tries to put back the initial setting. Only tests K2 label and ResolveNestedGroups setting
#
###############################


"Start tests"
#Set-K2UserManagementRoleInitSettings
[string]$firstSettingNameToTest="ResolveNestedGroups"
[string]$currentValue = Get-K2UserManagementRoleInitSetting -securityLabel "K2" -SettingName "$firstSettingNameToTest" 
[string]$firstNewValue = "True"


Set-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" -securityLabel "K2" -settingValue $firstNewValue 
[string]$testValue = Get-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" 
if ($firstNewValue.Equals($testValue)) {"Successfully set $firstSettingNameToTest to $firstNewValue"}
else {Write-Error "failed to set $firstSettingNameToTest to $firstNewValue"}

[string]$secondNewValue = "False"
Set-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" -settingValue $secondNewValue 
$testValue = Get-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" 
if ($secondNewValue.Equals($testValue)) {"Successfully set $firstSettingNameToTest to $secondNewValue "}
else {Write-Error "failed to set $firstSettingNameToTest to $secondNewValue "}

Set-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" -settingValue $currentValue 
$testValue = Get-K2UserManagementRoleInitSetting -SettingName "$firstSettingNameToTest" 
if ($currentValue.Equals($testValue)) {"Successfully set $firstSettingNameToTest back to what it was ($currentValue)"}
else {Write-Error "WARNING!! failed to set $firstSettingNameToTest to back to what it was. Please set it back manually to  $currentValue"}

"end"


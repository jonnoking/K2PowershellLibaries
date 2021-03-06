Import-Module .\GitHub\K2PowershellLibaries\scripts\K2AvailabilityHoursModule.psm1
[xml]$AvailabilityDatesBlank = $null

[xml]$AvailabilityDatesChristmas = @"
    <AvailabilityDates>
      <AvailabilityDate description="Christmas Day" date="2013-12-25T00:00:00" isNonWorkDate="True">
      </AvailabilityDate>
      <AvailabilityDate description="Christmas Eve" date="2013-12-24T00:00:00" isNonWorkDate="False">
        <TimeOfDay days="0" hours="13" minutes="0" seconds="0" milliseconds="0"></TimeOfDay>
        <Duration days="0" hours="5" minutes="0" seconds="0" milliseconds="0"></Duration>
      </AvailabilityDate>
    </AvailabilityDates>
"@
[xml]$AvailabilityHours = @"
    <AvailabilityHours>
      <AvailabilityHour workDay="5">
        <Duration days="0" hours="8" minutes="30" seconds="0" milliseconds="0"></Duration>
        <TimeOfDay days="0" hours="8" minutes="30" seconds="0" milliseconds="0"></TimeOfDay>
      </AvailabilityHour>
      <AvailabilityHour workDay="4">
        <Duration days="0" hours="9" minutes="30" seconds="0" milliseconds="0"></Duration>
        <TimeOfDay days="0" hours="8" minutes="00" seconds="0" milliseconds="0"></TimeOfDay>
      </AvailabilityHour>
      <AvailabilityHour workDay="3">
        <Duration days="0" hours="10" minutes="30" seconds="0" milliseconds="0"></Duration>
        <TimeOfDay days="0" hours="8" minutes="30" seconds="0" milliseconds="0"></TimeOfDay>
      </AvailabilityHour>
      <AvailabilityHour workDay="2">
        <Duration days="0" hours="10" minutes="30" seconds="0" milliseconds="0"></Duration>
        <TimeOfDay days="0" hours="8" minutes="30" seconds="0" milliseconds="0"></TimeOfDay>
      </AvailabilityHour>
      <AvailabilityHour workDay="1">
        <Duration days="0" hours="8" minutes="30" seconds="0" milliseconds="0"></Duration>
        <TimeOfDay days="0" hours="9" minutes="30" seconds="0" milliseconds="0"></TimeOfDay>
      </AvailabilityHour>
    </AvailabilityHours>
"@

"Start"
"Save all existing Zones and remove them"
[xml]$existingAvailabilityZones = Get-K2AvailabilityZonesAsXML 
if ( -not ([System.String]::IsNullOrEmpty( $existingAvailabilityZones.AvailabilityZones)))
{
	foreach ($availabilityZone in $existingAvailabilityZones.AvailabilityZones.AvailabilityZone)
	{
		$zoneToRemove =$availabilityZone.GetAttribute("name");
		Remove-K2AvailabilityZone -AvailabilityZoneName $zoneToRemove
	}
}
"Add a new zone with blank dates and hours"
Add-K2AvailabilityZone -AvailabilityZoneName "Powershelltest" -GMToffset "0" -AvailabilityZonedescription "this is a test to add a zone from powershell with blank dates" -isDefault $true -availabilityDates $AvailabilityDatesBlank -availabilityHours $AvailabilityHours
"remove this zone"
Remove-K2AvailabilityZone -AvailabilityZoneName "Powershelltest" 
"Add a new zone with christmas dates and sample hours"
Add-K2AvailabilityZone -AvailabilityZoneName "Powershelltest" -GMToffset "0" -AvailabilityZonedescription "this is a test to add a zone from powershell with Christmas dates" -isDefault $true -availabilityDates $AvailabilityDatesChristmas -availabilityHours $AvailabilityHours
"get this zone as xml"
[xml]$powershelltestAvailabilityTest = Get-K2AvailabilityZoneAsXML -AvailabilityZoneName "Powershelltest"
"Change a sample value in XML"
$powershelltestAvailabilityTest.AvailabilityZone.SetAttribute("GMTOffset", "-1")
"remove the zone which we now have backup XML for"
Remove-K2AvailabilityZone -AvailabilityZoneName "Powershelltest"
"Add zone back in from xml"
Add-K2AvailabilityZone -AvailabilityZoneXML $powershelltestAvailabilityTest

[xml]$powershelltestAvailabilityTest = Get-K2AvailabilityZoneAsXML -AvailabilityZoneName "Powershelltest"
"get xml again and check the value we changed"
if($powershelltestAvailabilityTest.AvailabilityZone.GMTOffset -eq -1)
{
	"GMTOffset set correctly"
}
else
{
	Write-Error "GMTOffset not set correctly"
}
"remove the temp zone"
Remove-K2AvailabilityZone -AvailabilityZoneName "Powershelltest"
"re-add the existing Zones"
Add-K2AvailabilityZonesAsXML -availabilityZonesXml $existingAvailabilityZones	
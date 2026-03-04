# Test migration APIs with Bearer token. Usage: .\Run-MigrationApiTests.ps1 -Token "YOUR_JWT"
param([Parameter(Mandatory=$true)][string]$Token)
$base = "http://localhost:3090"
$h = @{ Authorization = "Bearer $Token" }

function Test-Api {
    param([string]$Name, [string]$Uri)
    try {
        $r = Invoke-WebRequest -Uri $Uri -Headers $h -UseBasicParsing -TimeoutSec 15
        $preview = if ($r.Content.Length -gt 150) { $r.Content.Substring(0,150) + "..." } else { $r.Content }
        Write-Host "[OK] $Name -> $($r.StatusCode) | $preview"
        return $true
    } catch {
        $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        Write-Host "[--] $Name -> $code | $($_.Exception.Message)"
        return $false
    }
}

Write-Host "`n=== Migration API tests (base: $base) ===`n"

# Mục 2 - Apartment (Oid / buildingOid)
Test-Api "GetApartmentInfo (no params)" "$base/api/v2/apartment/GetApartmentInfo"
Test-Api "GetApartmentInfo (Oid only)" "$base/api/v2/apartment/GetApartmentInfo?Oid=00000000-0000-0000-0000-000000000001"
Test-Api "GetApartmentSearch (no params)" "$base/api/v2/apartment/GetApartmentSearch"
Test-Api "GetApartmentSearch (buildingOid)" "$base/api/v2/apartment/GetApartmentSearch?buildingOid=00000000-0000-0000-0000-000000000001"

# Mục 3 - Common / Elevator
Test-Api "GetFloorList (buildingOid)" "$base/api/v2/common/GetFloorList?buildingOid=00000000-0000-0000-0000-000000000001"
Test-Api "GetRoomList (buildingOid, floorOid)" "$base/api/v2/common/GetRoomList?buildingOid=00000000-0000-0000-0000-000000000001&floorOid=00000000-0000-0000-0000-000000000002"
Test-Api "GetBuildFloorList (buildingOid)" "$base/api/v2/elevatorBuilding/GetBuildFloorList?buildingOid=00000000-0000-0000-0000-000000000001&projectCd=TEST"

# Mục 4 - Card (cardOid)
Test-Api "GetCardInfo (cardOid)" "$base/api/v2/card/GetCardInfo?cardOid=00000000-0000-0000-0000-000000000001"

# Mục 5 - CardVehicle (cardVehicleOid)
Test-Api "GetVehicleCardInfoAsync (cardVehicleOid)" "$base/api/v2/card/GetVehicleCardInfoAsync?cardVehicleOid=00000000-0000-0000-0000-000000000001"
Test-Api "GetApartmentVehicleInfo (cardVehicleOid)" "$base/api/v2/vehicle/GetApartmentVehicleInfo?cardVehicleOid=00000000-0000-0000-0000-000000000001"
Test-Api "Vehicleresident GetVehicleInfo (cardVehicleOid)" "$base/api/v2/vehicleresident/GetVehicleInfo?cardVehicleOid=00000000-0000-0000-0000-000000000001"
Test-Api "VehiclePayment GetInfo (cardVehicleOid)" "$base/api/v2/vehicle-payment/GetInfo?cardVehicleOid=00000000-0000-0000-0000-000000000001"
Test-Api "CardVehicle GetInfo guest (cardVehicleOid)" "$base/api/v2/cardvehicle/GetInfo/guest?id=1&cardVehicleOid=00000000-0000-0000-0000-000000000001"
Test-Api "CardVehicle GetTicketInfo (cardVehicleOid)" "$base/api/v2/cardvehicle/GetTicketInfo?cardCd=TEST&id=1&cardVehicleOid=00000000-0000-0000-0000-000000000001"

Write-Host "`n=== Done ===`n"

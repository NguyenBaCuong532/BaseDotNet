# Checklist Test Migration (Hạng mục 10)

Tài liệu này dùng để test toàn bộ hệ thống sau các thay đổi migration (apartOid, buildingOid, floorOid, cardOid, cardVehicleOid).

**Cách triển khai:** Mục 1 (Build & chạy API) đã được chạy tự động; các mục 2–7 cần test thủ công qua **Swagger** (http://localhost:3090/swagger) hoặc script trong **Phụ lục** cuối file.

## 1. Kiểm tra Build

| Bước | Nội dung | Kết quả |
|------|----------|---------|
| 1.1 | `dotnet build UNI.RESIDENT.API\UNI.RESIDENT.API.csproj` | ✅ Pass |
| 1.2 | Chạy API: `dotnet run --project UNI.RESIDENT.API --launch-profile "UNI.Resident.API"` | ✅ Pass (API listen http://localhost:3090) |
| 1.3 | Swagger/health endpoint phản hồi bình thường | ✅ Pass (GET /swagger/v1/swagger.json → 200) |

**Lưu ý:** Build toàn solution (`UNI.RESIDENT.API.sln`) có thể lỗi do project dbSHome (SSDT) nếu không cài Visual Studio. Chỉ cần build project API là đủ cho chạy ứng dụng.

---

## 2. Apartment & Oid

| API / Hành vi | Tham số cũ | Tham số mới (oid) | Kết quả |
|---------------|------------|-------------------|---------|
| GetApartmentInfo | apartmentId | Oid (Guid) | ⬜ |
| DeleteApartmentAsync | apartmentId | Oid (Guid) | ⬜ |
| GetApartmentSearch | buildingCd | buildingOid | ⬜ |
| GetApartmentChangeRoomCodeInfo | buildingCd | buildingOid | ⬜ |
| GetFamilyMember / GetFamilyMemberByPhone | - | apartOid | ⬜ |
| GetHouseholdInfo | - | apartOid, Oid | ⬜ |
| GetViolationHistoryInfo | - | apartOid | ⬜ |

---

## 3. Building / Floor / Room

| API | Tham số cũ | Tham số mới (buildingOid, floorOid) | Kết quả |
|-----|------------|-------------------------------------|---------|
| GetFloorList | buildingCd | buildingOid | ⬜ |
| GetRoomList / GetRoomList2 | buildingCd, floorNo | buildingOid, floorOid | ⬜ |
| GetBuildFloorList / GetBuildFloorPage | buildingCd | buildingOid | ⬜ |
| FilterElevatorFloor | - | buildingOid | ⬜ |

---

## 4. Card (cardOid)

| API | Controller | Tham số mới | Kết quả |
|-----|------------|-------------|---------|
| GetCardInfo / GetEditCardInfo / GetCardLockInfo | CardController | cardOid | ⬜ |
| GetCardPage (FamilyCardRequestModel) | CardController | apartOid, cardOid trong filter | ⬜ |
| GetCardInfo | CardResidentController | apartOid, cardOid | ⬜ |
| GetResidentCardPage (FilterCardResident) | - | apartOid, cardOid | ⬜ |
| GetVehicleHistoryChange (VehicleHistoryChange) | CardDailyController | cardOid | ⬜ |
| GetCardInfo / DeleteCard / SetCardLocked | CardInternalController | cardOid | ⬜ |
| GetCardGuestInfo / DeleteCardAsync / SetCardLocked | CardGuestController | cardOid | ⬜ |

---

## 5. CardVehicle (cardVehicleOid)

| API | Controller | Tham số mới | Kết quả |
|-----|------------|-------------|---------|
| GetVehicleCardInfo | CardController | cardVehicleOid | ⬜ |
| SetVehicleLocked | CardController | cardVehicleOid | ⬜ |
| SetVehicleLockedWithReason (body) | CardController | VehicleLockRequest.CardVehicleOid | ⬜ |
| GetVehiclePaymentLoadForm | CardController | cardVehicleOid | ⬜ |
| DeleteVehicleCardAsync | CardController | cardVehicleOid | ⬜ |
| GetApartmentVehicleInfo | VehicleController | cardVehicleId, cardVehicleOid | ⬜ |
| GetVehicleInfo / GetVehicleLockInfo / SetVehicleLocked | VehicleResidentController | cardVehicleOid | ⬜ |
| DeleteVehicleInfo / GetCancelVehicleCardFields | VehicleResidentController | cardVehicleOid | ⬜ |
| GetVehicleInfo / SetVehicleLocked / DelVehicleInfo | VehicleInternalController | cardVehicleOid | ⬜ |
| GetVehicleInfo / SetVehicleLocked / DelVehicleInfo | VehicleGuestController | cardVehicleOid | ⬜ |
| GetInfo (payment) | VehiclePaymentController | cardVehicleOid | ⬜ |
| GetInfo (guest type) | CardVehicleController | cardVehicleOid | ⬜ |
| GetTicketInfo | CardVehicleController | cardVehicleOid | ⬜ |

---

## 6. Test backward compatibility

- Gọi các API **chỉ với tham số cũ** (apartmentId, cardVehicleId, buildingCd, …): kết quả giống trước migration.
- Gọi các API **với tham số mới (oid)** khi có dữ liệu: trả về đúng bản ghi tương ứng.
- Gọi **cùng lúc** tham số cũ và oid: ưu tiên oid (theo tài liệu migration).

| Kiểm tra | Kết quả |
|----------|---------|
| Chỉ dùng ID/Code cũ | ⬜ |
| Chỉ dùng Oid mới | ⬜ |
| Ưu tiên Oid khi truyền cả hai | ⬜ |

---

## 7. Database

| Bước | Nội dung | Kết quả |
|------|----------|---------|
| 7.1 | Đã chạy script migration 01–04, 08, 09 trên DB đích | ⬜ |
| 7.2 | Stored procedures đã deploy (sp_res_* đã cập nhật @cardVehicleOid, @cardOid, @apartOid, …) | ⬜ |
| 7.3 | MAS_CardVehicle.oid, MAS_Cards.oid, MAS_Apartments.oid có dữ liệu | ⬜ |

---

## Kết luận

- **Ngày test:** _điền khi chạy_
- **Người test:** _điền_
- **Môi trường:** Development / Staging / _
- **Kết quả tổng thể:** ⬜ Pass / ⬜ Fail (ghi chú lỗi vào từng dòng trên)

Sau khi hoàn tất checklist, cập nhật MIGRATION_GUIDE: Hạng mục 10 = ✅ Đã kiểm tra, ghi chú ngày và kết quả.

---

## Phụ lục: Gợi ý test nhanh (Swagger / PowerShell)

**Base URL (Development):** `http://localhost:3090`

- **Swagger UI:** http://localhost:3090/swagger — đăng nhập OAuth2 (JWT) rồi gọi từng API.
- Các API đều yêu cầu `Authorization: Bearer <token>`.

**Ví dụ PowerShell (sau khi có token):**

```powershell
$base = "http://localhost:3090"
$token = "YOUR_JWT_TOKEN"

# Mục 2 - Apartment (oid)
Invoke-RestMethod -Uri "$base/api/v2/apartment/GetApartmentInfo?Oid=<apartOid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/apartment/GetApartmentSearch?buildingOid=<guid>" -Headers @{ Authorization = "Bearer $token" }

# Mục 3 - Building/Floor/Room
Invoke-RestMethod -Uri "$base/api/v2/common/GetFloorList?buildingOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/common/GetRoomList?buildingOid=<guid>&floorOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/elevatorBuilding/GetBuildFloorList?buildingOid=<guid>&projectCd=..." -Headers @{ Authorization = "Bearer $token" }

# Mục 4 - Card (cardOid)
Invoke-RestMethod -Uri "$base/api/v2/card/GetCardInfo?CardCd=...&cardOid=<guid>" -Headers @{ Authorization = "Bearer $token" }

# Mục 5 - CardVehicle (cardVehicleOid)
Invoke-RestMethod -Uri "$base/api/v2/card/GetVehicleCardInfoAsync?cardVehicleOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/vehicle/GetApartmentVehicleInfo?cardVehicleOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/vehicleresident/GetVehicleInfo?cardVehicleOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/vehicle-payment/GetInfo?cardVehicleOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/cardvehicle/GetInfo/guest?id=<id>&cardVehicleOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "$base/api/v2/cardvehicle/GetTicketInfo?cardCd=...&id=<id>&cardVehicleOid=<guid>" -Headers @{ Authorization = "Bearer $token" }
```

Thay `<guid>`, `<id>`, `YOUR_JWT_TOKEN` bằng giá trị thực. Có thể dùng Swagger để lấy token và copy sang.

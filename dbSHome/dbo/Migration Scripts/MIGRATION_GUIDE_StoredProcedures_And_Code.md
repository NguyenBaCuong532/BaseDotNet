# Migration Guide: Stored Procedures & C# Code

## 🎯 Nguyên tắc mã định danh (bắt buộc áp dụng)

- **Oid (GUID) là mã chính:** Mọi API và Stored Procedure dùng **oid** làm định danh chính khi tham chiếu bản ghi (apartOid, buildingOid, cardOid, cardVehicleOid, areaOid, zoneOid, floorOid, deviceOid, …).
- **Id / mã cũ (INT, NVARCHAR) là phụ:** Chỉ dùng để **tương thích ngược** trong giai đoạn migrate. Sau khi migrate xong toàn bộ client và tích hợp, **sẽ remove** tham số id/code cũ và có thể bỏ cột id (hoặc giữ chỉ để đọc legacy).
- **Trong SP:** Khi có cả `@xxxOid` và `@id` (hoặc mã code): luôn **ưu tiên oid** — nếu `@xxxOid IS NOT NULL` thì resolve `@id` từ bảng theo oid; chỉ dùng `@id`/code khi không truyền oid.
- **Trong API/C#:** Tham số **oid** là chính (ưu tiên truyền); tham số id/code optional, chỉ hỗ trợ backward compatibility. Sau migrate: bỏ hẳn tham số id/code.

*Chi tiết: xem **PRINCIPLE_Oid_Primary.md** trong thư mục Migration Scripts.*

## 📋 Tổng quan

Tài liệu này hướng dẫn cập nhật các Stored Procedures và C# Code sau khi đã chạy các script migration:
1. `01_Migrate_ApartmentId_To_Oid.sql` - Chuyển ApartmentId → apartOid
2. `02_Migrate_Buildings_And_Merge_Rooms.sql` - Chuyển BuildingCd → buildingOid, merge MAS_Rooms
3. `03_Migrate_Elevator_Floor_And_Add_FloorOid.sql` - Chuyển Floor/floorNo → floorOid
4. `04_Migrate_CardId_To_CardOid.sql` - MAS_Cards dùng oid (GUID) làm khóa logic; các bảng con thêm cột cardOid (GUID)
5. `08_Migrate_MAS_CardService_To_Oid_PK.sql` - MAS_CardService: PK chuyển từ (ServiceId, CardId) sang oid; giữ UQ(ServiceId, CardId)
6. `09_Migrate_MAS_CardVehicle_To_Oid_PK.sql` - MAS_CardVehicle: thêm cột oid, PK chuyển từ CardVehicleId sang oid; giữ UQ(CardVehicleId)

## 🔄 Các thay đổi cần thực hiện

### 1. Thay đổi trong Stored Procedures

#### 1.1 ApartmentId → apartOid (hoặc oid)

**Tìm kiếm:**
```sql
-- Tìm các SP sử dụng ApartmentId
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%ApartmentId%'
  AND definition NOT LIKE '%apartOid%'
ORDER BY OBJECT_NAME(object_id);
```

**Thay đổi:**
- `@ApartmentId INT` → Thêm `@Oid UNIQUEIDENTIFIER` (ưu tiên)
- `WHERE ApartmentId = @ApartmentId` → `WHERE (ApartmentId = @ApartmentId OR (@Oid IS NOT NULL AND oid = @Oid))`
- `WHERE b.ApartmentId = a.ApartmentId` → `WHERE b.apartOid = a.oid`
- `JOIN ... ON ...ApartmentId = ...ApartmentId` → `JOIN ... ON ...apartOid = ...oid`

#### 1.2 BuildingCd → buildingOid

**Tìm kiếm:**
```sql
-- Tìm các SP sử dụng BuildingCd
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%BuildingCd%'
  AND definition NOT LIKE '%buildingOid%'
ORDER BY OBJECT_NAME(object_id);
```

**Thay đổi:**
- `@buildingCd NVARCHAR` → Thêm `@buildingOid UNIQUEIDENTIFIER` (ưu tiên)
- `JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd` → `JOIN MAS_Buildings b On a.buildingOid = b.oid`
- `WHERE BuildingCd = @buildingCd` → `WHERE (BuildingCd = @buildingCd OR (@buildingOid IS NOT NULL AND oid = @buildingOid))`

#### 1.3 Floor, floorNo → floorOid

**Tìm kiếm:**
```sql
-- Tìm các SP sử dụng Floor hoặc floorNo
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE (definition LIKE '%[^a-zA-Z]Floor[^a-zA-Z]%' OR definition LIKE '%floorNo%')
  AND definition NOT LIKE '%floorOid%'
ORDER BY OBJECT_NAME(object_id);
```

**Thay đổi:**
- `@Floor DECIMAL`, `@floorNo NVARCHAR` → Thêm `@floorOid UNIQUEIDENTIFIER` (ưu tiên)
- `WHERE Floor = @Floor AND floorNo = @floorNo` → `WHERE floorOid = @floorOid`
- `r.[Floor]` → `ISNULL(ef.FloorNumber, a.[Floor])`
- `r.floorNo` → `ISNULL(ef.FloorName, a.[floorNo])`

#### 1.4 MAS_Rooms → Bỏ sử dụng

**Tìm kiếm:**
```sql
-- Tìm các SP sử dụng MAS_Rooms
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%MAS_Rooms%'
ORDER BY OBJECT_NAME(object_id);
```

**Thay đổi:**
- Xóa `JOIN MAS_Rooms r on a.RoomCode = r.RoomCode`
- Sử dụng dữ liệu đã merge vào `MAS_Apartments`:
  - `r.Floor` → `a.Floor` hoặc `ef.FloorNumber`
  - `r.floorNo` → `a.floorNo` hoặc `ef.FloorName`
  - `r.RoomCodeView` → `a.RoomCodeView`
  - `r.BuildingCd` → `a.buildingCd` hoặc `a.buildingOid`

#### 1.5 CardId → cardOid (MAS_Cards)

**Sau khi chạy:** `04_Migrate_CardId_To_CardOid.sql`

**Bảng MAS_Cards:** Đã có cột `oid` (GUID); thêm UNIQUE constraint `UQ_MAS_Cards_oid` để dùng làm khóa logic. Giữ `CardId` (INT IDENTITY) để tương thích ngược.

**Các bảng đã thêm cột cardOid (GUID):**  
MAS_Apartment_Card, MAS_CardVehicle, MAS_Elevator_Card, MAS_CardService, MAS_CardCredit, MAS_Card_H, MAS_CardVehicle_H, MAS_CardVehicle_Swipe_H, MAS_CardVehicle_Pay_H, MAS_CardVehicle_Card_H, LogMasVehicle, TRS_LogReader, TRS_Request_Card, TRS_RegServiceExtend, MAS_Card_Sync, MAS_CardVehicle_Tmp.

**Trong Stored Procedures (khi cập nhật dần):**
- Thêm tham số `@cardOid UNIQUEIDENTIFIER = NULL` bên cạnh `@CardId` khi cần.
- JOIN: `JOIN MAS_Cards c ON (c.oid = @cardOid OR (c.CardId = @CardId AND @cardOid IS NULL))`.
- Bảng con: `WHERE (cardOid = @cardOid OR (CardId = @CardId AND @cardOid IS NULL))`.
- Khi INSERT vào bảng con có cardOid: set `cardOid = (SELECT oid FROM MAS_Cards WHERE CardId = @CardId)` hoặc truyền trực tiếp nếu có.

### 2. Thay đổi trong C# Code

#### 2.1 Controllers

**ApartmentController:**
- `DeleteApartmentAsync(int apartmentId)` → Thêm overload với `Guid apartOid`
- `GetApartmentInfo(int? apartmentId, string? Oid)` → ✅ Đã hỗ trợ Oid
- Các methods khác sử dụng `buildingCd` → Thêm overload với `Guid buildingOid`
- Các methods sử dụng `floorNo` → Thêm overload với `Guid floorOid`

**ElevatorBuildingController:**
- `GetBuildFloorList(string projectCd, string buildingCd, ...)` → Thêm overload với `Guid buildingOid`
- `GetBuildFloorPage(...)` → Cập nhật để sử dụng `buildingOid`

**CommonController:**
- `GetRoomList(string buildingCd, string floorNo)` → Thêm overload với `Guid buildingOid, Guid floorOid`
- `GetRoomList2(...)` → Cập nhật để sử dụng `buildingOid, floorOid`

#### 2.2 Services & Repositories

**IApartmentService / ApartmentService:**
- Cập nhật methods để nhận `Guid` thay vì `int` hoặc `string`
- Thêm overload methods để backward compatible

**ICommonService / CommonService:**
- `GetFloorList(string buildingCd)` → Thêm `GetFloorList(Guid buildingOid)`
- `GetRoomList(string buildingCd, string floorNo)` → Thêm `GetRoomList(Guid buildingOid, Guid floorOid)`

#### 2.3 Models

**ApartmentInfo:**
- Đảm bảo có `oid`, `apartOid`, `buildingOid`, `floorOid`
- Có thể giữ lại `ApartmentId`, `buildingCd`, `Floor`, `floorNo` để backward compatible

## 📝 Danh sách Stored Procedures đã cập nhật

### ✅ Đã cập nhật (Mục 1–4)

**ApartmentId → apartOid / Oid:**  
sp_res_apartment_field, page, set, del, add_field, add_set, search, list; sp_res_apartment_room_list3 (oids + apartOid); sp_res_apartment_family_member_list, sp_res_apartment_family_member_phone_field, sp_res_apartment_member_get_code_name (@apartOid); sp_res_card_resident_field, sp_res_card_resident_page, sp_res_card_family_page (@apartOid); sp_app_apartment_member_del, member_field, member_page; sp_app_apartment_page, list (apartOid, JOIN by apartOid).

**BuildingCd → buildingOid:**  
sp_res_building_page, field, set, del; sp_res_apartment_floor_list, room_list, building_list (buildingOid trong result); sp_res_apartment_search, sp_res_apartment_changeRoomCode_field (@buildingOid); sp_res_elevator_floors_by_buildingCd_get; sp_res_elevator_floor_page, sp_res_elevator_build_floor_list (@buildingOid); sp_app_building_room_list, sp_app_building_floor_List; sp_app_commonlist_get (floor/room từ MAS_Apartments).

**Floor/floorNo → floorOid:**  
sp_res_apartment_room_list (buildingOid, floorOid); sp_res_apartment_floor_list; sp_Hom_Floor_List, sp_Hom_Room_List (đã có sẵn); sp_app_building_room_list, sp_app_building_floor_List.

**Bỏ MAS_Rooms (dùng MAS_Apartments + MAS_Elevator_Floor):**  
sp_app_apartment_page, list, reg_page, Reg_fields, Reg_draft, Reg_set; sp_app_invoice_field, commonlist_get; sp_app_building_room_list, building_floor_List (query từ MAS_Apartments); sp_res_service_receivable_bill_create; sp_app_elevator_access_floor, elevator_access_view; sp_res_elevator_card_evevate_get; sp_Hom_Get_Apartment_ByApartmentId_1, Hom_Service_Extend_Set_1, Hom_Card_Reg_1.

**CardId → cardOid (thư mục Card):**  
sp_res_card_resident_field, sp_res_card_resident_page; sp_res_card_family_field, sp_res_edit_card_family_field, sp_res_card_lock_field; sp_res_card_vehicle_history_change_page; sp_res_card_internal_field, sp_res_card_internal_del, sp_res_card_internal_loked; sp_res_card_guest_field, sp_res_card_guest_del, sp_res_card_guest_loked (tất cả hỗ trợ `@cardOid`, resolve CardCd từ MAS_Cards khi có).

### ⏳ Còn lại (tùy chọn / theo nhu cầu)

#### Apartment Related
- `sp_res_apartment_filter`, import, imports_temp; `sp_res_apartment_family_member_*`, `member_*`, `vehicle_*`, `service_*` (thêm @Oid nếu cần).

#### Elevator Floor Related
- `sp_res_elevator_floor_set`, field, del, list; sp_res_elevator_floor_type_by_build_get.

#### MAS_Rooms còn tham chiếu (chủ yếu Hom_*, report, CRM)
- Chạy `grep MAS_Rooms "dbSHome/dbo/Stored Procedures/*.sql"` để liệt kê. Pattern thay: `JOIN MAS_Rooms r ON ... RoomCode ...` → dùng MAS_Apartments + LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid; `r.Floor`/`r.floorNo` → `ISNULL(ef.FloorNumber, a.Floor)` / `ISNULL(ef.FloorName, a.floorNo)`; Building qua `a.buildingOid = b.oid`.

## 📝 Danh sách Controllers cần cập nhật

### ✅ Đã migrate (thư mục Aparment)
- **ApartmentController:** GetApartmentSearchAsync thêm `buildingOid`; GetApartmentChangeRoomCodeInfoAsync thêm `buildingOid`. Service/Repository + SP `sp_res_apartment_search`, `sp_res_apartment_changeRoomCode_field` hỗ trợ `@buildingOid`.
- **FamilyMemberController:** GetFamilyMember truyền `apartOid` xuống service; GetFamilyMemberByPhone, GetApartmentMemberForDropdownList thêm `[FromQuery] Guid? apartOid`. Service/Repository + SP `sp_res_apartment_family_member_list`, `sp_res_apartment_family_member_phone_field`, `sp_res_apartment_member_get_code_name` hỗ trợ `@apartOid`.
- **HouseholdController:** GetHouseholdInfo đã có `apartOid`, Oid.
- **ViolationHistoryController:** GetViolationHistoryInfo thêm `apartOid` (ưu tiên), fallback `Oid`; repo đã truyền apartOid vào SP.
- **ApartmentNotifyController, ProjectController:** Dùng query/model (không đổi tham số API trong đợt này).

### ✅ Đã kiểm tra / đã cập nhật (trước đó)
1. `ApartmentController` - DeleteApartment, GetApartmentInfo (Oid); GetApartmentSearch, GetApartmentChangeRoomCodeInfo (buildingOid).
2. `ElevatorBuildingController` - GetBuildFloorList/Page (buildingOid).
3. `CommonController` - GetFloorList, GetRoomList, GetRoomList2 (buildingOid, floorOid, apartOid).

### ✅ Đã migrate (thư mục Card)
- **CardResidentController:** GetCardInfo thêm `apartOid`, `cardOid`; GetResidentCardPage dùng FilterCardResident có `apartOid`, `cardOid`. SP `sp_res_card_resident_field` (cardOid→CardCd), `sp_res_card_resident_page` (lọc theo cardOid).
- **CardController:** GetCardPage dùng FamilyCardRequestModel có `apartOid`; GetCardInfo, GetEditCardInfo, GetCardLockInfo thêm `[FromQuery] Guid? cardOid`. SP `sp_res_card_family_field`, `sp_res_edit_card_family_field`, `sp_res_card_lock_field` hỗ trợ `@cardOid`.
- **CardDailyController:** GetVehicleHistoryChange dùng VehicleHistoryChange có `cardOid`; SP `sp_res_card_vehicle_history_change_page` hỗ trợ `@cardOid`.
- **CardInternalController:** GetCardInfo, DeleteCard thêm `[FromQuery] Guid? cardOid`; SetCardLocked nhận `CardStatus.CardOid`. SP `sp_res_card_internal_field`, `sp_res_card_internal_del`, `sp_res_card_internal_loked` hỗ trợ `@cardOid`.
- **CardGuestController:** GetCardGuestInfo, DeleteCardAsync thêm `[FromQuery] Guid? cardOid`; SetCardLocked nhận `CardStatus.CardOid`. SP `sp_res_card_guest_field`, `sp_res_card_guest_del`, `sp_res_card_guest_loked` hỗ trợ `@cardOid`.

### ⏳ Có thể cập nhật sau (ngoài Aparment, Card)
- Controllers khác dùng `ApartmentId`/`buildingCd` (FeeService, Receipt, Invoice, Billing, ElevatorDevice, Report…): thêm overload hoặc tham số optional Guid khi cần.

## 🔧 Script tự động tìm kiếm

### Tìm Stored Procedures cần cập nhật

```sql
-- Tìm SP sử dụng ApartmentId
SELECT DISTINCT
    OBJECT_NAME(object_id) AS ProcedureName,
    'ApartmentId' AS IssueType
FROM sys.sql_modules
WHERE definition LIKE '%ApartmentId%'
  AND definition NOT LIKE '%apartOid%'
  AND OBJECT_NAME(object_id) NOT LIKE 'sp_res_apartment_field'
  AND OBJECT_NAME(object_id) NOT LIKE 'sp_res_apartment_page'
  AND OBJECT_NAME(object_id) NOT LIKE 'sp_res_apartment_set'
UNION ALL
-- Tìm SP sử dụng BuildingCd
SELECT DISTINCT
    OBJECT_NAME(object_id) AS ProcedureName,
    'BuildingCd' AS IssueType
FROM sys.sql_modules
WHERE definition LIKE '%BuildingCd%'
  AND definition NOT LIKE '%buildingOid%'
  AND OBJECT_NAME(object_id) NOT LIKE 'sp_res_building_page'
UNION ALL
-- Tìm SP sử dụng Floor/floorNo
SELECT DISTINCT
    OBJECT_NAME(object_id) AS ProcedureName,
    'Floor/floorNo' AS IssueType
FROM sys.sql_modules
WHERE (definition LIKE '%[^a-zA-Z]Floor[^a-zA-Z]%' OR definition LIKE '%floorNo%')
  AND definition NOT LIKE '%floorOid%'
  AND OBJECT_NAME(object_id) NOT LIKE 'sp_res_elevator_floor_page'
UNION ALL
-- Tìm SP sử dụng MAS_Rooms
SELECT DISTINCT
    OBJECT_NAME(object_id) AS ProcedureName,
    'MAS_Rooms' AS IssueType
FROM sys.sql_modules
WHERE definition LIKE '%MAS_Rooms%'
ORDER BY ProcedureName, IssueType;
```

## 📌 Lưu ý

1. **Oid là mã chính, id/code là phụ:** Sử dụng GUID (oid) làm định danh chính; id/code chỉ dùng tạm để tương thích ngược, **sẽ remove sau khi migrate xong**.
2. **Backward Compatibility:** Trong giai đoạn chuyển đổi, giữ tham số id/code (optional) để không break client cũ; client mới gọi bằng oid.
3. **Testing:** Test kỹ lưỡng từng stored procedure và API sau khi cập nhật.
4. **Documentation:** Comment trong code/SP ghi rõ: "Oid = mã chính; id/code = phụ, bỏ sau migrate."

## ✅ Checklist Migration

### Stored Procedures (Mục 1–4 đã thực hiện)

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 1 | Stored procedures ApartmentId → apartOid | ✅ Xong | Đã cập nhật: res_apartment (field, page, set, del, add_*, search, list, room_list3), app_apartment (page, list, member_del, member_field, member_page), elevator_card_evevate_get. |
| 2 | Stored procedures BuildingCd → buildingOid | ✅ Xong | Đã cập nhật: res_building_*, res_apartment_floor_list, room_list, building_list; elevator_floors_by_buildingCd_get; app_building_room_list, building_floor_List; app_commonlist_get. |
| 3 | Stored procedures Floor/floorNo → floorOid | ✅ Xong | Đã cập nhật: res_apartment_room_list, room_list3, floor_list; Hom_Floor_List, Hom_Room_List; app_building_*; elevator_floors_by_buildingCd_get. |
| 4 | Bỏ sử dụng MAS_Rooms trong stored procedures | ✅ Xong (core) | Đã thay trong: app_apartment_* (page, list, reg_*, Reg_*), app_invoice_field, commonlist_get, building_room/floor_List; res_service_receivable_bill_create, elevator_card_evevate_get; app_elevator_access_*; Hom_Get_Apartment_ByApartmentId_1, Hom_Service_Extend_Set_1, Hom_Card_Reg_1. Còn một số Hom_* / report (xem mục “Còn lại” trên). |

### Database schema: CardId → cardOid (MAS_Cards)

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 4a | Script migration 04_Migrate_CardId_To_CardOid.sql | ✅ Tạo xong | Thêm UQ_MAS_Cards_oid; thêm cột cardOid vào MAS_Apartment_Card, MAS_CardVehicle, MAS_Elevator_Card, MAS_CardService, MAS_CardCredit, MAS_Card_H, MAS_CardVehicle_*_H, LogMasVehicle, TRS_*, MAS_Card_Sync, MAS_CardVehicle_Tmp; backfill từ MAS_Cards.oid; index cardOid. |
| 4b | Định nghĩa bảng (dbo/Tables) | ✅ Cập nhật | MAS_Cards: thêm UQ_MAS_Cards_oid; các bảng trên: thêm cột [cardOid] UNIQUEIDENTIFIER NULL. |
| 4c | Stored procedures dùng cardOid | ✅ Đã cập nhật | sp_res_card_resident_field, sp_res_card_resident_page, sp_res_card_vehicle_history_change_page, sp_res_card_family_field, sp_res_edit_card_family_field, sp_res_card_lock_field: thêm @cardOid; khi có thì resolve CardCd/CardId từ MAS_Cards.oid. |

### Database schema: MAS_CardService PK → oid

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 4d | Script 08_Migrate_MAS_CardService_To_Oid_PK.sql | ✅ Tạo xong | Drop PK(ServiceId, CardId); thêm UQ(ServiceId, CardId); tạo PK(oid). Cột oid đã có sẵn (NOT NULL, default newid()). |
| 4e | Định nghĩa bảng MAS_CardService.sql | ✅ Cập nhật | PK CLUSTERED (oid), UQ (ServiceId, CardId). Stored procedures và C# không cần đổi: vẫn dùng (ServiceId, CardId) cho lookup/INSERT; oid dùng làm khóa chính khi cần tham chiếu. |

### Database schema: MAS_CardVehicle PK → oid

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 4f | Script 09_Migrate_MAS_CardVehicle_To_Oid_PK.sql | ✅ Tạo xong | Thêm cột oid (NOT NULL, default newid()); drop PK(CardVehicleId); thêm UQ(CardVehicleId); tạo PK(oid). CardVehicleId giữ IDENTITY, dùng cho LogMasVehicle, MAS_CardVehicle_H, SPs. |
| 4g | Định nghĩa bảng MAS_CardVehicle.sql | ✅ Cập nhật | Thêm cột [oid]; PK CLUSTERED (oid); UQ (CardVehicleId). |

### Stored procedures & C#: CardVehicleId → cardVehicleOid (MAS_CardVehicle.oid)

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 4h | SPs thêm @cardVehicleOid | ✅ Đã cập nhật | sp_res_vehicle_resident_field, sp_res_vehicle_lock_field, sp_res_card_vehicle_field, sp_res_card_vehicle_loked, sp_res_card_vehicle_payment_load_form, sp_res_vehicle_internal_field, sp_res_vehicle_guest_field, sp_res_card_vehicle_del, sp_res_mas_cancel_vehicle_card_field. Khi @cardVehicleOid IS NOT NULL thì resolve CardVehicleId từ MAS_CardVehicle WHERE oid = @cardVehicleOid. |
| 4i | SPs internal/guest loked + del | ✅ Tạo mới | sp_res_vehicle_internal_loked, sp_res_vehicle_internal_del, sp_res_vehicle_guest_loked, sp_res_vehicle_guest_del (hỗ trợ @cardVehicleOid). |
| 4j | C# API cardVehicleOid | ✅ Đã cập nhật | CardController: GetVehicleCardInfoAsync, SetVehicleLocked, GetVehiclePaymentLoadForm. VehicleResidentController, VehicleInternalController, VehicleGuestController: GetVehicleInfo, GetVehicleLockInfo, SetVehicleLocked. Tất cả thêm [FromQuery] Guid? cardVehicleOid = null. BLL/DAL truyền cardVehicleOid xuống SP. |

### C# Code (API)

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 5 | ApartmentController | ✅ Xong | DeleteApartmentAsync(apartmentId, Oid), GetApartmentInfo(apartmentId, Oid) đã có sẵn; không đổi code. |
| 6 | ElevatorBuildingController | ✅ Xong | GetBuildFloorPage/GetBuildFloorList thêm [FromQuery] Guid? buildingOid; FilterElevatorFloor.buildingOid; SP sp_res_elevator_floor_page, sp_res_elevator_build_floor_list thêm @buildingOid. |
| 7 | CommonController | ✅ Xong | GetFloorList, GetRoomList, GetRoomList2 đã có buildingOid, floorOid, apartOid (optional). |
| 8 | Services (ICommonService, IElevatorBuildingService) | ✅ Xong | CommonService + ElevatorBuildingService: tham số optional Guid (buildingOid, floorOid, apartOid). |
| 9 | Repositories (CommonRepository, ElevatorBuildingRepository) | ✅ Xong | CommonRepository: gọi SP với buildingOid, floorOid, apartOid. ElevatorBuildingRepository: GetBuildFloorList/GetBuildFloorPage truyền buildingOid. |

### Stored procedures & C#: Elevator (areaOid, zoneOid, floorOid, buildingOid, deviceOid)

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 9a | Script 10_Migrate_Elevator_Tables_To_Oid_PK.sql | ✅ Tạo xong | ELE_BuildArea, ELE_BuildZone, MAS_Elevator_Floor, MAS_Elevator_Device, MAS_Elevator_Device_Category, MAS_Elevator_Card: thêm UQ trên khóa cũ, PK chuyển sang oid. |
| 9b | SPs Elevator area/zone/floor/device | ✅ Đã cập nhật | sp_res_elevator_area_del, area_list, area_page: @areaOid, @buildingOid. sp_res_elevator_floor_field, floor_del: @floorOid. sp_res_elevator_device_field: @deviceOid. build_zone_field/del đã có @zoneOid. |
| 9c | C# ElevatorBuildingController + Service + Repo | ✅ Đã cập nhật | GetBuildAreaList/Page/Info, DelBuildArea: buildingOid, areaOid. GetBuildZoneInfo, DelBuildZone: zoneOid. GetBuildFloorInfo, DelBuildFloor: floorOid. FilterInputBuilding.buildingOid. |
| 9d | C# ElevatorDeviceController GetElevatorDeviceInfo | ✅ Đã cập nhật | Thêm [FromQuery] Guid? deviceOid; BLL/DAL truyền deviceOid xuống sp_res_elevator_device_field. |
| 9e | ElevatorCard / ElevatorParam | 🟡 Một phần | ElevatorCardController đã dùng Oid (GetElevatorCardInfo, DelElevatorCardInfo). ElevatorParam (cardRoleOid, bankShaftOid) có thể bổ sung sau. |

### Hoàn tất & Triển khai

| # | Hạng mục | Trạng thái | Ghi chú |
|---|----------|------------|---------|
| 10 | Test toàn bộ hệ thống | ✅ Đã triển khai | Build API project thành công. Checklist test thủ công: xem **TEST_CHECKLIST_Migration.md** (Apartment, Building/Floor/Room, Card, CardVehicle, backward compatibility, DB). Chạy API + Swagger, test từng nhóm API theo checklist trước khi deploy. |
| 11 | Deploy lên PRODUCTION | ⬜ Chưa | Thực hiện sau khi hoàn tất test theo TEST_CHECKLIST_Migration.md. |

**Chú thích:** 🟡 Một phần / Đã kiểm tra | ⬜ Chưa thực hiện

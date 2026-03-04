# Migration Script: Buildings & Merge Rooms

## 📋 Mục đích

Script này thực hiện 3 công việc chính:

1. **Chuyển Primary Key của MAS_Buildings** từ `BuildingCd` (NVARCHAR) → `oid` (UNIQUEIDENTIFIER/GUID)
2. **Merge dữ liệu từ MAS_Rooms vào MAS_Apartments** và bỏ bảng `MAS_Rooms`
3. **Thêm `buildingOid`** vào `MAS_Apartments` và `MAS_Apartments_Save` để liên kết với `MAS_Buildings`

## 🎯 Các bước thực hiện

### Bước 1: Chuyển Primary Key của MAS_Buildings
- Xóa Primary Key cũ (`PK_MAS_Buildings` trên `BuildingCd`)
- Tạo Primary Key mới trên `oid`
- Tạo Unique Index cho `BuildingCd` để backward compatibility

### Bước 2: Thêm cột `buildingOid`
- Thêm cột `buildingOid` (UNIQUEIDENTIFIER, NULLABLE) vào:
  - `MAS_Apartments`
  - `MAS_Apartments_Save`

### Bước 3: Populate `buildingOid`
- Cập nhật giá trị `buildingOid` từ `buildingCd` bằng cách join với `MAS_Buildings.oid`

### Bước 4: Merge dữ liệu từ MAS_Rooms
- Merge các trường từ `MAS_Rooms` vào `MAS_Apartments` qua `RoomCode`:
  - `Floor` (DECIMAL) - Tầng
  - `WallArea` (FLOAT) - Diện tích tường
  - `WaterwayArea` (FLOAT) - Diện tích đường nước
  - `floorNo` (NVARCHAR) - Số tầng
  - `RoomCodeView` (NVARCHAR) - Mã phòng hiển thị
  - `BuildingCd` và `buildingOid` (nếu chưa có)

### Bước 5: Tạo Index
- Tạo Non-Clustered Index cho `buildingOid` trên các bảng

### Bước 6: Tạo Foreign Key
- Tạo Foreign Key constraint từ `buildingOid` → `MAS_Buildings.oid`

## 📊 Cấu trúc dữ liệu

### MAS_Buildings
- **PK cũ**: `BuildingCd` (NVARCHAR(50))
- **PK mới**: `oid` (UNIQUEIDENTIFIER)
- **Đã có**: `oid`, `tenant_oid`

### MAS_Rooms (sẽ bỏ)
- **PK**: `RoomCode` (NVARCHAR(50))
- **Các trường sẽ merge**: `Floor`, `WallArea`, `WaterwayArea`, `floorNo`, `RoomCodeView`, `BuildingCd`

### MAS_Apartments
- **Thêm mới**: `buildingOid` (UNIQUEIDENTIFIER)
- **Thêm mới**: `Floor` (DECIMAL(18,2))
- **Thêm mới**: `floorNo` (NVARCHAR(50))
- **Thêm mới**: `RoomCodeView` (NVARCHAR(50))
- **Cập nhật**: `WallArea`, `WaterwayArea`, `buildingCd`, `buildingOid` từ MAS_Rooms

### MAS_Apartments_Save
- **Thêm mới**: `buildingOid` (UNIQUEIDENTIFIER)

## ⚠️ Lưu ý quan trọng

### Trước khi chạy script

1. **Backup Database**
   ```sql
   BACKUP DATABASE [dbSHome] 
   TO DISK = 'C:\Backup\dbSHome_Before_Buildings_Migration_' + CONVERT(VARCHAR, GETDATE(), 112) + '.bak'
   WITH COMPRESSION, INIT;
   ```

2. **Test trên môi trường DEV/STAGING trước**
   - Không chạy trực tiếp lên PRODUCTION
   - Test kỹ lưỡng trên môi trường non-production

3. **Kiểm tra dữ liệu**
   - Đảm bảo tất cả `MAS_Buildings` có `oid` không NULL
   - Đảm bảo không có `oid` trùng lặp
   - Kiểm tra quan hệ giữa `MAS_Rooms` và `MAS_Apartments` qua `RoomCode`

4. **Thông báo team**
   - Thông báo cho team phát triển về thời gian migration
   - Có thể cần downtime nếu dữ liệu lớn

### Trong khi chạy script

- Script được thiết kế **idempotent** - có thể chạy nhiều lần an toàn
- Script sử dụng **Transaction** - nếu có lỗi sẽ tự động rollback
- Theo dõi output để biết tiến trình

### Sau khi chạy script

1. **Kiểm tra dữ liệu đã merge**
   ```sql
   -- Kiểm tra số lượng bản ghi đã được merge
   SELECT 
       'MAS_Apartments' AS TableName,
       COUNT(*) AS TotalRows,
       SUM(CASE WHEN buildingOid IS NULL THEN 1 ELSE 0 END) AS NullBuildingOid,
       SUM(CASE WHEN Floor IS NULL THEN 1 ELSE 0 END) AS NullFloor,
       SUM(CASE WHEN floorNo IS NULL OR floorNo = '' THEN 1 ELSE 0 END) AS NullFloorNo
   FROM MAS_Apartments;
   ```

2. **Kiểm tra Foreign Key**
   ```sql
   -- Kiểm tra FK đã được tạo
   SELECT 
       fk.name AS ForeignKeyName,
       OBJECT_NAME(fk.parent_object_id) AS TableName,
       COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName
   FROM sys.foreign_keys fk
   INNER JOIN sys.foreign_key_columns fc ON fk.object_id = fc.constraint_object_id
   WHERE fk.name LIKE '%buildingOid%'
   ORDER BY TableName;
   ```

3. **Kiểm tra Primary Key của MAS_Buildings**
   ```sql
   -- Kiểm tra PK của MAS_Buildings
   SELECT 
       kc.name AS ConstraintName,
       c.name AS ColumnName,
       ty.name AS DataType
   FROM sys.key_constraints kc
   INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
   INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
   INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
   WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID('dbo.MAS_Buildings');
   ```

4. **So sánh dữ liệu giữa MAS_Rooms và MAS_Apartments**
   ```sql
   -- Kiểm tra dữ liệu đã merge đúng chưa
   SELECT 
       r.RoomCode,
       r.Floor AS Rooms_Floor,
       a.Floor AS Apartments_Floor,
       r.WallArea AS Rooms_WallArea,
       a.WallArea AS Apartments_WallArea,
       r.WaterwayArea AS Rooms_WaterwayArea,
       a.WaterwayArea AS Apartments_WaterwayArea,
       r.floorNo AS Rooms_floorNo,
       a.floorNo AS Apartments_floorNo
   FROM MAS_Rooms r
   LEFT JOIN MAS_Apartments a ON r.RoomCode = a.RoomCode
   WHERE a.RoomCode IS NOT NULL;
   ```

## 🔄 Các bước tiếp theo

### 1. Cập nhật Stored Procedures

Tìm và cập nhật tất cả Stored Procedures sử dụng `BuildingCd`:

```sql
-- Tìm SP sử dụng BuildingCd
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%BuildingCd%'
  AND definition NOT LIKE '%buildingOid%';
```

**Ví dụ cập nhật:**
```sql
-- Trước
WHERE buildingCd = @BuildingCd

-- Sau
WHERE buildingOid = @buildingOid
```

### 2. Cập nhật Application Code

- **Repository Layer**: Cập nhật methods sử dụng `BuildingCd`
- **Service Layer**: Cập nhật business logic
- **API Controllers**: Cập nhật endpoints
- **Models**: Cập nhật model classes

**Ví dụ C#:**
```csharp
// Trước
public async Task<List<ApartmentInfo>> GetApartmentsByBuilding(string buildingCd)
{
    return await _repository.GetApartmentsByBuilding(buildingCd);
}

// Sau
public async Task<List<ApartmentInfo>> GetApartmentsByBuilding(Guid buildingOid)
{
    return await _repository.GetApartmentsByBuilding(buildingOid);
}
```

### 3. Xóa bảng MAS_Rooms (Sau khi đảm bảo)

**⚠️ CHỈ XÓA SAU KHI:**
- Đã kiểm tra dữ liệu merge đúng
- Đã cập nhật tất cả Stored Procedures
- Đã cập nhật tất cả Application Code
- Đã test kỹ lưỡng trên môi trường production
- Đã có backup và rollback plan

```sql
-- Kiểm tra xem còn sử dụng MAS_Rooms không
SELECT 
    OBJECT_NAME(object_id) AS ObjectName,
    type_desc AS ObjectType,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%MAS_Rooms%';

-- Nếu không còn sử dụng, có thể xóa
-- DROP TABLE [dbo].[MAS_Rooms];
```

### 4. Xóa cột buildingCd (Tùy chọn)

**⚠️ CHỈ XÓA SAU KHI:**
- Đã cập nhật tất cả Stored Procedures
- Đã cập nhật tất cả Application Code
- Đã test kỹ lưỡng trên môi trường production
- Đã có backup và rollback plan

```sql
-- Ví dụ xóa cột buildingCd (CHỈ CHẠY KHI CHẮC CHẮN)
-- ALTER TABLE [dbo].[MAS_Apartments]
-- DROP COLUMN [buildingCd];
```

## 📝 Rollback Plan

Nếu cần rollback:

1. **Khôi phục từ backup**
   ```sql
   RESTORE DATABASE [dbSHome] 
   FROM DISK = 'C:\Backup\dbSHome_Before_Buildings_Migration_YYYYMMDD.bak'
   WITH REPLACE;
   ```

2. **Hoặc revert thủ công:**
   - Xóa Foreign Key mới
   - Xóa cột `buildingOid`
   - Khôi phục Primary Key cũ trên `BuildingCd`
   - Khôi phục dữ liệu từ backup nếu đã xóa `MAS_Rooms`

## ✅ Checklist

- [ ] Backup database
- [ ] Test trên DEV/STAGING
- [ ] Kiểm tra dữ liệu trước migration
- [ ] Kiểm tra quan hệ giữa MAS_Rooms và MAS_Apartments
- [ ] Chạy script migration
- [ ] Kiểm tra dữ liệu sau migration
- [ ] Kiểm tra Foreign Key
- [ ] Kiểm tra Primary Key của MAS_Buildings
- [ ] So sánh dữ liệu đã merge
- [ ] Cập nhật Stored Procedures
- [ ] Cập nhật Application Code
- [ ] Test toàn bộ hệ thống
- [ ] Xóa bảng MAS_Rooms (nếu đã đảm bảo)
- [ ] Deploy lên PRODUCTION (nếu đã test OK)

## 📞 Liên hệ

Nếu có vấn đề trong quá trình migration, vui lòng liên hệ team Database hoặc Development Team.

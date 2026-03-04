# Migration Script: Elevator Floor & Add FloorOid

## 📋 Mục đích

Script này thực hiện các công việc sau:

1. **Thêm `buildingOid` vào MAS_Elevator_Floor** và populate từ `buildingCd`
2. **Chuyển Primary Key của MAS_Elevator_Floor** từ `Id` (INT IDENTITY) → `oid` (UNIQUEIDENTIFIER/GUID)
3. **Thêm `floorOid` vào MAS_Apartments** để thay thế cho `Floor` và `floorNo`
4. **Populate `floorOid`** từ `Floor` và `floorNo` bằng cách match với `MAS_Elevator_Floor`

## 🎯 Các bước thực hiện

### Bước 1: Thêm buildingOid vào MAS_Elevator_Floor
- Thêm cột `buildingOid` (UNIQUEIDENTIFIER, NULLABLE)

### Bước 2: Populate buildingOid
- Cập nhật giá trị `buildingOid` từ `buildingCd` bằng cách join với `MAS_Buildings.oid`

### Bước 3: Chuyển Primary Key của MAS_Elevator_Floor
- Xóa Primary Key cũ (`PK_MAS_Elevator_Floor` trên `Id`)
- Tạo Primary Key mới trên `oid`
- Tạo Unique Index cho `Id` để backward compatibility

### Bước 4-5: Tạo Index và Foreign Key cho buildingOid
- Tạo Non-Clustered Index cho `buildingOid`
- Tạo Foreign Key từ `buildingOid` → `MAS_Buildings.oid`

### Bước 6: Thêm floorOid vào MAS_Apartments
- Thêm cột `floorOid` (UNIQUEIDENTIFIER, NULLABLE)

### Bước 7: Populate floorOid
- Match theo `buildingCd` + `FloorNumber` = `Floor` (nếu Floor là số nguyên)
- Match theo `buildingCd` + `FloorName` = `floorNo`
- Match theo `buildingOid` + `FloorNumber` = `Floor` (nếu đã có buildingOid)
- Match theo `buildingOid` + `FloorName` = `floorNo`

### Bước 8-9: Tạo Index và Foreign Key cho floorOid
- Tạo Non-Clustered Index cho `floorOid`
- Tạo Foreign Key từ `floorOid` → `MAS_Elevator_Floor.oid`

## 📊 Cấu trúc dữ liệu

### MAS_Elevator_Floor
- **PK cũ**: `Id` (INT IDENTITY)
- **PK mới**: `oid` (UNIQUEIDENTIFIER)
- **Thêm mới**: `buildingOid` (UNIQUEIDENTIFIER)
- **Đã có**: `oid`, `tenant_oid`, `buildingCd`, `FloorNumber`, `FloorName`

### MAS_Apartments
- **Thêm mới**: `floorOid` (UNIQUEIDENTIFIER) - **Thay thế cho `Floor` và `floorNo`**
- **Có sẵn**: `Floor` (DECIMAL), `floorNo` (NVARCHAR), `buildingCd`, `buildingOid`

## 🔗 Logic Match floorOid

Script sẽ match `floorOid` theo thứ tự ưu tiên:

1. **Match theo FloorNumber = Floor** (nếu Floor là số nguyên)
   ```sql
   WHERE buildingCd = buildingCd AND FloorNumber = CAST(Floor AS INT)
   ```

2. **Match theo FloorName = floorNo**
   ```sql
   WHERE buildingCd = buildingCd AND FloorName = floorNo
   ```

3. **Match theo buildingOid + FloorNumber** (nếu đã có buildingOid)
   ```sql
   WHERE buildingOid = buildingOid AND FloorNumber = CAST(Floor AS INT)
   ```

4. **Match theo buildingOid + FloorName**
   ```sql
   WHERE buildingOid = buildingOid AND FloorName = floorNo
   ```

## ⚠️ Lưu ý quan trọng

### Trước khi chạy script

1. **Backup Database**
   ```sql
   BACKUP DATABASE [dbSHome] 
   TO DISK = 'C:\Backup\dbSHome_Before_Elevator_Floor_Migration_' + CONVERT(VARCHAR, GETDATE(), 112) + '.bak'
   WITH COMPRESSION, INIT;
   ```

2. **Test trên môi trường DEV/STAGING trước**
   - Không chạy trực tiếp lên PRODUCTION
   - Test kỹ lưỡng trên môi trường non-production

3. **Kiểm tra dữ liệu**
   - Đảm bảo tất cả `MAS_Elevator_Floor` có `oid` không NULL
   - Đảm bảo không có `oid` trùng lặp
   - Kiểm tra dữ liệu `Floor` và `floorNo` trong `MAS_Apartments` có thể match với `MAS_Elevator_Floor`

4. **Thông báo team**
   - Thông báo cho team phát triển về thời gian migration
   - Có thể cần downtime nếu dữ liệu lớn

### Trong khi chạy script

- Script được thiết kế **idempotent** - có thể chạy nhiều lần an toàn
- Script sử dụng **Transaction** - nếu có lỗi sẽ tự động rollback
- Theo dõi output để biết tiến trình

### Sau khi chạy script

1. **Kiểm tra dữ liệu đã populate**
   ```sql
   -- Kiểm tra số lượng bản ghi đã được populate
   SELECT 
       'MAS_Elevator_Floor' AS TableName,
       COUNT(*) AS TotalRows,
       SUM(CASE WHEN buildingOid IS NULL THEN 1 ELSE 0 END) AS NullBuildingOid
   FROM MAS_Elevator_Floor
   UNION ALL
   SELECT 
       'MAS_Apartments' AS TableName,
       COUNT(*) AS TotalRows,
       SUM(CASE WHEN floorOid IS NULL THEN 1 ELSE 0 END) AS NullFloorOid
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
   WHERE fk.name LIKE '%buildingOid%' OR fk.name LIKE '%floorOid%'
   ORDER BY TableName;
   ```

3. **Kiểm tra Primary Key của MAS_Elevator_Floor**
   ```sql
   -- Kiểm tra PK của MAS_Elevator_Floor
   SELECT 
       kc.name AS ConstraintName,
       c.name AS ColumnName,
       ty.name AS DataType
   FROM sys.key_constraints kc
   INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
   INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
   INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
   WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Floor');
   ```

4. **Kiểm tra dữ liệu match**
   ```sql
   -- Kiểm tra dữ liệu đã match đúng chưa
   SELECT 
       a.RoomCode,
       a.Floor AS Apartments_Floor,
       a.floorNo AS Apartments_floorNo,
       ef.FloorNumber AS ElevatorFloor_FloorNumber,
       ef.FloorName AS ElevatorFloor_FloorName,
       a.floorOid,
       ef.oid AS ElevatorFloor_oid,
       CASE WHEN a.floorOid = ef.oid THEN 'Match' ELSE 'Not Match' END AS MatchStatus
   FROM MAS_Apartments a
   LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
   WHERE a.floorOid IS NOT NULL;
   ```

## 🔄 Các bước tiếp theo

### 1. Cập nhật Stored Procedures

Tìm và cập nhật tất cả Stored Procedures sử dụng `Floor` và `floorNo`:

```sql
-- Tìm SP sử dụng Floor hoặc floorNo
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE (definition LIKE '%[^a-zA-Z]Floor[^a-zA-Z]%' OR definition LIKE '%floorNo%')
  AND definition NOT LIKE '%floorOid%';
```

**Ví dụ cập nhật:**
```sql
-- Trước
WHERE Floor = @Floor AND floorNo = @floorNo

-- Sau
WHERE floorOid = @floorOid
```

### 2. Cập nhật Application Code

- **Repository Layer**: Cập nhật methods sử dụng `Floor`, `floorNo`
- **Service Layer**: Cập nhật business logic
- **API Controllers**: Cập nhật endpoints
- **Models**: Cập nhật model classes

**Ví dụ C#:**
```csharp
// Trước
public async Task<List<ApartmentInfo>> GetApartmentsByFloor(decimal floor, string floorNo)
{
    return await _repository.GetApartmentsByFloor(floor, floorNo);
}

// Sau
public async Task<List<ApartmentInfo>> GetApartmentsByFloor(Guid floorOid)
{
    return await _repository.GetApartmentsByFloor(floorOid);
}
```

### 3. Xóa cột Floor và floorNo (Tùy chọn)

**⚠️ CHỈ XÓA SAU KHI:**
- Đã cập nhật tất cả Stored Procedures
- Đã cập nhật tất cả Application Code
- Đã test kỹ lưỡng trên môi trường production
- Đã có backup và rollback plan

```sql
-- Ví dụ xóa cột Floor và floorNo (CHỈ CHẠY KHI CHẮC CHẮN)
-- ALTER TABLE [dbo].[MAS_Apartments]
-- DROP COLUMN [Floor], [floorNo];
```

## 📝 Rollback Plan

Nếu cần rollback:

1. **Khôi phục từ backup**
   ```sql
   RESTORE DATABASE [dbSHome] 
   FROM DISK = 'C:\Backup\dbSHome_Before_Elevator_Floor_Migration_YYYYMMDD.bak'
   WITH REPLACE;
   ```

2. **Hoặc revert thủ công:**
   - Xóa Foreign Key mới
   - Xóa cột `floorOid` và `buildingOid`
   - Khôi phục Primary Key cũ trên `Id`

## ✅ Checklist

- [ ] Backup database
- [ ] Test trên DEV/STAGING
- [ ] Kiểm tra dữ liệu trước migration
- [ ] Kiểm tra dữ liệu Floor và floorNo có thể match với MAS_Elevator_Floor
- [ ] Chạy script migration
- [ ] Kiểm tra dữ liệu sau migration
- [ ] Kiểm tra Foreign Key
- [ ] Kiểm tra Primary Key của MAS_Elevator_Floor
- [ ] Kiểm tra dữ liệu match
- [ ] Cập nhật Stored Procedures
- [ ] Cập nhật Application Code
- [ ] Test toàn bộ hệ thống
- [ ] Xóa cột Floor và floorNo (nếu đã đảm bảo)
- [ ] Deploy lên PRODUCTION (nếu đã test OK)

## 📞 Liên hệ

Nếu có vấn đề trong quá trình migration, vui lòng liên hệ team Database hoặc Development Team.

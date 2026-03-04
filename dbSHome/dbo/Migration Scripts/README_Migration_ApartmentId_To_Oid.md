# Migration Script: ApartmentId → apartOid

## 📋 Mục đích

Script này thực hiện migration để chuẩn hóa khóa chính của bảng `MAS_Apartments` từ `ApartmentId` (INT IDENTITY) sang `oid` (UNIQUEIDENTIFIER/GUID).

## 🎯 Các bước thực hiện

### Bước 1: Thêm cột `apartOid`
- Thêm cột `apartOid` (UNIQUEIDENTIFIER, NULLABLE) vào tất cả các bảng có Foreign Key đến `MAS_Apartments`

### Bước 2: Populate dữ liệu
- Cập nhật giá trị `apartOid` từ `ApartmentId` bằng cách join với `MAS_Apartments.oid`

### Bước 3: Tạo Index
- Tạo Non-Clustered Index cho cột `apartOid` trên các bảng chính để tối ưu performance

### Bước 4: Tạo Foreign Key
- Tạo Foreign Key constraint từ `apartOid` → `MAS_Apartments.oid`

### Bước 5: Chuyển Primary Key
- Xóa Primary Key cũ (`PK_MAS_Apartments` trên `ApartmentId`)
- Tạo Primary Key mới trên `oid`
- Tạo Unique Index cho `ApartmentId` để backward compatibility

## 📊 Danh sách bảng được migrate

### ⚠️ Lưu ý về MAS_Customers

**Bảng `MAS_Customers` KHÔNG được migrate** vì:
- Bảng này dùng chung cho nhiều `MAS_Apartments` (một khách hàng có thể có nhiều căn hộ)
- Quan hệ giữa `MAS_Customers` và `MAS_Apartments` được quản lý qua bảng trung gian `MAS_Apartment_Member`
- Cột `ApartmentId` trong `MAS_Customers` sẽ được bỏ trong tương lai (nếu cần)

### Bảng chính (Core Tables)
1. ✅ `MAS_Apartment_Member` - Thành viên căn hộ
2. ⚠️ `MAS_Customers` - **BỎ QUA**: Bảng này dùng chung cho nhiều `MAS_Apartments`, không migrate
3. ✅ `MAS_Apartment_Card` - Thẻ căn hộ
4. ✅ `MAS_Customer_Household` - Hộ gia đình
5. ✅ `MAS_Requests` - Yêu cầu

### Bảng dịch vụ (Service Tables)
6. `MAS_Feedbacks` - Phản ánh
7. `MAS_Cards` - Thẻ
8. `MAS_Card_H` - Lịch sử thẻ
9. `MAS_Apartment_Violation` - Vi phạm
10. `MAS_Apartment_Service_Extend` - Dịch vụ mở rộng
11. `MAS_Apartment_Service_Living` - Dịch vụ sinh hoạt
12. `MAS_Apartment_Profile` - Hồ sơ căn hộ
13. `MAS_Apartment_Member_H` - Lịch sử thành viên
14. `MAS_Apartment_HostChange_History` - Lịch sử đổi chủ hộ
15. `MAS_Service_Living_Tracking` - Theo dõi dịch vụ sinh hoạt
16. `MAS_Service_Living_Track` - Track dịch vụ sinh hoạt
17. `MAS_Service_Cut_History` - Lịch sử cắt dịch vụ
18. `MAS_Service_ReceiveEntry` - Nhập dịch vụ
19. `MAS_Service_Receipts` - Biên lai dịch vụ
20. `MAS_Service_Receipts_H` - Lịch sử biên lai

### Bảng khác
21. `TRS_PayRegBill` - Thanh toán hóa đơn
22. `MAS_Apartments_Save` - Backup căn hộ
23. `MAS_CardVehicle` - Thẻ xe
24. `MAS_CardVehicle_H` - Lịch sử thẻ xe

## ⚠️ Lưu ý quan trọng

### Trước khi chạy script

1. **Backup Database**
   ```sql
   BACKUP DATABASE [dbSHome] 
   TO DISK = 'C:\Backup\dbSHome_Before_Migration_' + CONVERT(VARCHAR, GETDATE(), 112) + '.bak'
   WITH COMPRESSION, INIT;
   ```

2. **Test trên môi trường DEV/STAGING trước**
   - Không chạy trực tiếp lên PRODUCTION
   - Test kỹ lưỡng trên môi trường non-production

3. **Kiểm tra dữ liệu**
   - Đảm bảo tất cả `MAS_Apartments` có `oid` không NULL
   - Đảm bảo không có `oid` trùng lặp

4. **Thông báo team**
   - Thông báo cho team phát triển về thời gian migration
   - Có thể cần downtime nếu dữ liệu lớn

### Trong khi chạy script

- Script được thiết kế **idempotent** - có thể chạy nhiều lần an toàn
- Script sử dụng **Transaction** - nếu có lỗi sẽ tự động rollback
- Theo dõi output để biết tiến trình

### Sau khi chạy script

1. **Kiểm tra dữ liệu**
   ```sql
   -- Kiểm tra số lượng bản ghi đã được populate
   SELECT 
       'MAS_Apartment_Member' AS TableName,
       COUNT(*) AS TotalRows,
       SUM(CASE WHEN apartOid IS NULL THEN 1 ELSE 0 END) AS NullRows
   FROM MAS_Apartment_Member
   UNION ALL
   SELECT 'MAS_Apartment_Card', COUNT(*), SUM(CASE WHEN apartOid IS NULL THEN 1 ELSE 0 END)
   FROM MAS_Apartment_Card
   UNION ALL
   SELECT 'MAS_Requests', COUNT(*), SUM(CASE WHEN apartOid IS NULL THEN 1 ELSE 0 END)
   FROM MAS_Requests
   -- ... các bảng khác
   -- Lưu ý: MAS_Customers không được migrate (bảng dùng chung)
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
   WHERE fk.name LIKE '%apartOid%'
   ORDER BY TableName;
   ```

3. **Kiểm tra Primary Key**
   ```sql
   -- Kiểm tra PK của MAS_Apartments
   SELECT 
       kc.name AS ConstraintName,
       c.name AS ColumnName,
       ty.name AS DataType
   FROM sys.key_constraints kc
   INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
   INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
   INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
   WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID('dbo.MAS_Apartments');
   ```

## 🔄 Các bước tiếp theo

### 1. Cập nhật Stored Procedures

Tìm và cập nhật tất cả Stored Procedures sử dụng `ApartmentId`:

```sql
-- Tìm SP sử dụng ApartmentId
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%ApartmentId%'
  AND definition NOT LIKE '%apartOid%';
```

**Ví dụ cập nhật:**
```sql
-- Trước
WHERE apartmentId = @ApartmentId

-- Sau
WHERE apartOid = @apartOid
```

### 2. Cập nhật Application Code

- **Repository Layer**: Cập nhật methods sử dụng `ApartmentId`
- **Service Layer**: Cập nhật business logic
- **API Controllers**: Cập nhật endpoints
- **Models**: Cập nhật model classes

**Ví dụ C#:**
```csharp
// Trước
public async Task<ApartmentInfo> GetApartment(int apartmentId)
{
    return await _repository.GetApartment(apartmentId);
}

// Sau
public async Task<ApartmentInfo> GetApartment(Guid apartOid)
{
    return await _repository.GetApartment(apartOid);
}
```

### 3. Cập nhật Indexes

Sau khi chuyển sang sử dụng `apartOid`, có thể cần:
- Xóa index cũ trên `ApartmentId` (nếu không còn sử dụng)
- Tối ưu index mới trên `apartOid`

### 4. Xóa cột ApartmentId (Tùy chọn)

**⚠️ CHỈ XÓA SAU KHI:**
- Đã cập nhật tất cả Stored Procedures
- Đã cập nhật tất cả Application Code
- Đã test kỹ lưỡng trên môi trường production
- Đã có backup và rollback plan

```sql
-- Ví dụ xóa cột ApartmentId (CHỈ CHẠY KHI CHẮC CHẮN)
-- ALTER TABLE [dbo].[MAS_Apartment_Member]
-- DROP COLUMN [ApartmentId];
```

## 📝 Rollback Plan

Nếu cần rollback:

1. **Khôi phục từ backup**
   ```sql
   RESTORE DATABASE [dbSHome] 
   FROM DISK = 'C:\Backup\dbSHome_Before_Migration_YYYYMMDD.bak'
   WITH REPLACE;
   ```

2. **Hoặc revert thủ công:**
   - Xóa Foreign Key mới
   - Xóa cột `apartOid`
   - Khôi phục Primary Key cũ trên `ApartmentId`

## ✅ Checklist

- [ ] Backup database
- [ ] Test trên DEV/STAGING
- [ ] Kiểm tra dữ liệu trước migration
- [ ] Chạy script migration
- [ ] Kiểm tra dữ liệu sau migration
- [ ] Kiểm tra Foreign Key
- [ ] Kiểm tra Primary Key
- [ ] Cập nhật Stored Procedures
- [ ] Cập nhật Application Code
- [ ] Test toàn bộ hệ thống
- [ ] Deploy lên PRODUCTION (nếu đã test OK)

## 📞 Liên hệ

Nếu có vấn đề trong quá trình migration, vui lòng liên hệ team Database hoặc Development Team.

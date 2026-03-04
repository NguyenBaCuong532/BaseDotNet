# Tài Liệu Cấu Trúc Database dbSHome

## 📊 TỔNG QUAN

**Database**: `dbSHome`  
**Schema**: `dbo`  
**Mục đích**: Quản lý hệ thống căn hộ thông minh (Smart Home Management System)

### Cấu trúc tổng thể
- **185 Tables**: Quản lý thông tin căn hộ, khách hàng, thẻ, dịch vụ, yêu cầu, thông báo
- **551 Stored Procedures**: Xử lý business logic
- **82 Functions**: Hỗ trợ tính toán và xử lý dữ liệu
- **17 User Defined Types**: Định nghĩa kiểu dữ liệu phức tạp

---

## 🏢 KIẾN TRÚC MULTI-TENANT

### Tổng quan

Hệ thống **dbSHome** được thiết kế theo mô hình **Multi-Tenant Architecture**, cho phép một instance database phục vụ nhiều tenant (khách hàng/dự án) độc lập.

### Bảng định danh Tenant: MAS_Projects

**MAS_Projects** là bảng trung tâm định danh các tenant trong hệ thống:

```sql
CREATE TABLE [dbo].[MAS_Projects] (
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Projects_oid] DEFAULT (newid()) NOT NULL,
    [sub_projectCd]       NVARCHAR (10)    NOT NULL,
    [projectCd]           NVARCHAR (10)    NOT NULL,
    [projectName]         NVARCHAR (250)   NOT NULL,
    [investorName]        NVARCHAR (150)   NOT NULL,
    [address]             NVARCHAR (250)   NOT NULL,
    -- ... các trường khác
    CONSTRAINT [PK_MAS_Projects] PRIMARY KEY CLUSTERED ([oid] ASC)
);
```

**Đặc điểm:**
- **Khóa chính**: `oid` (UNIQUEIDENTIFIER/GUID) - Mỗi tenant có một GUID duy nhất
- **Mỗi `oid` tương đương với 1 tenant** - Một dự án/căn hộ thông minh
- **Tất cả dữ liệu trong hệ thống được phân tách theo `tenant_oid`**

### Cơ chế Multi-Tenant

1. **Foreign Key Pattern**: 
   - Các bảng con có cột `tenant_oid` (UNIQUEIDENTIFIER, NULLABLE)
   - Foreign Key: `FK_[TableName]_tenant_oid` → `MAS_Projects.oid`
   - Cho phép phân tách dữ liệu theo tenant

2. **Khóa chính chuẩn hóa**:
   - **Mục tiêu**: Tất cả các bảng sẽ sử dụng `oid` (UNIQUEIDENTIFIER) làm khóa chính
   - **Lợi ích**:
     - Đảm bảo tính nhất quán trong toàn hệ thống
     - Dễ dàng merge/replicate dữ liệu giữa các môi trường
     - Tránh xung đột ID khi tích hợp nhiều tenant
     - Hỗ trợ tốt cho distributed systems

3. **Trạng thái hiện tại**:
   - ✅ Một số bảng đã có `oid` và `tenant_oid`
   - ⚠️ Nhiều bảng vẫn đang sử dụng khóa chính kiểu INT IDENTITY hoặc NVARCHAR
   - 🔄 Đang trong quá trình migration

---

## 📁 CẤU TRÚC MODULE CHÍNH

### 1. 📦 MODULE QUẢN LÝ CĂN HỘ (APARTMENT MANAGEMENT)

#### 1.1 MAS_Apartments - Bảng căn hộ chính
**Mục đích**: Quản lý thông tin căn hộ
```sql
- ApartmentId (INT, PK, Identity)
- RoomCode (NVARCHAR(50), UNIQUE) - Mã phòng
- projectCd (NVARCHAR(10)) - Mã dự án
- buildingCd (NVARCHAR(10)) - Mã tòa nhà
- sub_projectCd (NVARCHAR(10)) - Mã dự án con
- ApartmentType (INT) - Loại căn hộ
- IsClose (BIT) - Đã đóng
- IsLock (BIT) - Đã khóa
- IsReceived (BIT) - Đã nhận
- ReceiveDt (DATE) - Ngày nhận
- IsRent (BIT) - Cho thuê
- FeeStart (DATETIME) - Ngày bắt đầu tính phí
- IsFree (BIT) - Miễn phí
- numFreeMonth (INT) - Số tháng miễn phí
- FreeToDt (DATETIME) - Miễn phí đến ngày
- CurrBal (DECIMAL(18)) - Số dư hiện tại
- DebitAmt (DECIMAL(18)) - Số tiền nợ
- RefundAmt (DECIMAL(18)) - Số tiền hoàn lại
- par_residence_type_oid (UNIQUEIDENTIFIER) - Loại căn hộ
```

**Indexes**:
- idx_MAS_Apartments_roomCode
- idx_MAS_Apartments_projectCd
- idx_MAS_Apartments_userlogin
- idx_MAS_Apartments_IsReceived

#### 1.2 MAS_Apartment_Member - Thành viên căn hộ
**Mục đích**: Quản lý thành viên trong từng căn hộ

#### 1.3 MAS_Apartment_Reg - Đăng ký căn hộ
**Mục đích**: Lưu thông tin đăng ký cư trú

#### 1.4 MAS_Buildings - Tòa nhà
**Mục đích**: Quản lý thông tin tòa nhà, block

---

### 2. 👥 MODULE QUẢN LÝ KHÁCH HÀNG (CUSTOMER MANAGEMENT)

#### 2.1 MAS_Customers - Khách hàng
**Mục đích**: Quản lý thông tin khách hàng, cư dân
```sql
- CustId (NVARCHAR(50), PK) - ID khách hàng
- Cif_No (NVARCHAR(50)) - Số CIF
- FullName (NVARCHAR(250)) - Họ và tên
- FirstName (NVARCHAR(100)) - Tên
- LastName (NVARCHAR(150)) - Họ
- AvatarUrl (NVARCHAR(350)) - Ảnh đại diện
- IsSex (BIT) - Giới tính (True=Male, False=Female)
- Birthday (DATETIME) - Ngày sinh
- RelationId (INT) - Quan hệ
- Phone (NVARCHAR(50)) - Số điện thoại
- Phone2 (NVARCHAR(30)) - Số điện thoại 2
- Email (NVARCHAR(150)) - Email
- Email2 (NVARCHAR(150)) - Email 2
- Pass_No (NVARCHAR(50)) - Số CMT/CCCD/Passport
- Pass_Dt (DATE) - Ngày cấp
- Pass_Plc (NVARCHAR(150)) - Nơi cấp
- Address (NVARCHAR(350)) - Địa chỉ
- ProvinceCd (NVARCHAR(30)) - Mã tỉnh/thành phố
- IsForeign (BIT) - Người nước ngoài
- CountryCd (NVARCHAR(30)) - Mã quốc gia
- IsContact (BIT) - Người liên hệ
- IsEmployee (BIT) - Nhân viên
- ApartmentId (INT) - ID căn hộ
- IsHost (BIT) - Chủ hộ
- Auth_St (BIT) - Trạng thái xác thực
- Auth_Dt (DATETIME) - Ngày xác thực
- Auth_Id (NVARCHAR(50)) - Người xác thực
```

**Indexes**:
- IX_MAS_Customers_Phone_CifNo_INC_CustId
- idx_MAS_Customers_phone
- idx_MAS_Customers_email
- idx_MAS_Customers_cif_no
- idx_MAS_Customers_FullName
- idx_MAS_Customers_Pass_No

**Triggers**:
- trg_mas_customers_update - Validate CustId
- trg_mas_customers_delete - Backup vào MAS_Customers_Save khi xóa

#### 2.2 MAS_Customer_Household - Hộ gia đình
**Mục đích**: Quản lý quan hệ hộ gia đình

#### 2.3 MAS_Customer_Relation - Quan hệ khách hàng
**Mục đích**: Định nghĩa các mối quan hệ

#### 2.4 MAS_Customer_Image - Hình ảnh khách hàng
**Mục đích**: Lưu ảnh khách hàng

---

*Note: File này chứa nội dung đầy đủ từ DATABASE_STRUCTURE.md gốc. Vui lòng xem file gốc để có đầy đủ nội dung.*

---

## 📋 DANH SÁCH BẢNG ĐÃ CÓ TENANT_OID

Các bảng sau đã được tích hợp multi-tenant với cột `tenant_oid` và Foreign Key đến `MAS_Projects.oid`:

### ✅ Bảng đã có tenant_oid (Một phần danh sách)

1. **MAS_Apartments** - Căn hộ
   - Khóa chính: `ApartmentId` (INT IDENTITY)
   - Đã có: `oid` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `ApartmentId` → `oid`

2. **MAS_Customers** - Khách hàng
   - Khóa chính: `CustId` (NVARCHAR(50))
   - Đã có: `oid` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `CustId` → `oid`

3. **MAS_Buildings** - Tòa nhà
   - Khóa chính: `BuildingCd` (NVARCHAR(50))
   - Đã có: `oid` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `BuildingCd` → `oid`

4. **MAS_CardBase** - Thẻ cơ sở
   - Khóa chính: `Card_Num` (NVARCHAR(20))
   - Đã có: `Guid_Cd` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `Card_Num` → `Guid_Cd` hoặc tạo `oid` mới

5. **MAS_Requests** - Yêu cầu
   - Khóa chính: `requestId` (INT IDENTITY)
   - Đã có: `oid` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `requestId` → `oid`

6. **mas_employee** - Nhân viên
   - Khóa chính: `empId` (UNIQUEIDENTIFIER) ✅
   - Đã có: `oid` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `empId` → `oid` (nếu muốn thống nhất)

7. **UserProject** - Dự án người dùng
   - Khóa chính: Composite (`projectCd`, `userId`)
   - Đã có: `id` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ composite → `id`

8. **UserInfo** - Thông tin người dùng
   - Khóa chính: `reg_userId` (NVARCHAR)
   - Đã có: `oid` (GUID), `tenant_oid` (FK)
   - **Cần migrate**: Chuyển PK từ `reg_userId` → `oid`

9. **maintenance_work_order** - Work Order bảo trì
   - Khóa chính: `oid` (UNIQUEIDENTIFIER) ✅
   - Đã có: `tenant_oid` (FK)
   - **Trạng thái**: Đã đúng chuẩn

10. **maintenance_plan** - Kế hoạch bảo trì
    - Khóa chính: `oid` (UNIQUEIDENTIFIER) ✅
    - Đã có: `tenant_oid` (FK)
    - **Trạng thái**: Đã đúng chuẩn

### 📊 Các bảng khác đã có tenant_oid (Tham khảo)

- `visit_fee`, `utl_Error_Log`, `vehicleno_riverside`, `user_role`
- `user_rocketchat_vistor`, `two_stage_rate`, `user_favorite_service`
- `transaction_payment_draft`, `trans_response_klb`, `short_stay_rule`
- `support_service_users`, `support_request_assignments`, `shift_config`
- `service_supplier`, `service_type`, `service_request_extra`
- `service_speed_extra`, `service_request`, `service_package`, `service`
- `security_policy`, `rocketchat_department`, `role`
- `rocketchat_channel_join_request`, `rocketchat_channel_member`, `rocketchat_channel`
- `request_chat`, `request_review`, `pricing_rule`, `project_channel`
- `par_water`, `par_water_detail`, `par_vehicle_detail`, `par_vehicle_type`
- `par_vehicle_daily_detail`, `par_vehicle_daily_type`, `par_vehicle_daily`, `par_vehicle`
- `par_service_price_log`, `par_service_price_type`, `par_project_config_default`
- `par_residence_type`, `par_parking_space`, `par_project_config`, `par_electric`, `par_electric_detail`
- ... và nhiều bảng khác

---

## 🔄 KẾ HOẠCH MIGRATION

### Mục tiêu

Chuyển đổi tất cả các bảng sang sử dụng **`oid` (UNIQUEIDENTIFIER/GUID)** làm khóa chính thay vì:
- `INT IDENTITY` (tự động tăng)
- `NVARCHAR` (mã định danh dạng text)
- Composite keys (khóa phức hợp)

### Nguyên tắc Migration

1. **Bảo toàn dữ liệu**: Không mất dữ liệu trong quá trình migration
2. **Backward Compatibility**: Duy trì khả năng tương thích ngược khi có thể
3. **Foreign Key**: Cập nhật tất cả Foreign Key liên quan
4. **Indexes**: Tái tạo indexes sau khi đổi khóa chính
5. **Stored Procedures**: Cập nhật tất cả SP liên quan
6. **Application Code**: Cập nhật code ứng dụng để sử dụng `oid` thay vì khóa cũ

### Quy trình Migration (Chi tiết)

#### Bước 1: Phân tích và Chuẩn bị

1. **Liệt kê tất cả bảng cần migrate**
   ```sql
   -- Tìm các bảng có PK không phải UNIQUEIDENTIFIER
   SELECT 
       t.name AS TableName,
       c.name AS ColumnName,
       ty.name AS DataType
   FROM sys.tables t
   INNER JOIN sys.key_constraints kc ON t.object_id = kc.parent_object_id
   INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
   INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
   INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
   WHERE kc.type = 'PK'
     AND ty.name != 'uniqueidentifier'
   ORDER BY t.name;
   ```

2. **Phân tích Foreign Key dependencies**
   - Xác định các bảng con phụ thuộc
   - Xác định thứ tự migration (parent → child)

3. **Backup dữ liệu**
   - Full backup database
   - Backup các bảng quan trọng

#### Bước 2: Thêm cột `oid` (nếu chưa có)

```sql
-- Ví dụ: Thêm oid cho bảng chưa có
ALTER TABLE [dbo].[TableName]
ADD [oid] UNIQUEIDENTIFIER CONSTRAINT [DF_TableName_oid] DEFAULT (newid()) NOT NULL;

-- Tạo unique index cho oid
CREATE UNIQUE NONCLUSTERED INDEX [IX_TableName_oid]
ON [dbo].[TableName]([oid] ASC);
```

#### Bước 3: Cập nhật Foreign Key trong các bảng con

```sql
-- Ví dụ: Cập nhật FK từ ApartmentId (INT) → oid (GUID)
-- 1. Thêm cột mới
ALTER TABLE [dbo].[ChildTable]
ADD [apartment_oid] UNIQUEIDENTIFIER NULL;

-- 2. Populate dữ liệu
UPDATE ct
SET ct.[apartment_oid] = a.[oid]
FROM [dbo].[ChildTable] ct
INNER JOIN [dbo].[MAS_Apartments] a ON ct.[ApartmentId] = a.[ApartmentId];

-- 3. Tạo FK mới
ALTER TABLE [dbo].[ChildTable]
ADD CONSTRAINT [FK_ChildTable_apartment_oid] 
FOREIGN KEY ([apartment_oid]) REFERENCES [dbo].[MAS_Apartments]([oid]);

-- 4. Xóa FK cũ (sau khi đảm bảo không còn sử dụng)
-- ALTER TABLE [dbo].[ChildTable] DROP CONSTRAINT [FK_ChildTable_ApartmentId];
```

#### Bước 4: Chuyển đổi Primary Key

```sql
-- 1. Xóa Primary Key cũ
ALTER TABLE [dbo].[TableName]
DROP CONSTRAINT [PK_TableName];

-- 2. Đặt oid làm Primary Key mới
ALTER TABLE [dbo].[TableName]
ADD CONSTRAINT [PK_TableName] PRIMARY KEY CLUSTERED ([oid] ASC);

-- 3. (Tùy chọn) Giữ lại cột cũ làm Unique Index nếu cần backward compatibility
CREATE UNIQUE NONCLUSTERED INDEX [IX_TableName_OldPK]
ON [dbo].[TableName]([OldPrimaryKeyColumn] ASC);
```

#### Bước 5: Cập nhật Stored Procedures

- Tìm tất cả SP sử dụng khóa cũ
- Cập nhật tham số và logic để sử dụng `oid`
- Test kỹ lưỡng

#### Bước 6: Cập nhật Application Code

- Repository layer: Cập nhật methods sử dụng khóa cũ
- Service layer: Cập nhật business logic
- API Controllers: Cập nhật endpoints
- Models: Cập nhật model classes

### Ưu tiên Migration

#### Phase 1: Core Tables (Ưu tiên cao)
1. ✅ `MAS_Projects` - Đã đúng chuẩn
2. 🔄 `MAS_Apartments` - Cần migrate
3. 🔄 `MAS_Customers` - Cần migrate
4. 🔄 `MAS_Buildings` - Cần migrate

#### Phase 2: Related Tables
5. `MAS_Apartment_Member`
6. `MAS_Apartment_Reg`
7. `MAS_Customer_Household`
8. `MAS_Cards`
9. `MAS_CardVehicle`

#### Phase 3: Business Tables
10. `MAS_Requests`
11. `MAS_Service_Receivable`
12. `MAS_Service_Receipts`
13. `MAS_Feedbacks`
14. ... các bảng khác

### Lưu ý quan trọng

⚠️ **Rủi ro và Cân nhắc:**

1. **Downtime**: Migration có thể yêu cầu downtime
2. **Data Volume**: Với dữ liệu lớn, migration có thể mất nhiều thời gian
3. **Application Impact**: Cần phối hợp với team phát triển
4. **Testing**: Test kỹ lưỡng trên môi trường dev/staging trước
5. **Rollback Plan**: Chuẩn bị kế hoạch rollback nếu có vấn đề

✅ **Best Practices:**

1. Migration từng bảng một, không làm hàng loạt
2. Test trên môi trường non-production trước
3. Giữ lại cột cũ (nullable) trong giai đoạn chuyển tiếp
4. Tạo migration scripts có thể chạy lại (idempotent)
5. Document tất cả thay đổi

---

## 🎯 KẾT LUẬN

Database **dbSHome** là một hệ thống quản lý căn hộ thông minh toàn diện với:

- ✅ Quản lý căn hộ, khách hàng, thẻ
- ✅ Quản lý gửi xe
- ✅ Dịch vụ và phí dịch vụ
- ✅ Yêu cầu và phản ánh
- ✅ Thông báo và email/SMS
- ✅ Báo cáo và phân tích
- ✅ Thang máy
- ✅ Ví điện tử và điểm thưởng
- ✅ Quản trị hệ thống

Hệ thống sử dụng kiến trúc **Layered Architecture** với **Repository Pattern** để quản lý truy cập dữ liệu, đảm bảo tính mở rộng và bảo trì dễ dàng.



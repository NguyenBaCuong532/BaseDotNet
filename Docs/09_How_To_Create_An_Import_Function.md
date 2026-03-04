# 09. Hướng dẫn Import/Export đầy đủ

**Date**: 2025-01-27  
**Version**: 3.0  
**Purpose**: Complete guide for implementing Import/Export functionality with examples from PersonController

> 📌 **IMPORTANT**: This is the official complete guide replacing both the old `09_How_To_Create_An_Import_Function.md` and `12_Import_Export_Complete_Guide.md`

> 📋 **UPDATE v3.0**: 
> - Thêm nguyên tắc đồng bộ Import/Export/Model
> - Thêm nguyên tắc tên cột (tiếng Việt cho display, tiếng Anh cho code)
> - Thêm hướng dẫn sử dụng template `export_danh_muc_chung.xlsx`
> - Cập nhật ví dụ PersonImport/Export hoàn chỉnh

---

## 0. Nguyên tắc Cơ bản - Đồng bộ Import/Export/Model

### 0.1. Nguyên tắc Đồng bộ 4 Layer

Khi tạo Import/Export cho một nghiệp vụ mới, **BẮT BUỘC** phải đồng bộ 4 layer sau:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. C# Model (PersonImport.cs)                               │
│    - Tên property: Tiếng Anh (Code, FullName, Phone...)   │
│    - Excel attributes: [Excel(ExcelCol = "A")]             │
│    - XmlElement: Tên tiếng Anh                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. SQL UDTT (PersonImportType)                             │
│    - Tên cột: Tiếng Anh (Code, FullName, Phone...)         │
│    - Data type: Khớp với C# property type                  │
│    - Comment: Mô tả tiếng Việt                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Import Template SP (sp_core_person_imports_temp)         │
│    - Tên cột SELECT: Tiếng Việt ([Mã NV], [Họ tên]...)     │
│    - Dữ liệu mẫu: 1 dòng                                    │
│    - Thứ tự cột: KHỚP với PersonImportType                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Export SP (sp_core_person_export)                       │
│    - Tên cột SELECT: Tiếng Việt ([Mã NV], [Họ tên]...)    │
│    - Các cột: GIỐNG HỆT Import Template                     │
│    - Format: Date (dd/MM/yyyy), Status (Active/Inactive)   │
└─────────────────────────────────────────────────────────────┘
```

### 0.2. Nguyên tắc Đặt Tên Cột

**Quy tắc CHÍNH:**

1. **C# Model & SQL UDTT**: 
   - ✅ Dùng **tiếng Anh** (Code, FullName, Phone, Email...)
   - ❌ KHÔNG dùng tiếng Việt (Mã NV, Họ tên...)

2. **Import/Export Stored Procedures**:
   - ✅ Dùng **tiếng Việt** trong SELECT AS ([Mã NV], [Họ tên], [Điện thoại]...)
   - ✅ Dùng **tiếng Anh** khi SELECT từ table/parameter (code, full_name, phone...)

3. **Excel Column Headers**:
   - ✅ Dùng **tiếng Việt** ([Mã NV], [Họ tên]...) để hiển thị trong Excel

**Ví dụ đúng:**

```sql
-- ✅ ĐÚNG: Import Template SP
SELECT 
    1 AS [STT],                           -- Tiếng Việt cho display
    N'NV001' AS [Mã NV],                  -- Tiếng Việt cho display
    N'Nguyễn Văn An' AS [Họ tên]          -- Tiếng Việt cho display
FROM ...
```

```csharp
-- ✅ ĐÚNG: C# Model
public class PersonImport
{
    [XmlElement("Code")]                   -- Tiếng Anh
    [Excel(ExcelCol = "B")]
    public string Code { get; set; }       -- Tiếng Anh
}
```

```sql
-- ✅ ĐÚNG: SQL UDTT
CREATE TYPE [dbo].[PersonImportType] AS TABLE (
    [Code] NVARCHAR(50) NULL,              -- Tiếng Anh
    [FullName] NVARCHAR(200) NULL          -- Tiếng Anh
);
```

### 0.3. Nguyên tắc Thứ tự Cột

**QUAN TRỌNG**: Tất cả các layer phải có **thứ tự cột giống nhau**:

1. ✅ C# Model: Thứ tự properties
2. ✅ SQL UDTT: Thứ tự columns  
3. ✅ Import Template SP: Thứ tự SELECT
4. ✅ Export SP: Thứ tự SELECT
5. ✅ Excel Template: Thứ tự columns A, B, C...

**Checklist đồng bộ:**
- [ ] C# Model có đủ properties theo thứ tự
- [ ] SQL UDTT có đủ columns theo thứ tự
- [ ] Import Template SP có đủ SELECT theo thứ tự
- [ ] Export SP có đủ SELECT theo thứ tự (trừ cột Errors)
- [ ] ExcelCol attributes khớp với thứ tự A, B, C...

### 0.4. Nguyên tắc Sử dụng Template Excel

**Template chuẩn**: `templates/export_danh_muc_chung.xlsx`

**Sử dụng cho**:
- ✅ Import Template (GetImportTemp)
- ✅ Export Data (SetExport)

**Không cần**:
- ❌ Tạo template riêng cho mỗi nghiệp vụ
- ❌ Chỉnh sửa template (sử dụng chung)

**Cách sử dụng**:

```csharp
// Service Layer
public async Task<BaseValidate<Stream>> GetPersonImportTemp()
{
    var ds = await _personRepository.GetPersonImportTemp();
    var r = new FlexcellUtils();
    var templatePath = $"templates/export_danh_muc_chung.xlsx";
    var template = await File.ReadAllBytesAsync(templatePath);
    Dictionary<string, object> p = new Dictionary<string, object>();
    var report = r.CreateReport(template, ReportType.xlsx, ds, p);
    return new BaseValidate<Stream>(report);
}
```

**Lưu ý**: 
- Template `export_danh_muc_chung.xlsx` được thiết kế để nhận DataSet từ stored procedure
- DataSet phải có đúng cấu trúc (tên cột tiếng Việt)
- FlexcellUtils sẽ tự động map dữ liệu vào template

---

## 1. Tổng quan Quy trình 2 Bước (Two-Step Import)

Quy trình này tách biệt việc **Kiểm tra dữ liệu (Validate)** và **Chấp nhận dữ liệu (Accept)**.

### 1.1. Bước 1: Upload & Validate

```
Client
  ↓ POST /api/v1/admin/person/setimport (file)
Controller.SetImport()
  ↓ DoImportFile<PersonImport, PersonImportSet>(file, fromRow=5, serviceHandler)
  - Đọc file Excel từ dòng 5 (skip headers)
  - Convert to List<PersonImport>
  - Upload original file to MinIO
  ↓ serviceHandler(records, accept=1) → PersonService.SetPersonImport(records, accept=1)
Service.SetPersonImport()
  ↓ PersonRepository.SetPersonImport(importSet, serial_is=1)
  ↓ sp_core_person_imports (@data, @accept, @serial_is)
Database
  ↓ Validate only, return results with messages
  ↓ Create/Update draft records
  ↓ Return ImportListPage with validation results
Controller
  ↓ GenerateResultImportedFile() - Add error messages to Excel
  ↓ Return BaseResponse<ImportListPage>
Client
  ↓ Display file with validation results
```

### 1.2. Bước 2: Accept & Save

```
Client
  ↓ POST /api/v1/admin/person/setimportaccept ({importSet})
Controller.SetImportAccept()
  ↓ PersonService.SetPersonImport(importSet, accept=0)
  ↓ PersonRepository.SetPersonImport(importSet, serial_is=0)
  ↓ sp_core_person_imports (@data, @accept=0, @serial_is)
Database
  ↓ Save valid records only
  ↓ Return final results
  ↓ Return ImportListPage with success/failure
Client
  ↓ Display final import results
```

---

## 2. API Layer - Controller Implementation

**Sử dụng `UniController.DoImportFile`:**

Đây là một phương thức generic, được thiết kế để xử lý hầu hết các logic chung của việc import file.

**Nhiệm vụ của `DoImportFile`:**
1. Kiểm tra file (tồn tại, định dạng .xls/.xlsx).
2. Đọc file Excel và chuyển đổi thành một danh sách các đối tượng DTO (`List<T>`).
3. Tải file gốc lên storage (ví dụ: MinIO) để lưu trữ.
4. Gọi `serviceHandler` đã được truyền vào với dữ liệu đã đọc và cờ `accept=1`.
5. Nhận `ImportListPage` từ BLL trả về.
6. Gọi `GenerateResultImportedFile` để tạo file Excel kết quả với các thông báo lỗi.
7. Trả về `BaseResponse<ImportListPage>` cho client.

**Ví dụ (`PersonController.cs`):**

```csharp
// File: UNI.Resident.API/Controllers/Version1/Admin/PersonController.cs

/// <summary>
/// SetImport - Upload và validate file Excel
/// </summary>
[HttpPost]
public async Task<BaseResponse<ImportListPage>> SetImport(IFormFile file)
{
    // DoImportFile<TImport, TImportSet>(
    //   file,              // File Excel từ client
    //   fromRow: 5,        // Bắt đầu đọc từ dòng 5 (skip 4 dòng header)
    //   serviceHandler     // Delegate gọi PersonService.SetPersonImport
    // )
    return await DoImportFile<PersonImport, PersonImportSet>(file, 5,
        records => _personService.SetPersonImport(records, 1));
}
```

### 2.2. SetImportAccept - Accept & Save

```csharp
/// <summary>
/// SetImportAccept - Accept và lưu dữ liệu đã validate
/// </summary>
[HttpPost]
public async Task<BaseResponse<ImportListPage>> SetImportAccept([FromBody] PersonImportSet importSet)
{
    try
    {
        // Gọi service với accept=0 để lưu dữ liệu thật
        var rs = await _personService.SetPersonImport(importSet, 0);
        return GetResponse(ApiResult.Success, rs);
    }
    catch (Exception e)
    {
        _logger.LogError(e, e.Message);
        return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
    }
}
```

### 2.3. SetExport - Export Data

```csharp
/// <summary>
/// SetExport - Export danh sách ra Excel
/// </summary>
[HttpPost]
public async Task<FileStreamResult> SetExport([FromBody] PersonFilterRequest filter)
{
    try
    {
        var rs = await _personService.SetPersonExport(filter);
        return File(rs.Data, "application/octet-stream", "thong_tin_nhan_vien.xlsx");
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, ex.Message);
        return null;
    }
}
```

### 2.4. GetImportTemp - Download Template

```csharp
/// <summary>
/// GetImportTemp - Download template Excel để import
/// </summary>
[HttpGet]
public async Task<FileStreamResult> GetImportTemp()
{
    try
    {
        var rs = await _personService.GetPersonImportTemp();
        return File(rs.Data, "application/octet-stream", "temp_thong_tin_nhan_vien.xlsx");
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, ex.Message);
        return null;
    }
}
```

---

## 3. Model Layer - Cấu trúc Models

### 3.1. PersonImport - Import Model

```csharp
// File: UNI.Resident.Model/Core/PersonInfo.cs

/// <summary>
/// PersonImport - Model cho 1 dòng dữ liệu import từ Excel
/// QUAN TRỌNG: Tên property phải là tiếng Anh, khớp với SQL UDTT
/// </summary>
public class PersonImport
{
    [XmlElement("STT")]
    [Excel(ExcelCol = "A")]
    public int? STT { get; set; }                   // STT - Số thứ tự

    [XmlElement("Code")]
    [Excel(ExcelCol = "B")]
    public string Code { get; set; }                // Mã NV - Mã nhân viên

    [XmlElement("FullName")]
    [Excel(ExcelCol = "C")]
    public string FullName { get; set; }            // Họ tên - Họ tên đầy đủ

    [XmlElement("Phone")]
    [Excel(ExcelCol = "D")]
    public string Phone { get; set; }               // Điện thoại - Số điện thoại

    [XmlElement("Email")]
    [Excel(ExcelCol = "E")]
    public string Email { get; set; }               // Email - Email

    [XmlElement("Errors")]
    [Excel(ExcelCol = "F")]
    public string Errors { get; set; }              // Errors - Lỗi validation
}
```

**Nguyên tắc**:
- ✅ **Tên property: Tiếng Anh** (Code, FullName, Phone...) - khớp với SQL UDTT
- ✅ Dùng attribute `[Excel(ExcelCol = "A")]` để map với cột Excel
- ✅ Thứ tự properties phải khớp với SQL UDTT và SP
- ✅ Date fields dùng `string` (linh hoạt format, có thể là dd/MM/yyyy)
- ✅ Thêm property `Errors` để chứa validation messages từ SP
- ✅ Comment mỗi property với mô tả rõ ràng

### 3.2. PersonImportSet - Import Set

```csharp
/// <summary>
/// PersonImportSet - Model cho toàn bộ import data
/// Kế thừa từ BaseImportSet để có các thuộc tính chung
/// </summary>
public class PersonImportSet : BaseImportSet<PersonImport>
{
    // Inherits from BaseImportSet:
    // - public bool accept { get; set; }
    // - public List<T> imports { get; set; }
    // - public uImportFile importFile { get; set; }
}
```

### 3.3. DataTableTypes

```csharp
// File: UNI.Resident.Model/bzzDataTableTypes.cs

public class DataTableTypes
{
    public const string PERSON_IMPORT_TYPE = "PERSON_IMPORT_TYPE";
    public const string VEHICLE_IMPORT_TYPE = "VEHICLE_IMPORT_TYPE";
    // Add more as needed
}
```

---

## 4. BLL Layer - Service Implementation

```csharp
// File: UNI.Resident.BLL/Services/Admin/PersonService.cs

/// <summary>
/// SetPersonImport - Validate hoặc Save dữ liệu import
/// </summary>
public Task<ImportListPage> SetPersonImport(PersonImportSet importSet, int serial_is)
{
    const string storedProcedure = "sp_core_person_imports";
    return base.SetImport<PersonImport, PersonImportSet>(
        storedProcedure, 
        importSet, 
        "persons",
        DataTableTypes.PERSON_IMPORT_TYPE,
        new { serial_is });
}

/// <summary>
/// GetPersonImportTemp - Get template Excel for import
/// QUAN TRỌNG: Sử dụng template chuẩn export_danh_muc_chung.xlsx
/// </summary>
public async Task<BaseValidate<Stream>> GetPersonImportTemp()
{
    var ds = await _personRepository.GetPersonImportTemp();
    var r = new FlexcellUtils();
    var templatePath = $"templates/exports/commonlists/export_danh_muc_chung.xlsx";
    var template = await File.ReadAllBytesAsync(templatePath);
    Dictionary<string, object> p = new Dictionary<string, object>();
    var report = r.CreateReport(template, ReportType.xlsx, ds, p);
    return new BaseValidate<Stream>(report);
}

/// <summary>
/// SetPersonExport - Export dữ liệu ra Excel
/// QUAN TRỌNG: Sử dụng template chuẩn export_danh_muc_chung.xlsx
/// </summary>
public async Task<BaseValidate<Stream>> SetPersonExport(PersonFilterRequest flt)
{
    var ds = await _personRepository.SetPersonExport(flt);
    var r = new FlexcellUtils();
    var templatePath = $"templates/exports/commonlists/export_danh_muc_chung.xlsx";
    var template = await File.ReadAllBytesAsync(templatePath);
    Dictionary<string, object> p = new Dictionary<string, object>();
    var report = r.CreateReport(template, ReportType.xlsx, ds, p);
    return new BaseValidate<Stream>(report);
}
```

---

## 5. DAL Layer - Repository Implementation

```csharp
// File: UNI.Resident.DAL/Repositories/Admin/PersonRepository.cs

/// <summary>
/// SetPersonImport - Import dữ liệu từ Excel
/// </summary>
public Task<ImportListPage> SetPersonImport(PersonImportSet importSet, int serial_is)
{
    const string storedProcedure = "sp_core_person_imports";
    return base.SetImport<PersonImport, PersonImportSet>(
        storedProcedure, 
        importSet, 
        "persons",
        DataTableTypes.PERSON_IMPORT_TYPE,
        new { serial_is });
}

/// <summary>
/// SetPersonExport - Export dữ liệu
/// </summary>
public async Task<DataSet> SetPersonExport(PersonFilterRequest filter)
{
    const string storedProcedure = "sp_core_person_export";
    return await base.GetDataSetAsync(storedProcedure, param =>
    {
        // Add filter parameters
    });
}

/// <summary>
/// GetPersonImportTemp - Get template structure
/// </summary>
public async Task<DataSet> GetPersonImportTemp()
{
    const string storedProcedure = "sp_core_person_imports_temp";
    return await GetDataSetAsync(storedProcedure);
}
```

---

## 6. Database Layer - Stored Procedures

### 6.1. sp_core_person_imports (Import Validation & Save)

```sql
CREATE PROCEDURE sp_core_person_imports
    @data PERSON_IMPORT_TYPE READONLY,
    @accept INT = 1,
    @serial_is INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    -- Validate và save logic
END
```

### 6.2. sp_core_person_export (Export Data)

```sql
CREATE PROCEDURE [dbo].[sp_core_person_export]
    @userId UNIQUEIDENTIFIER = NULL,
    @department NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Return export data with tiếng Việt column names
    SELECT 
        ROW_NUMBER() OVER (ORDER BY code) AS [STT],
        code AS [Mã NV],
        full_name AS [Họ tên],
        -- ... other columns
    FROM hr_person
    WHERE ...
END
```

### 6.3. sp_core_person_imports_temp (Import Template)

```sql
CREATE PROCEDURE [dbo].[sp_core_person_imports_temp]
    @userId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Return template structure with tiếng Việt column names
    SELECT 
        1 AS [STT],
        N'NV001' AS [Mã NV],
        N'Nguyễn Văn An' AS [Họ tên],
        -- ... other columns with sample data
    UNION ALL
    SELECT 
        NULL AS [STT],
        NULL AS [Mã NV],
        -- ... empty structure
    WHERE 1 = 0;
END
```

### 6.4. User-Defined Table Type

```sql
CREATE TYPE [dbo].[PersonImportType] AS TABLE (
    [STT]            INT            NULL,
    [Code]           NVARCHAR (50)  NULL,
    [FullName]       NVARCHAR (200) NULL,
    [Phone]          NVARCHAR (20)  NULL,
    [Email]          NVARCHAR (250) NULL,
    [Errors]         NVARCHAR (500) NULL
);
```

---

## 7. Excel Templates

### 7.1. Template Chuẩn - `export_danh_muc_chung.xlsx`

**Location:** `UNI.Resident.API/templates/exports/commonlists/export_danh_muc_chung.xlsx`

**Sử dụng cho:**
- ✅ **Import Template** (GetImportTemp) - Download template Excel để import
- ✅ **Export Data** (SetExport) - Export dữ liệu ra Excel

**Đặc điểm:**
- Template chung cho tất cả nghiệp vụ
- Không cần tạo template riêng cho mỗi nghiệp vụ
- FlexcellUtils tự động map dữ liệu từ DataSet vào template

---

## 8. Quick Start - Tạo Import/Export mới

### 8.1. Checklist Chi tiết

1. **Tạo C# Model**
2. **Tạo SQL UDTT**
3. **Tạo Import Template SP**
4. **Tạo Export SP**
5. **Tạo Import SP**
6. **Implement Repository**
7. **Implement Service**
8. **Implement Controller**

---

## 9. Common Issues & Solutions

### 9.1. Import Issues

**Issue:** Data không được lưu vào database  
**Solution:** Kiểm tra `@accept` parameter trong SP (1=validate, 0=save)

### 9.2. Export Issues

**Issue:** File Excel rỗng  
**Solution:** Kiểm tra stored procedure trả về data đúng

---

## 10. Best Practices

### 10.1. Do's

✅ **Always:**
- **Đồng bộ 4 layer**: C# Model ↔ SQL UDTT ↔ Import Template SP ↔ Export SP
- **Tên cột đúng quy tắc**: Tiếng Anh cho Model/UDTT, Tiếng Việt cho SP SELECT
- **Thứ tự cột giống nhau** trong tất cả các layer
- **Sử dụng template chuẩn** `export_danh_muc_chung.xlsx`

### 10.2. Don'ts

❌ **Never:**
- **Dùng tiếng Việt trong C# Model hoặc SQL UDTT**
- **Tạo template Excel riêng** cho mỗi nghiệp vụ
- **Làm sai thứ tự cột** giữa các layer

---

**End of Document**  
**Date**: 2025-01-27  
**Version**: 3.0


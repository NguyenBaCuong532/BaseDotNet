# Coding Standards - Resident API

Tài liệu này định nghĩa các chuẩn mực lập trình (coding standards) cho dự án **Resident API** để đảm bảo code có chất lượng cao, nhất quán và dễ bảo trì.

## 1. Nguyên tắc chung

### 1.1. SOLID Principles

- **S - Single Responsibility:** Mỗi class chỉ có một lý do để thay đổi
- **O - Open/Closed:** Mở cho mở rộng, đóng cho sửa đổi
- **L - Liskov Substitution:** Interface và implementation có thể thay thế cho nhau
- **I - Interface Segregation:** Nhiều interface cụ thể hơn là một interface tổng quát
- **D - Dependency Inversion:** Phụ thuộc vào abstraction, không phụ thuộc vào concrete

### 1.2. DRY (Don't Repeat Yourself)

- Tránh duplicate code
- Sử dụng base classes và helper methods
- Tái sử dụng code thông qua shared libraries (`uni-common`)

### 1.3. KISS (Keep It Simple, Stupid)

- Giữ code đơn giản, dễ hiểu
- Tránh over-engineering
- Ưu tiên clarity hơn cleverness

## 2. Naming Conventions

Chi tiết đầy đủ xem tại: [01_Naming_Conventions.md](01_Naming_Conventions.md)

### Tóm tắt

- **Classes/Interfaces:** PascalCase (`PersonService`, `IPersonRepository`)
- **Methods:** PascalCase (`GetPersonInfo`, `SetPersonDraft`)
- **Properties:** PascalCase (`CurrentUserId`, `GridKey`)
- **Private Fields:** camelCase với prefix `_` (`_logger`, `_repository`)
- **Local Variables:** camelCase (`result`, `userId`)
- **Constants:** UPPER_SNAKE_CASE (`ALLOW_SPECIFIC_ORIGINS`)

## 3. Code Organization

### 3.1. File Structure

```csharp
// 1. Usings (sorted alphabetically, system namespaces first)
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using UNI.Common;
using UNI.Resident.BLL.BusinessInterfaces;

// 2. Namespace
namespace UNI.Resident.API.Controllers.Version2
{
    // 3. Class documentation (if needed)
    /// <summary>
    /// Controller for managing notifications
    /// </summary>
    // 4. Class definition
    public class PersonController : UniController
    {
        // 5. Private fields
        private readonly IPersonService _PersonService;
        private readonly ILogger<PersonController> _logger;

        // 6. Constructor
        public PersonController(
            IPersonService PersonService,
            ILogger<PersonController> logger)
        {
            _PersonService = PersonService;
            _logger = logger;
        }

        // 7. Public methods
        // 8. Private methods
    }
}
```

### 3.2. Method Organization

- Constructor đầu tiên
- Public methods tiếp theo
- Protected methods
- Private methods cuối cùng
- Sắp xếp theo alphabet trong cùng nhóm (nếu logic cho phép)

## 4. Coding Practices

### 4.1. Controllers (API Layer)

#### 4.1.1. Controller Structure Pattern

```csharp
/// <summary>
/// PersonController - Quản lý học viên/nhân viên
/// Full CRUD với getFilter, getPage, getInfo, setDraft, setInfo, delInfo, setImport, setExport,  GetImportTemp, getList
/// </summary>
public class PersonController : UniController
{
    private readonly IPersonService _personService;

    /// <summary>
    /// Thông tin khởi tạo
    /// </summary>
    /// <param name="personService"></param>
    /// <param name="appSettings"></param>
    /// <param name="logger"></param>
    /// <param name="storageService"></param>
    public PersonController(
        IPersonService personService,
        IOptions<AppSettings> appSettings,
        ILoggerFactory logger,
        IApiStorageService storageService) : base(appSettings, logger, storageService)
    {
        _personService = personService;
    }

    // API endpoints ở đây...
}
```

#### 4.1.2. Basic CRUD Endpoints

**a) GetFilter - Lấy danh sách filter options**

```csharp
/// <summary>
/// GetFilter - Lấy danh sách filter options
/// </summary>
/// <returns></returns>
[HttpGet]
public async Task<BaseResponse<CommonViewInfo>> GetFilter()
{
    try
    {
        var result = await _personService.GetPersonFilter();
        return GetResponse<CommonViewInfo>(ApiResult.Success, result);
    }
    catch (Exception ex)
    {
        return GetErrorResponse<CommonViewInfo>(ApiResult.Error, 500, ex.Message);
    }
}
```

**b) GetInfoPage - Lấy danh sách phân trang**

```csharp
/// <summary>
/// GetInfoPage - Lấy danh sách phân trang
/// </summary>
/// <param name="flt"></param>
/// <returns></returns>
[HttpGet]
public async Task<BaseResponse<CommonDataPage>> GetInfoPage(
    [FromQuery] PersonFilterRequest flt)
{
    var result = await _personService.GetPersonPage(flt);
    return GetResponse<CommonDataPage>(ApiResult.Success, result);
}
```

**c) GetInfo - Lấy thông tin chi tiết**

```csharp
/// <summary>
/// GetInfo - Lấy thông tin chi tiết 1 người
/// </summary>
/// <param name="oid">Person ID</param>
/// <returns></returns>
[HttpGet]
public async Task<BaseResponse<PersonInfo>> GetInfo([FromQuery] Guid? oid)
{
    var result = await _personService.GetPersonInfo(oid);
    return GetResponse(ApiResult.Success, result);
}
```

**d) SetDraft - Tạo bản nháp**

```csharp
/// <summary>
/// SetDraft - Tạo bản nháp thông tin người
/// </summary>
/// <param name="draft">Thông tin người</param>
/// <returns></returns>
[HttpPost]
public async Task<BaseResponse<PersonInfo>> SetDraft([FromBody] PersonInfo draft)
{
    var result = await _personService.SetPersonDraft(draft);
    return GetResponse(ApiResult.Success, result);
}
```

**e) SetInfo - Thêm mới hoặc cập nhật**

```csharp
/// <summary>
/// SetInfo - Thêm mới hoặc cập nhật thông tin người
/// </summary>
/// <param name="info">Thông tin người</param>
/// <returns></returns>
[HttpPost]
public async Task<BaseResponse<string>> SetInfo([FromBody] PersonInfo info)
{
    var result = await _personService.SetPersonInfo(info);
    return GetResponse<string>(result.valid ? ApiResult.Success : ApiResult.Error, result.messages);
}
```

**f) DelInfo - Xóa (soft delete)**

```csharp
/// <summary>
/// DelInfo - Xóa thông tin người (soft delete)
/// </summary>
/// <param name="oid">Person ID</param>
/// <returns></returns>
[HttpDelete]
public async Task<BaseResponse<string>> DelInfo([FromQuery] Guid oid)
{
    var result = await _personService.DelPersonInfo(oid);
    return GetResponse<string>(result.valid ? ApiResult.Success : ApiResult.Error, result.messages);
}
```

**g) GetImportTemp - Lấy file mẫu import**

```csharp
/// <summary>
/// GetImportTemp - Lấy file mẫu import
/// </summary>
/// <returns></returns>
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

#### 4.1.3. Controller Best Practices

**Quy tắc:**

- ✅ Kế thừa từ `UniController` hoặc các base controller khác (theo module)
- ✅ Inject services qua constructor: `IService`, `IOptions<AppSettings>`, `ILoggerFactory`, `IApiStorageService`
- ✅ Sử dụng `GetResponse<T>(ApiResult.Success, data)` và `GetErrorResponse<T>(ApiResult.Error, statusCode, message)`
- ✅ Return type: `BaseResponse<T>` với generic type cụ thể
- ✅ Handle exceptions với try-catch và log lỗi (cho các endpoint quan trọng)
- ✅ Sử dụng async/await cho tất cả I/O operations
- ✅ XML documentation cho tất cả methods
- ✅ Sử dụng `[FromQuery]` cho query parameters, `[FromBody]` cho request body
- ✅ Sử dụng `[HttpDelete]` cho DELETE operations
- ✅ Kiểm tra `result.valid` cho SetInfo/DelInfo để trả về đúng status code
- ❌ KHÔNG chứa business logic trong controller
- ❌ KHÔNG truy cập repository trực tiếp
- ❌ KHÔNG include try-catch nếu không cần xử lý đặc biệt (để base class xử lý)
- ❌ KHÔNG return null, luôn return BaseResponse với status code phù hợp

#### 4.1.4. Endpoint Naming Convention

**Standard CRUD Endpoints:**

| Endpoint | HTTP Method | Purpose | Return Type |
|----------|-------------|---------|-------------|
| `GetFilter` | GET | Filter options | `BaseResponse<CommonViewInfo>` |
| `GetInfoPage` | GET | Paginated list | `BaseResponse<CommonDataPage>` |
| `GetInfo` | GET | Single record detail | `BaseResponse<EntityInfo>` |
| `SetDraft` | POST | Create draft | `BaseResponse<EntityInfo>` |
| `SetInfo` | POST | Create/Update | `BaseResponse<string>` |
| `DelInfo` | DELETE | Soft delete | `BaseResponse<string>` |
| `SetImport` | POST | Import Excel | `BaseResponse<ImportListPage>` |
| `GetImportTemp` | GET | Download import template | `FileStreamResult` |
| `SetExport` | GET/POST | Export Excel | `FileStreamResult` |
| `GetList` | GET | Simple list (dropdown) | `BaseResponse<List<CommonValue>>` |

**Response Pattern:**

- **Success**: `status: 1`, `data: <T>`, `message: null`
- **Error**: `status: 0`, `data: null`, `message: "Error description"`
- **SetInfo/DelInfo**: Check `result.valid` để trả về đúng status code

### 4.2. Services (BLL Layer)

```csharp
public class PersonService : IPersonService
{
    private readonly IPersonRepository _personRepository;

    public PersonService(IPersonRepository personRepository)
    {
        _personRepository = personRepository;
    }

    #region Person Management
    public async Task<CommonViewInfo> GetPersonFilter()
    {
        return await _personRepository.GetPersonFilter();
    }

    public Task<CommonDataPage> GetPersonPage(PersonFilterRequest flt)
    {
        return _personRepository.GetPersonPage(flt);
    }

    public async Task<PersonInfo> GetPersonInfo(Guid? id)
    {
        return await _personRepository.GetPersonInfo(id);
    }

    public async Task<BaseValidate> SetPersonInfo(PersonInfo person)
    {
        return await _personRepository.SetPersonInfo(person);
    }

    public async Task<BaseValidate> DelPersonInfo(Guid id)
    {
        return await _personRepository.DelPersonInfo(id);
    }

    #endregion

    #region Statistics & Dashboard
    public async Task<PersonStatistics> GetPersonStatistics()
    {
        return await _personRepository.GetPersonStatistics();
    }

    public async Task<object> GetPersonDashboard()
    {
        return await _personRepository.GetPersonDashboard();
    }
    #endregion
}
```

**Quy tắc:**

- ✅ Implement interface tương ứng (`IPersonService`)
- ✅ Inject repository qua constructor (chỉ repository, không cần config/logger)
- ✅ Services chủ yếu passthrough đến repository
- ✅ Sử dụng `#region` để tổ chức code theo nhóm chức năng
- ✅ Return types cụ thể: `CommonViewInfo`, `CommonDataPage`, `PersonInfo`, `BaseValidate`
- ✅ Async methods đơn giản, ít business logic phức tạp
- ✅ Tên methods theo pattern: `Get{Entity}Filter`, `Get{Entity}Page`, `Get{Entity}Info`, `Set{Entity}Info`, `Del{Entity}Info`
- ❌ KHÔNG truy cập database trực tiếp
- ❌ KHÔNG chứa HTTP-specific logic
- ❌ KHÔNG validate input (để repository xử lý)

### 4.3. Repositories (DAL Layer)

**QUAN TRỌNG:** Tất cả repositories PHẢI:

- ✅ Kế thừa từ `UniBaseRepository`
- ✅ CHỈ gọi Stored Procedures, TUYỆT ĐỐI KHÔNG viết raw SQL
- ✅ Sử dụng helper methods của `UniBaseRepository`
- ✅ Inject `IUniCommonBaseRepository` qua constructor
- ✅ Sử dụng `const string` cho tên stored procedure
- ✅ Truyền parameters dưới dạng anonymous objects `new { ... }`
- ❌ KHÔNG chứa business logic
- ❌ KHÔNG validate business rules
- ❌ KHÔNG truy cập database trực tiếp qua connection string

#### 4.3.1. Repository Constructor Pattern

```csharp
public class VehicleRepository : UniBaseRepository, IVehicleRepository
{
    public VehicleRepository(IUniCommonBaseRepository commonInfo) : base(commonInfo)
    {
    }
}
```

#### 4.3.2. Helper Methods của UniBaseRepository

**a) GetTableFilterAsync** - Lấy filter options cho màn hình

```csharp
/// <summary>
/// GetVehicleFilter - Lấy danh sách filter options
/// </summary>
public async Task<CommonViewInfo> GetVehicleFilter()
{
    const string storedProcedure = "core_vehicle_filter";
    return await base.GetTableFilterAsync(storedProcedure, new { });
}
```

**b) GetDataListPageAsync** - Lấy danh sách phân trang

```csharp
/// <summary>
/// GetVehiclePage - Lấy danh sách phân trang
/// </summary>
public Task<CommonDataPage> GetVehiclePage(VehicleFilterRequest flt)
{
    const string storedProcedure = "sp_core_vehicle_page";
    return base.GetDataListPageAsync(storedProcedure, flt,
        new { flt.VehicleType, flt.OwnerId, flt.Status });
}
```

**c) GetFieldsAsync** - Lấy thông tin chi tiết một record

```csharp
/// <summary>
/// GetVehicleInfo - Lấy thông tin chi tiết phương tiện
/// </summary>
public async Task<VehicleInfo> GetVehicleInfo(Guid? oid)
{
    const string storedProcedure = "sp_core_vehicle_field";
    return await base.GetFieldsAsync<VehicleInfo>(storedProcedure, new { oid });
}
```

**d) SetInfoAsync** - Thêm mới hoặc cập nhật

```csharp
/// <summary>
/// SetVehicleInfo - Thêm mới hoặc cập nhật phương tiện
/// </summary>
public async Task<BaseValidate> SetVehicleInfo(VehicleInfo vehicle)
{
    const string storedProcedure = "sp_core_vehicle_set";
    return await base.SetInfoAsync<BaseValidate>(storedProcedure, vehicle,
        new { oid = vehicle.oid });
}
```

**e) DeleteAsync** - Xóa record (soft delete)

```csharp
/// <summary>
/// DelVehicleInfo - Xóa phương tiện (soft delete)
/// </summary>
public async Task<BaseValidate> DelVehicleInfo(Guid oid)
{
    const string storedProcedure = "sp_core_vehicle_del";
    return await base.DeleteAsync(storedProcedure, new { oid });
}
```

**f) GetListAsync** - Lấy danh sách đơn giản (dropdown, list)

```csharp
/// <summary>
/// GetVehicleList - Lấy danh sách đơn giản (dropdown)
/// </summary>
public async Task<List<CommonValue>> GetVehicleList(string filter)
{
    const string storedProcedure = "sp_core_vehicle_list";
    return await base.GetListAsync<CommonValue>(storedProcedure, new { filter });
}

/// <summary>
/// GetVehicles - Lấy danh sách với nhiều tham số
/// </summary>
public async Task<List<CommonValue>> GetVehicles(string vehicleType, string filter)
{
    const string storedProcedure = "sp_core_vehicle_get";
    return await base.GetListAsync<CommonValue>(storedProcedure,
        new { vehicleType, filter });
}
```

**g) SetAsync** - Cập nhật hoặc thực thi action

```csharp
/// <summary>
/// CheckInGuest - Check-in khách
/// </summary>
public async Task<BaseValidate> CheckInGuest(GuestCheckInRequest request)
{
    const string storedProcedure = "sp_guest_checkin";
    return await base.SetAsync(storedProcedure, request);
}

/// <summary>
/// ApproveGuest - Duyệt khách với tham số đơn giản
/// </summary>
public async Task<BaseValidate> ApproveGuest(Guid id, string note)
{
    const string storedProcedure = "sp_guest_approve";
    return await base.SetAsync(storedProcedure, new { id, note });
}
```

**h) GetFirstOrDefaultAsync** - Lấy một record duy nhất

```csharp
/// <summary>
/// GetGuestStatistics - Thống kê khách
/// </summary>
public async Task<GuestStatistics> GetGuestStatistics()
{
    const string storedProcedure = "sp_guest_statistics";
    return await base.GetFirstOrDefaultAsync<GuestStatistics>(storedProcedure, new { });
}

/// <summary>
/// GetDeviceByCodeAsync - Lấy thiết bị theo mã code
/// </summary>
public async Task<DeviceInfo> GetDeviceByCodeAsync(string deviceCode)
{
    const string storedProcedure = "sp_device_get_by_code";
    return await base.GetFirstOrDefaultAsync<DeviceInfo>(storedProcedure,
        new { deviceCode });
}
```

**i) GetDataSetAsync** - Lấy nhiều result sets (cho export)

```csharp
/// <summary>
/// SetVehicleExport - Export danh sách phương tiện ra Excel
/// </summary>
public async Task<DataSet> SetVehicleExport(VehicleFilterRequest flt)
{
    const string storedProcedure = "sp_core_vehicle_export";
    return await base.GetDataSetAsync(storedProcedure, param =>
    {
        // Add parameters if needed
    });
}
```

**j) SetImport** - Import dữ liệu từ Excel

```csharp
/// <summary>
/// SetVehicleImport - Import phương tiện từ Excel
/// </summary>
public Task<ImportListPage> SetVehicleImport(VehicleImportSet importSet, int serial_is)
{
    const string storedProcedure = "sp_core_vehicle_imports";
    return base.SetImport<VehicleImport, VehicleImportSet>(
        storedProcedure,
        importSet,
        "vehicles",
        DataTableTypes.VEHICLE_IMPORT_TYPE,
        new { serial_is });
}
```

#### 4.3.3. Repository với nhiều chức năng (Full Example)

```csharp
public class GuestRepository : UniBaseRepository, IGuestRepository
{
    public GuestRepository(IUniCommonBaseRepository commonInfo) : base(commonInfo)
    {
    }

    #region Guest Management

    public async Task<CommonViewInfo> GetGuestFilter()
    {
        const string storedProcedure = "visit_guest_info_filter";
        return await base.GetTableFilterAsync(storedProcedure, new { });
    }

    public Task<CommonDataPage> GetGuestPage(GuestFilterRequest flt)
    {
        const string storedProcedure = "sp_visit_guest_info_page";
        return base.GetDataListPageAsync(storedProcedure, flt,
            new { flt.HostPersonId, flt.Status });
    }

    public async Task<GuestInfo> GetGuestInfo(Guid? oid)
    {
        const string storedProcedure = "sp_visit_guest_info_field";
        return await base.GetFieldsAsync<GuestInfo>(storedProcedure, new { oid });
    }

    public async Task<BaseValidate> SetGuestInfo(GuestInfo guest)
    {
        const string storedProcedure = "sp_visit_guest_info_set";
        return await base.SetInfoAsync<BaseValidate>(storedProcedure, guest,
            new { guest.Oid });
    }

    public async Task<BaseValidate> DelGuestInfo(Guid oid)
    {
        const string storedProcedure = "sp_visit_guest_info_del";
        return await base.DeleteAsync(storedProcedure, new { oid });
    }

    #endregion

    #region Guest Queries

    public async Task<List<GuestInfo>> GetGuestsByHost(Guid hostPersonId)
    {
        const string storedProcedure = "sp_guest_by_host";
        return await base.GetListAsync<GuestInfo>(storedProcedure,
            new { hostPersonId });
    }

    public async Task<List<GuestInfo>> SearchGuests(string keyword)
    {
        const string storedProcedure = "sp_guest_search";
        return await base.GetListAsync<GuestInfo>(storedProcedure, new { keyword });
    }

    #endregion
}
```

#### 4.3.4. Các Pattern quan trọng

**✅ ĐÚNG - Sử dụng UniBaseRepository helper methods:**

```csharp
public async Task<DeviceInfo> GetDeviceInfo(Guid? oid)
{
    const string storedProcedure = "sp_device_info_field";
    return await base.GetFieldsAsync<DeviceInfo>(storedProcedure, new { oid });
}
```

**❌ SAI - Truy cập database trực tiếp:**

```csharp
public async Task<DeviceInfo> GetDeviceInfo(Guid? oid)
{
    using (var connection = new SqlConnection(_connectionString))
    {
        // KHÔNG làm như này!
        var sql = "SELECT * FROM devices WHERE oid = @oid";
        return await connection.QueryFirstAsync<DeviceInfo>(sql, new { oid });
    }
}
```

**✅ ĐÚNG - Truyền parameters đơn giản:**

```csharp
public async Task<bool> UpdateLastHeartbeatAsync(string deviceCode, DateTime heartbeatTime)
{
    const string storedProcedure = "sp_device_update_heartbeat";
    var result = await base.SetAsync<BaseValidate>(storedProcedure,
        new { deviceCode, heartbeatTime });
    return result?.valid ?? false;
}
```

**✅ ĐÚNG - Truyền parameters từ filter object:**

```csharp
public Task<AllGuestsVisitHistoryPage> GetAllGuestsVisitHistoryPage(
    AllGuestsVisitHistoryFilterRequest flt)
{
    const string storedProcedure = "sp_guest_visit_history_page_all";

    return GetDataListPageAsync<AllGuestsVisitHistoryPage>(storedProcedure, flt, new
    {
        guestName = flt.GuestName,
        sponsorName = flt.SponsorName,
        dateFrom = flt.DateFrom,
        dateTo = flt.DateTo,
        status = flt.Status,
        sortField = flt.SortField,
        sortDir = flt.SortDir
    });
}
```

**✅ ĐÚNG - Sử dụng CommonInfo từ base class:**

```csharp
public async Task<string> UploadVehicleDocument(Guid vehicleId, string documentType,
    string documentUrl, string documentName)
{
    const string storedProcedure = "sp_vehicle_document_set";
    await base.SetAsync(storedProcedure, new
    {
        vehicle_oid = vehicleId,
        document_type = documentType,
        document_url = documentUrl,
        document_name = documentName,
        created_by = CommonInfo.UserId  // ✅ Lấy từ CommonInfo
    });
    return documentUrl;
}
```

#### 4.3.5. Tổng kết Quy tắc Repository

1. **LUÔN LUÔN** kế thừa từ `UniBaseRepository`
2. **LUÔN LUÔN** inject `IUniCommonBaseRepository` qua constructor
3. **CHỈ** gọi Stored Procedures, không raw SQL
4. **LUÔN** dùng `const string` cho tên stored procedure
5. **LUÔN** truyền parameters bằng anonymous objects
6. **LUÔN** dùng helper methods của base class
7. **KHÔNG BAO GIỜ** tự quản lý connection strings
8. **KHÔNG BAO GIỜ** viết SQL inline trong code
9. **KHÔNG BAO GIỜ** chứa business logic trong repository

#### 4.3.6. Quản lý Database Objects

**QUAN TRỌNG:** Tất cả các database objects (stored procedures, tables, types, views, functions) PHẢI được lưu script vào source control.

**Cấu trúc thư mục:**

```
dbSHome/
└── dbo/
    ├── User Defined Types/      // Các kiểu dữ liệu tự định nghĩa
    ├── Tables/                  // Các bảng database
    ├── Stored Procedures/       // Các stored procedures
    ├── Views/                   // Các views
    ├── Functions/               // Các functions
    └── Scripts/                 // Các scripts khác (seed data, migration, etc.)
```

**Quy tắc:**

**1. Stored Procedures**

- ✅ Mọi stored procedure mới PHẢI lưu script vào `dbSHome/dbo/Stored Procedures/`
- ✅ Khi chỉnh sửa stored procedure, PHẢI cập nhật file script tương ứng
- ✅ Tên file theo format: `sp_{module}_{entity}_{action}.sql`
- ✅ Script phải chứa `CREATE OR ALTER PROCEDURE` và tham số mặc định `@userId UNIQUEIDENTIFIER = NULL` và `@acceptLanguage NVARCHAR(50) = N'vi-VN'`

```sql
-- File: dbSHome/dbo/Stored Procedures/sp_core_org_unit_field.sql
CREATE OR ALTER PROCEDURE [dbo].[sp_core_org_unit_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @oid uniqueidentifier = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    -- Stored procedure logic here
END
```

**1.1. Field Procedures Pattern (`sp_{entity}_field`)**

**QUAN TRỌNG:** Khi tạo hoặc cập nhật các stored procedure `_field` (ví dụ: `sp_core_person_field`, `sp_device_info_field`, `sp_core_vehicle_field`), PHẢI tuân thủ các nguyên tắc sau để tránh lỗi khi tạo temp table:

**Nguyên tắc bắt buộc:**

1. **Tạo temp table với structure đầy đủ:**
   ```sql
   -- ✅ ĐÚNG - Tạo temp table với structure đầy đủ từ bảng
   SELECT TOP 0 b.*
   INTO #tempIn
   FROM [table_name] b;
   
   -- ❌ SAI - Không tạo được structure nếu không có record
   SELECT b.*
   INTO #tempIn
   FROM [table_name] b
   WHERE b.[oid] = @oid;
   ```

2. **Kiểm tra record tồn tại trước khi INSERT:**
   ```sql
   -- ✅ ĐÚNG
   IF EXISTS (SELECT 1 FROM [table_name] WHERE [oid] = @oid)
   BEGIN
       INSERT INTO #tempIn
       SELECT b.*
       FROM [table_name] b
       WHERE b.[oid] = @oid;
   END
   ELSE
   BEGIN
       -- Tạo record mới với giá trị mặc định
   END
   ```

3. **🔴 QUAN TRỌNG: Đặt giá trị mặc định cho các field NOT NULL:**
   
   **BƯỚC 1:** Kiểm tra cấu trúc bảng để xác định các field NOT NULL:
   ```sql
   -- Xem file dbSHome/dbo/Tables/{table_name}.sql
   -- Hoặc query: SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'table_name' AND IS_NULLABLE = 'NO'
   ```

   **BƯỚC 2:** Đặt giá trị mặc định phù hợp cho từng loại field NOT NULL:
   
   ```sql
   -- ✅ ĐÚNG - Đặt giá trị mặc định cho tất cả field NOT NULL
   INSERT INTO #tempIn (
       [oid], [field1], [field2], [field3], [field4], [field5], ...
   ) 
   VALUES (
       @oid, 
       '',           -- NVARCHAR/VARCHAR NOT NULL -> '' (empty string)
       'Default',     -- VARCHAR NOT NULL có DEFAULT -> giá trị mặc định
       'Student',     -- VARCHAR NOT NULL có constraint -> giá trị hợp lệ
       0,             -- BIT NOT NULL -> 0 hoặc 1 (theo DEFAULT)
       1,             -- INT NOT NULL -> 1 hoặc giá trị mặc định
       SYSUTCDATETIME(), -- DATETIME2 NOT NULL -> SYSUTCDATETIME() hoặc GETDATE()
       ...
   );
   ```

   **Bảng giá trị mặc định theo data type:**
   
   | Data Type | NOT NULL Default | Example |
   |-----------|------------------|---------|
   | `NVARCHAR/VARCHAR` | `''` (empty string) | `full_name NOT NULL -> ''` |
   | `VARCHAR` với DEFAULT | Giá trị DEFAULT | `plate_status NOT NULL DEFAULT 'REGISTERED' -> 'REGISTERED'` |
   | `VARCHAR` có CHECK constraint | Giá trị hợp lệ | `person_type NOT NULL CHECK (...) -> 'Student'` |
   | `BIT` | `0` hoặc `1` (theo DEFAULT) | `is_blacklisted NOT NULL DEFAULT 0 -> 0` |
   | `INT` | `1` hoặc giá trị DEFAULT | `app_st NOT NULL DEFAULT 1 -> 1` |
   | `DATETIME2` | `SYSUTCDATETIME()` | `created_at NOT NULL -> SYSUTCDATETIME()` |
   | `UNIQUEIDENTIFIER` | `@oid` hoặc `NEWID()` | `oid NOT NULL -> @oid` (đã có sẵn) |

4. **Ví dụ đầy đủ cho `sp_visit_guest_info_field`:**
   ```sql
   -- Tạo temp table với structure đầy đủ
   SELECT TOP 0 b.*
   INTO #tempIn
   FROM visit_guest_info b;

   -- Insert dữ liệu nếu có record
   IF EXISTS (SELECT 1 FROM visit_guest_info WHERE [oid] = @oid)
   BEGIN
       INSERT INTO #tempIn
       SELECT b.*
       FROM visit_guest_info b
       WHERE b.[oid] = @oid;
   END
   ELSE
   BEGIN
       -- Nếu không có dữ liệu, tạo record mới với đầy đủ columns
       IF @oid IS NULL SET @oid = NEWID();
       
       -- 🔴 QUAN TRỌNG: Kiểm tra các field NOT NULL trong cấu trúc bảng:
       -- visit_guest_info: oid, full_name, is_blacklisted, app_st, created_at
       
       INSERT INTO #tempIn (
           [oid], [full_name], [id_no], [phone], [email], [company],
           [is_blacklisted], [app_st], [code], [purpose], [visit_date],
           [host_person_oid], [vehicle_plate], [avatar_url],
           [created_at], [updated_at]
       ) 
       VALUES (
           @oid, 
           '', '', '', '', '',              -- full_name NOT NULL -> '' (empty string)
           0, 1, '', '', NULL,              -- is_blacklisted NOT NULL -> 0, app_st NOT NULL -> 1
           NULL, '', '',                    -- NULL fields
           SYSUTCDATETIME(), NULL           -- created_at NOT NULL -> SYSUTCDATETIME()
       );
   END
   ```

5. **Checklist khi tạo/cập nhật `_field` procedure:**
   
   - [ ] Đã kiểm tra cấu trúc bảng để xác định các field NOT NULL
   - [ ] Đã dùng `SELECT TOP 0` để tạo temp table structure
   - [ ] Đã kiểm tra record tồn tại trước khi INSERT
   - [ ] Đã đặt giá trị mặc định cho TẤT CẢ field NOT NULL
   - [ ] Đã test với trường hợp `@oid = NULL` (tạo record mới)
   - [ ] Đã test với trường hợp `@oid` không tồn tại (tạo record mới)
   - [ ] Đã test với trường hợp `@oid` tồn tại (lấy record hiện có)

6. **Các lỗi thường gặp cần tránh:**
   
   ```sql
   -- ❌ SAI - Không tạo được temp table nếu không có record
   SELECT b.* INTO #tempIn FROM [table] b WHERE b.[oid] = @oid;
   
   -- ❌ SAI - Thiếu giá trị cho field NOT NULL
   INSERT INTO #tempIn ([oid], [field1]) VALUES (@oid, NULL);  -- field1 NOT NULL
   
   -- ❌ SAI - Không kiểm tra record tồn tại
   INSERT INTO #tempIn ([oid]) VALUES (@oid);  -- Thiếu các field NOT NULL khác
   
   -- ✅ ĐÚNG - Đầy đủ và đúng
   SELECT TOP 0 b.* INTO #tempIn FROM [table] b;
   IF EXISTS (SELECT 1 FROM [table] WHERE [oid] = @oid)
       INSERT INTO #tempIn SELECT * FROM [table] WHERE [oid] = @oid;
   ELSE
       INSERT INTO #tempIn ([oid], [field1], [field2]) 
       VALUES (@oid, '', 1);  -- Đầy đủ giá trị cho field NOT NULL
   ```

**2. User Defined Types**

- ✅ Lưu vào `dbSHome/dbo/User Defined Types/`
- ✅ Tên file theo format: `{TypeName}.sql`
- ✅ Dùng cho Table-Valued Parameters (TVP)

```sql
-- File: dbSHome/dbo/User Defined Types/VehicleImportType.sql
CREATE TYPE [dbo].[VehicleImportType] AS TABLE
(
    [PlateNumber] NVARCHAR(20),
    [VehicleType] NVARCHAR(50),
    [OwnerId] UNIQUEIDENTIFIER
)
```

**3. Tables**

- ✅ Lưu vào `dbSHome/dbo/Tables/`
- ✅ Tên file theo tên bảng: `{TableName}.sql`
- ✅ Include indexes, constraints, foreign keys

```sql
-- File: dbSHome/dbo/Tables/core_vehicles.sql
CREATE TABLE [dbo].[core_vehicles]
(
    [oid] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [plate_number] NVARCHAR(20) NOT NULL,
    [vehicle_type] NVARCHAR(50),
    [owner_id] UNIQUEIDENTIFIER,
    [status] INT DEFAULT 1,
    [created_date] DATETIME DEFAULT GETDATE(),
    [created_by] UNIQUEIDENTIFIER
)
```

**4. Views**

- ✅ Lưu vào `dbSHome/dbo/Views/`
- ✅ Tên file theo format: `vw_{module}_{name}.sql`

```sql
-- File: dbSHome/dbo/Views/vw_core_vehicle_summary.sql
CREATE OR ALTER VIEW [dbo].[vw_core_vehicle_summary]
AS
SELECT
    v.oid,
    v.plate_number,
    v.vehicle_type,
    p.full_name as owner_name
FROM core_vehicles v
LEFT JOIN persons p ON v.owner_id = p.oid
```

**5. Functions**

- ✅ Lưu vào `dbSHome/dbo/Functions/`
- ✅ Tên file theo format: `fn_{name}.sql`

```sql
-- File: dbSHome/dbo/Functions/fn_get_vehicle_status.sql
CREATE OR ALTER FUNCTION [dbo].[fn_get_vehicle_status]
(
    @VehicleId UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Status NVARCHAR(50)
    -- Function logic
    RETURN @Status
END
```

**6. Scripts**

- ✅ Lưu migration scripts vào `dbSHome/dbo/Scripts/`
- ✅ Tên file theo format: `YYYYMMDD_HHmm_{description}.sql`

```sql
-- File: dbSHome/dbo/Scripts/20241031_1430_add_vehicle_color_column.sql
ALTER TABLE [dbo].[core_vehicles]
ADD [color] NVARCHAR(50) NULL
GO
```

**Workflow khi tạo/sửa database objects:**

1. **Tạo mới Stored Procedure:**

   ```
   a) Viết stored procedure trong SSMS/Azure Data Studio
   b) Test kỹ stored procedure
   c) Export script ra file và lưu vào dbSHome/dbo/Stored Procedures/
   d) Commit script vào Git
   e) Tạo/cập nhật Repository method để gọi stored procedure
   ```

2. **Chỉnh sửa Stored Procedure:**

   ```
   a) Sửa stored procedure trong SSMS/Azure Data Studio
   b) Test kỹ các thay đổi
   c) Cập nhật file script tương ứng trong dbSHome/dbo/Stored Procedures/
   d) Commit thay đổi vào Git
   e) Cập nhật Repository method nếu có thay đổi signature
   ```

3. **Tạo mới Table:**
   ```
   a) Thiết kế table schema
   b) Tạo table trong database
   c) Lưu CREATE TABLE script vào dbSHome/dbo/Tables/
   d) Tạo migration script vào dbSHome/dbo/Scripts/
   e) Commit cả hai files vào Git
   ```

**Lưu ý quan trọng:**

- 🔴 **LUÔN LUÔN** lưu script trước khi deploy lên production
- 🔴 **KHÔNG BAO GIỜ** thay đổi database mà không có script backup
- 🔴 **PHẢI** review database scripts như review code
- 🔴 **BẮT BUỘC** test scripts trên môi trường dev/staging trước
- ✅ Sử dụng `CREATE OR ALTER PROCEDURE` cho procedures/views/functions để script có thể chạy nhiều lần
- ✅ Include rollback scripts cho mọi thay đổi quan trọng
- ✅ Document breaking changes trong commit message

### 4.4. Models & DTOs

```csharp
// Domain Model
public class PersonInfo
{
    public string PersonId { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public DateTime CreatedDate { get; set; }
}

// Request DTO
public class PersonInfoSet
{
    public string PersonId { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public List<PersonTo> PersonTos { get; set; }
}

// Filter DTO
public class FilterInpPerson : FilterBase
{
    public string source_ref { get; set; }
    public string Person_type { get; set; }
}
```

**Quy tắc:**

- ✅ Models là POCO (Plain Old CLR Objects)
- ✅ Properties là public với get/set
- ✅ Sử dụng proper data types
- ✅ DTOs khác với domain models (nếu cần)
- ✅ Filter classes kế thừa từ `FilterBase`
- ❌ KHÔNG chứa logic trong models

## 5. Best Practices

### 5.1. Async/Await

```csharp
// ✅ Good
public async Task<PersonInfo> GetPersonAsync(string id)
{
    return await _repository.GetPersonAsync(id);
}

// ❌ Bad - Blocking
public PersonInfo GetPerson(string id)
{
    return _repository.GetPersonAsync(id).Result; // Deadlock risk!
}

// ❌ Bad - Unnecessary async
public async Task<int> Add(int a, int b)
{
    return a + b; // No await, unnecessary async
}
```

### 5.2. Exception Handling

```csharp
// ✅ Good - Log and handle at appropriate level
try
{
    var result = await _service.GetData();
    return GetResponse(result);
}
catch (Exception ex)
{
    _logger.LogError(ex, "Error in GetData for userId: {UserId}", UserId);
    return GetErrorResponse<DataType>("Failed to get data");
}

// ❌ Bad - Swallow exceptions
try
{
    var result = await _service.GetData();
}
catch
{
    // Silent failure - BAD!
}

// ❌ Bad - Catching and re-throwing without value
catch (Exception ex)
{
    throw ex; // Loses stack trace! Use "throw;" instead
}
```

### 5.3. Dependency Injection

```csharp
// ✅ Good - Constructor injection
public class PersonService : IPersonService
{
    private readonly IPersonRepository _repository;

    public PersonService(IPersonRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }
}

// ❌ Bad - Service locator anti-pattern
public class PersonService
{
    private IPersonRepository _repository;

    public PersonService()
    {
        _repository = ServiceLocator.Get<IPersonRepository>(); // Anti-pattern!
    }
}
```

### 5.4. Null Checking

```csharp
// ✅ Good - Modern C# patterns
public void ProcessUser(User user)
{
    if (user is null)
        throw new ArgumentNullException(nameof(user));

    // Or use null-conditional operator
    var name = user?.Name ?? "Unknown";
}

// ✅ Good - Null-coalescing
string displayName = userName ?? "Guest";

// ✅ Good - Pattern matching (C# 9+)
if (user is not null)
{
    ProcessValidUser(user);
}
```

### 5.5. LINQ Best Practices

```csharp
// ✅ Good - Readable and efficient
var activeUsers = users
    .Where(u => u.IsActive)
    .OrderBy(u => u.Name)
    .ToList();

// ❌ Bad - Multiple enumerations
var count = users.Where(u => u.IsActive).Count();
var items = users.Where(u => u.IsActive).ToList(); // Enumerated twice!

// ✅ Better
var activeUsersList = users.Where(u => u.IsActive).ToList();
var count = activeUsersList.Count;
```

### 5.6. String Handling

```csharp
// ✅ Good - Use string interpolation
var message = $"User {userId} logged in at {DateTime.Now}";

// ❌ Bad - String concatenation
var message = "User " + userId + " logged in at " + DateTime.Now;

// ✅ Good - StringBuilder for loops
var sb = new StringBuilder();
foreach (var item in items)
{
    sb.AppendLine($"Item: {item}");
}

// ✅ Good - Check for null/empty
if (string.IsNullOrWhiteSpace(input))
    return "Default value";
```

## 6. Comments & Documentation

### 6.1. XML Documentation

```csharp
/// <summary>
/// Gets notification information by ID
/// </summary>
/// <param name="PersonId">The notification ID</param>
/// <param name="userId">The current user ID</param>
/// <param name="acceptLanguage">Preferred language</param>
/// <returns>Notification information if found</returns>
/// <exception cref="ArgumentException">Thrown when PersonId is null or empty</exception>
public async Task<PersonInfo> GetPersonInfo(
    string PersonId,
    string userId,
    string acceptLanguage)
{
    // Implementation
}
```

### 6.2. Code Comments

```csharp
// ✅ Good - Explains WHY, not WHAT
// We need to delay processing by 1 second to avoid overwhelming the external API
await Task.Delay(1000);

// ❌ Bad - States the obvious
// Add 1 to the counter
counter = counter + 1;

// ✅ Good - Clarifies complex logic
// Check if user has permission OR is an admin OR is the owner of the resource
if (user.HasPermission(resource) || user.IsAdmin || resource.OwnerId == user.Id)
{
    // Grant access
}
```

### 6.3. TODO Comments

```csharp
// TODO: Implement caching to improve performance
// TODO: Add input validation for edge cases
// FIXME: This breaks when userId is null
// HACK: Temporary workaround until API v2 is ready
```

## 7. Testing Standards

### 7.1. Unit Tests

```csharp
[Fact]
public async Task GetPersonInfo_WithValidId_Returns()
{
    // Arrange
    var mockRepo = new Mock<IPersonRepository>();
    mockRepo.Setup(r => r.GetPersonInfo(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>()))
            .ReturnsAsync(new PersonInfo { PersonId = "123" });

    var service = new PersonService(mockRepo.Object);

    // Act
    var result = await service.GetPersonInfo("123", "user1", "en");

    // Assert
    Assert.NotNull(result);
    Assert.Equal("123", result.PersonId);
}
```

### 7.2. Test Naming

- Pattern: `MethodName_Scenario_ExpectedResult`
- Examples:
  - `GetPersonInfo_WithValidId_ReturnsNotification`
  - `SetPersonInfo_WithNullTitle_ThrowsArgumentException`
  - `DeletePerson_WhenNotFound_ReturnsFalse`

## 8. Performance Guidelines

### 8.1. Database Access

- ✅ Sử dụng async methods cho tất cả database calls
- ✅ Sử dụng pagination cho large datasets
- ✅ Dispose connections và resources đúng cách
- ❌ KHÔNG load toàn bộ data rồi filter trong memory
- ❌ KHÔNG gọi database trong vòng lặp (N+1 problem)

### 8.2. Caching

```csharp
// ✅ Cache expensive operations
private readonly IMemoryCache _cache;

public async Task<List<Category>> GetCategories()
{
    return await _cache.GetOrCreateAsync("categories", async entry =>
    {
        entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
        return await _repository.GetAllCategories();
    });
}
```

## 9. Security Guidelines

### 9.1. Input Validation

```csharp
// ✅ Always validate user input
public async Task<BaseResponse> SetPersonInfo(PersonInfoSet model)
{
    if (model == null)
        return GetErrorResponse("Model cannot be null");

    if (string.IsNullOrWhiteSpace(model.Title))
        return GetErrorResponse("Title is required");

    if (model.Title.Length > 500)
        return GetErrorResponse("Title too long");

    // Process valid input
}
```

### 9.2. SQL Injection Prevention

- ✅ CHỈ sử dụng Stored Procedures
- ✅ Sử dụng parameterized queries (Dapper)
- ❌ KHÔNG concatenate user input vào SQL strings

### 9.3. Authentication & Authorization

```csharp
// ✅ Always use [Authorize] attribute
[Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
public class SecureController : UniController
{
    // Secured endpoints
}

// ✅ Use UserId from claims, never trust user input
var currentUserId = this.UserId; // From base controller
```

## 10. Git Commit Standards

### 10.1. Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 10.2. Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### 10.3. Examples

```
feat(Person): add push notification support

Implemented real-time push notifications using SignalR.
Added PersonHub and updated PersonService.

Closes #123
```

```
fix(auth): resolve token expiration issue

Fixed bug where tokens were not being refreshed properly.

Fixes #456
```

## Tổng kết

Tuân thủ các coding standards này giúp:

- ✅ Code dễ đọc và dễ hiểu
- ✅ Dễ bảo trì và mở rộng
- ✅ Giảm bugs và technical debt
- ✅ Team collaboration hiệu quả hơn
- ✅ Onboarding developers mới nhanh hơn

**Luôn nhớ: Clean code là code mà người khác có thể hiểu và maintain!**


# 00. Cấu Trúc Project

## 📋 TỔNG QUAN DỰ ÁN

**UNI Resident API** là hệ thống API quản lý căn hộ thông minh (Smart Home Management System) được xây dựng trên nền tảng .NET 8.0 với kiến trúc 3 tầng (3-Layer Architecture).

### Thông Tin Dự Án
- **Tên dự án**: UNI Resident API
- **Framework**: .NET 8.0
- **Kiến trúc**: 3-Layer Architecture (Presentation → Business Logic → Data Access)
- **Database**: SQL Server (dbSHome)
- **Authentication**: JWT Bearer với Keycloak
- **API Documentation**: Swagger/NSwag

---

## 🏗️ KIẾN TRÚC TỔNG THỂ

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│                  UNI.RESIDENT.API                            │
│  • Controllers                                               │
│  • Filters & Attributes                                      │
│  • Extensions                                                │
│  • Startup & Configuration                                   │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                       │
│                  UNI.Resident.BLL                            │
│  • BusinessService                                           │
│  • BusinessInterfaces                                        │
│  • Business Logic & Validation                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                   DATA ACCESS LAYER                          │
│                  UNI.Resident.DAL                            │
│  • Repositories                                              │
│  • Interfaces                                                │
│  • Data Access Logic                                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                      DATA LAYER                              │
│                 UNI.Resident.Model                           │
│  • Entities                                                  │
│  • DTOs                                                      │
│  • View Models                                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                      DATABASE                                │
│                     dbSHome (SQL Server)                     │
│  • 193 Tables                                                │
│  • 587 Stored Procedures                                     │
│  • 77 Functions                                              │
│  • 21 User Defined Types                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 CẤU TRÚC THƯ MỤC DỰ ÁN

### 1. **UNI.RESIDENT.API** - Presentation Layer

Dự án API chính, entry point của hệ thống.

```
UNI.RESIDENT.API/
├── Controllers/                    # API Controllers
│   ├── Version1/                  # API Version 1
│   │   ├── ApartmentController.cs
│   │   ├── CardController.cs
│   │   ├── CardVehicleController.cs
│   │   ├── ElevatorController.cs
│   │   ├── FeeServiceController.cs
│   │   ├── NotifyController.cs
│   │   ├── ReportController.cs
│   │   └── RequestController.cs
│   ├── Version2/                  # API Version 2 (Main)
│   │   ├── Advertisement/
│   │   ├── Aparment/
│   │   ├── Billing/
│   │   ├── Card/
│   │   ├── CardVehicle/
│   │   ├── Elevator/
│   │   ├── Parking/
│   │   ├── Project/
│   │   ├── Reports/
│   │   ├── Request/
│   │   ├── ServiceFee/
│   │   ├── ServicePrice/
│   │   ├── Settings/
│   │   ├── User/
│   │   └── Visitor/
│   └── ServiceAPI/               # External Service APIs
├── Attributes/                    # Custom Attributes
├── Authorization/                 # Authorization Logic
├── Docs/                         # Tài liệu dự án
├── Extensions/                   # Extension Methods
│   └── ServiceCollectionExtensions.cs
├── Filters/                      # Action Filters
├── Reports/                      # Báo cáo templates (.xlsx)
├── templates/                    # Import templates
├── wwwroot/                      # Static files
├── Program.cs                    # Entry point
├── Startup.cs                    # Startup configuration
├── appsettings.json              # Configuration
├── appsettings.development.json
└── appsettings.production.json
```

#### Các Module Chính trong API:

1. **Apartment Management** - Quản lý căn hộ
2. **Card Management** - Quản lý thẻ (thẻ cư dân, thẻ khách, thẻ nội bộ)
3. **Card Vehicle Management** - Quản lý thẻ xe
4. **Elevator Management** - Quản lý thang máy
5. **Request Management** - Quản lý yêu cầu/phản ánh
6. **Notification Management** - Quản lý thông báo
7. **Service Fee Management** - Quản lý phí dịch vụ
8. **Service Price Management** - Quản lý bảng giá
9. **Billing Management** - Quản lý hóa đơn/biên lai
10. **Report Management** - Quản lý báo cáo
11. **Advertisement Management** - Quản lý quảng cáo
12. **User Management** - Quản lý người dùng
13. **Project Management** - Quản lý dự án

---

### 2. **UNI.Resident.BLL** - Business Logic Layer

Tầng xử lý logic nghiệp vụ, validate dữ liệu.

```
UNI.Resident.BLL/
├── BusinessInterfaces/            # Service Interfaces
│   ├── Advertisement/
│   ├── Apartment/
│   ├── Api/
│   ├── App/
│   ├── Card/
│   ├── CardVehicle/
│   ├── Elevator/
│   ├── Invoice/
│   ├── Notify/
│   ├── Request/
│   └── ServicePrice/
├── BusinessService/               # Service Implementations
│   ├── Advertisement/
│   │   ├── AdvertisementService.cs
│   │   └── AdvertisementAnalyticsService.cs
│   ├── Apartment/
│   │   ├── ApartmentService.cs
│   │   ├── FamilyMemberService.cs
│   │   ├── HouseholdService.cs
│   │   └── ProjectService.cs
│   ├── Card/
│   │   ├── CardService.cs
│   │   ├── CardBaseService.cs
│   │   ├── CardDailyService.cs
│   │   ├── CardGuestService.cs
│   │   ├── CardInternalService.cs
│   │   ├── CardResidentService.cs
│   │   └── VehicleCardService.cs
│   ├── CardVehicle/
│   │   ├── VehicleService.cs
│   │   ├── VehicleGuestService.cs
│   │   ├── VehicleInternalService.cs
│   │   ├── VehicleResidentService.cs
│   │   └── VehiclePaymentService.cs
│   ├── Elevator/
│   │   ├── ElevatorService.cs
│   │   ├── ElevatorBuildingService.cs
│   │   ├── ElevatorCardService.cs
│   │   ├── ElevatorDeviceService.cs
│   │   └── ElevatorParamService.cs
│   ├── Invoice/
│   │   ├── InvoiceService.cs
│   │   ├── ReceiptService.cs
│   │   └── FeeServiceService.cs
│   ├── Notify/
│   │   ├── NotifyService.cs
│   │   ├── NotificationService.cs
│   │   └── TaskService.cs
│   ├── Request/
│   │   ├── RequestService.cs
│   │   └── ServiceService.cs
│   ├── ServicePrice/
│   │   ├── ServicePriceCommonService.cs
│   │   ├── ServicePriceElectricService.cs
│   │   ├── ServicePriceWaterService.cs
│   │   ├── ServicePriceVehicleService.cs
│   │   └── ...
│   ├── App/                      # Mobile App Services
│   │   ├── AppApartmentService.cs
│   │   ├── AppCardService.cs
│   │   ├── AppElevatorService.cs
│   │   ├── AppHomeService.cs
│   │   ├── AppNotifyService.cs
│   │   ├── AppRequestService.cs
│   │   └── AppUserService.cs
│   ├── HelperService/
│   │   ├── ChatService.cs
│   │   ├── GoogleCloudService.cs
│   │   ├── MailgunSendService.cs
│   │   └── UserTokenService.cs
│   └── ...
└── UserMapperProfile.cs          # AutoMapper Profile
```

#### Nguyên Tắc Thiết Kế BLL:

- **Separation of Concerns**: Mỗi service chỉ xử lý một domain cụ thể
- **Dependency Injection**: Sử dụng DI container để quản lý dependencies
- **Interface-based**: Tất cả services đều có interface tương ứng
- **Business Validation**: Logic nghiệp vụ được đặt ở đây, không phải ở Controller hoặc DAL

---

### 3. **UNI.Resident.DAL** - Data Access Layer

Tầng truy cập dữ liệu, giao tiếp với database.

```
UNI.Resident.DAL/
├── Interfaces/                    # Repository Interfaces
│   ├── Advertisement/
│   ├── Apartment/
│   ├── Api/
│   ├── App/
│   ├── Card/
│   ├── CardVehicle/
│   ├── Elevator/
│   ├── Invoice/
│   ├── Notify/
│   ├── Request/
│   └── ServicePrice/
├── Repositories/                  # Repository Implementations
│   ├── Advertisement/
│   │   ├── AdvertisementRepository.cs
│   │   └── AdvertisementAnalyticsRepository.cs
│   ├── Apartment/
│   │   ├── ApartmentRepository.cs
│   │   ├── FamilyMemberRepository.cs
│   │   ├── HouseholdRepository.cs
│   │   └── ProjectRepository.cs
│   ├── Card/
│   │   ├── CardRepository.cs
│   │   ├── CardBaseRepository.cs
│   │   ├── CardDailyRepository.cs
│   │   ├── CardGuestRepository.cs
│   │   ├── CardInternalRepository.cs
│   │   ├── CardResidentRepository.cs
│   │   └── VehicleCardRepository.cs
│   ├── CardVehicle/
│   │   ├── VehicleRepository.cs
│   │   ├── VehicleGuestRepository.cs
│   │   ├── VehicleInternalRepository.cs
│   │   ├── VehicleResidentRepository.cs
│   │   └── VehiclePaymentRepository.cs
│   ├── Elevator/
│   │   ├── ElevatorRepository.cs
│   │   ├── ElevatorBuildingRepository.cs
│   │   ├── ElevatorCardRepository.cs
│   │   ├── ElevatorDeviceRepository.cs
│   │   └── ElevatorParamRepository.cs
│   ├── Invoice/
│   │   ├── InvoiceRepository.cs
│   │   ├── ReceiptRepository.cs
│   │   └── FeeServiceRepository.cs
│   ├── Notify/
│   │   ├── NotifyRepository.cs
│   │   ├── NotificationRepository.cs
│   │   └── TaskRepository.cs
│   ├── Request/
│   │   ├── RequestRepository.cs
│   │   └── ServiceRepository.cs
│   ├── ServicePrice/
│   │   ├── ServicePriceCommonRepository.cs
│   │   ├── ServicePriceElectricRepository.cs
│   │   ├── ServicePriceWaterRepository.cs
│   │   └── ...
│   ├── App/                      # Mobile App Repositories
│   ├── Api/                      # External API Repositories
│   ├── Commons/
│   │   └── ResidentCommonBaseRepository.cs
│   └── ...
└── Commons/                       # Common Repository Base
```

#### Repository Pattern:

- **Base Repository**: `ResidentCommonBaseRepository` kế thừa từ `UniBaseRepository`
- **Stored Procedures**: Sử dụng stored procedures cho các thao tác phức tạp
- **Dapper**: Sử dụng Dapper cho data access (không dùng EF Core)
- **Connection Management**: Quản lý connection string từ configuration

---

### 4. **UNI.Resident.Model** - Data Models

Các model, DTOs, và view models.

```
UNI.Resident.Model/
├── Advertisement/
│   ├── Advertisement.cs
│   ├── AdvertisementDto.cs
│   ├── AdvertisementFilter.cs
│   └── AdvertisementInfo.cs
├── Apartment/
│   ├── ApartmentImportSet.cs
│   └── ApartmentOwner.cs
├── Card/
│   ├── CardClassificationInfo.cs
│   ├── CardGuestFilter.cs
│   ├── CardImportSet.cs
│   ├── CardStatus.cs
│   └── VehicleCardFilter.cs
├── Common/
│   ├── CommonPage.cs
│   ├── CommonViewInfo.cs
│   ├── FilterInput.cs
│   ├── GridFilterBase.cs
│   └── GridProjectFilter.cs
├── Elevator/
│   ├── ElevatorCardInfo.cs
│   └── ElevatorDeviceImportSet.cs
├── Invoice/
│   ├── InvoiceModel.cs
│   └── appPaymentInfo.cs
├── Notification/
│   ├── Notification.cs
│   ├── NotifyInfo.cs
│   └── NotifyPage.cs
├── Receipt/
│   ├── ReceiptInfo.cs
│   ├── ReceiptPage.cs
│   └── ReceiptRequestModel.cs
├── Request/
│   ├── RequestAssign.cs
│   ├── RequestAttach.cs
│   └── RequestProcess.cs
├── Resident/
│   ├── Apartment.cs
│   ├── Card.cs
│   ├── Project.cs
│   ├── Request.cs
│   ├── User.cs
│   └── Vehicle.cs
├── ServicePrice/
│   ├── ServicePriceElectricDetail.cs
│   ├── ServicePriceWaterDetail.cs
│   └── ...
├── SHome/                        # Database Models (60 files)
└── TableTypes.cs                 # Table-Valued Parameters
```

#### Model Types:

- **Entity Models**: Map trực tiếp với database tables
- **DTOs (Data Transfer Objects)**: Chuyển dữ liệu giữa các layers
- **View Models**: Dữ liệu cho views/UI
- **Filter Models**: Cho các query/search operations
- **Import Models**: Cho import data từ Excel

---

### 5. **UNI.SUPAPP.API** - Super App API

Dự án API phụ cho Super App (một phần của hệ thống).

```
UNI.SUPAPP.API/
├── Controllers/
├── Extensions/
├── Program.cs
├── Startup.cs
└── appsettings.json
```

---

### 6. **dbSHome** - Database Project

SQL Server Database Project chứa schema, stored procedures, functions.

```
dbSHome/
├── dbo/
│   ├── Functions/                # 77 SQL Functions
│   ├── Sequences/                # 1 Sequence
│   ├── Stored Procedures/        # 587 Stored Procedures
│   ├── Tables/                   # 193 Tables
│   └── User Defined Types/       # 21 User Defined Types
├── FullTextIndexes.sql
├── Phase1_Index_Optimization.sql
├── Phase1_Index_Rollback.sql
└── Storage/
```

**Xem chi tiết**: `Docs/DATABASE_STRUCTURE.md`

---

### 7. **uni-common/** - Shared Libraries

Thư viện tiện ích dùng chung cho nhiều dự án.

```
uni-common/
├── UNI.Common/                    # Core utilities
│   ├── CommonBase/               # Base repository & service
│   ├── Middleware/               # Custom middleware
│   ├── HelperService/            # Helper services
│   └── ...
├── UNI.Model/                     # Shared models
├── UNI.Utils/                     # General utilities
├── UNI.Document/                  # Document processing (Word, PDF)
├── UNI.Utilities.Email/           # Email service
├── UNI.Utilities.Encryption.AES/  # AES encryption
├── UNI.Utilities.ExternalStorage/ # External storage (MinIO, Firebase)
├── UNI.Utilities.Flexcel/         # Excel processing
├── UNI.Utilities.HttpClientExtension/  # HTTP client extensions
├── UNI.Utilities.JsonExtension/   # JSON extensions
├── UNI.Utilities.Keycloak/        # Keycloak integration
├── UNI.Utilities.MinIo/           # MinIO storage
├── UNI.Utilities.QrPay/           # QR Payment
├── UNI.Utilities.Rocketchat/      # RocketChat integration
├── UNI.Utilities.StringExtension/ # String extensions
└── itextsharp-netcore/            # PDF processing library
```

---

## 🔗 DEPENDENCY INJECTION

### Service Registration

Tất cả services được đăng ký trong `Extensions/ServiceCollectionExtensions.cs`:

```csharp
services.RegisterServices(Configuration);
```

#### Registration Pattern:

1. **Repository Registration**:
```csharp
services.AddScoped<IApartmentRepository, ApartmentRepository>();
services.AddScoped<ICardRepository, CardRepository>();
// ...
```

2. **Service Registration**:
```csharp
services.AddScoped<IApartmentService, ApartmentService>();
services.AddScoped<ICardService, CardService>();
// ...
```

3. **Base Repository Registration**:
```csharp
services.AddScopedUniBaseService(
    ServiceLifetime.Scoped, 
    "SHomeConnection", 
    "sp_common_filter"
);
```

4. **Storage Service**:
```csharp
// MinIO hoặc Firebase Storage
services.AddSingleton<IApiStorageService, ApiMinIoStorageService>();
```

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### JWT Bearer Authentication

- **Provider**: Keycloak
- **Token Validation**: JWT Bearer tokens
- **Realm Roles**: Được map thành .NET Claims
- **Configuration**: Trong `Startup.cs`

```csharp
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => {
        options.Authority = Configuration["Jwt:Authority"];
        // ...
    });
```

### Swagger OAuth2

- **Flow**: Implicit flow
- **Authorization URL**: Keycloak authorization endpoint
- **Token URL**: Keycloak token endpoint

---

## 📊 LOGGING & MONITORING

### Serilog

- **Provider**: Serilog với Elastic APM
- **Log Levels**: Debug, Information, Warning, Error
- **Output**: File logs và Elasticsearch
- **Configuration**: `appsettings.json`

### Elastic APM

- **Integration**: Elastic APM cho application performance monitoring
- **SQL Monitoring**: Tích hợp SQL Client diagnostics
- **HTTP Monitoring**: HTTP request diagnostics

---

## 🛠️ CÔNG NGHỆ & THƯ VIỆN

### Core Technologies

- **.NET 8.0**: Runtime framework
- **ASP.NET Core Web API**: Web framework
- **C#**: Programming language
- **SQL Server**: Database

### Key NuGet Packages

#### API Layer:
- `AutoMapper` (12.0.1) - Object mapping
- `NSwag.AspNetCore` (14.0.0) - Swagger/OpenAPI
- `Serilog.AspNetCore` (8.0.0) - Logging
- `Elastic.Apm.AspNetCore` (1.25.3) - APM
- `Microsoft.AspNetCore.Mvc.NewtonsoftJson` (6.0.26) - JSON serialization
- `Newtonsoft.Json` (13.0.3) - JSON processing

#### Business Logic Layer:
- `AutoMapper` (9.0.0) - Object mapping
- `Minio` (5.0.0) - MinIO client
- `MailKit` (2.15.0) - Email sending

#### Data Access Layer:
- `Dapper` - Micro ORM
- `Microsoft.Data.SqlClient` - SQL Server client
- `Keycloak.Net.Core.v19` (1.0.2) - Keycloak integration

#### Common Libraries:
- `TMS.FlexCel` (7.6.2) - Excel processing
- `iTextSharp` - PDF processing

---

## 📝 CONFIGURATION

### Configuration Files

1. **appsettings.json**: Base configuration
2. **appsettings.development.json**: Development environment
3. **appsettings.production.json**: Production environment

### Configuration Sections

```json
{
  "ConnectionStrings": {
    "AppManagerConnection": "...",
    "IdentityUserConnection": "...",
    "SHomeConnection": "..."  // Main database
  },
  "Jwt": {
    "Authority": "https://api.sunshinegroup.vn:5000",
    "ClientId": "..."
  },
  "AppSettings": {
    "ProjectId": "sunshine-app-production",
    "BaseUrls": {
      "Auth": "https://api.sunshinegroup.vn:5000"
    }
  },
  "StorageService": {
    "Provider": "MinIo",
    "MinIo": {
      "AccessKey": "...",
      "SecretKey": "...",
      "Endpoint": "...",
      "BucketName": "..."
    }
  }
}
```

---

## 🚀 DEPLOYMENT

### Build Commands

```bash
# Build solution
dotnet build UNI.RESIDENT.API.sln

# Run API
dotnet run --project UNI.RESIDENT.API

# Run with environment
dotnet run --project UNI.RESIDENT.API --environment Development
```

### Endpoints

- **API**: http://localhost:5000 (HTTP) / https://localhost:5001 (HTTPS)
- **IIS Express**: http://localhost:3090
- **Swagger UI**: Available at `/swagger` when running

---

## 📚 TÀI LIỆU LIÊN QUAN

- **01. Database Structure**: Chi tiết về cấu trúc database (DATABASE_STRUCTURE.md)
- **02. API Endpoints**: Tài liệu về các API endpoints
- **03. Authentication**: Hướng dẫn authentication & authorization
- **04. Business Logic**: Tài liệu về business logic layer
- **05. Data Access**: Tài liệu về data access patterns

---

## 🎯 TÓM TẮT

### Kiến Trúc
- ✅ **3-Layer Architecture**: Separation of concerns rõ ràng
- ✅ **Repository Pattern**: Abstraction cho data access
- ✅ **Dependency Injection**: Loose coupling giữa các components
- ✅ **Interface-based Design**: Dễ dàng test và maintain

### Tính Năng Chính
- ✅ Quản lý căn hộ, khách hàng, thẻ
- ✅ Quản lý gửi xe (thẻ xe)
- ✅ Quản lý dịch vụ và phí dịch vụ
- ✅ Yêu cầu và phản ánh
- ✅ Thông báo (push, SMS, Email)
- ✅ Thang máy
- ✅ Báo cáo và phân tích
- ✅ Quản lý bảng giá
- ✅ Ví điện tử và điểm thưởng

### Best Practices
- ✅ **SOLID Principles**: Tuân thủ các nguyên tắc SOLID
- ✅ **Naming Conventions**: Nhất quán trong naming
- ✅ **Code Organization**: Tổ chức code theo domain/module
- ✅ **Documentation**: XML comments và Swagger documentation
- ✅ **Error Handling**: Centralized error handling middleware
- ✅ **Logging**: Comprehensive logging với Serilog
- ✅ **Security**: JWT authentication, CORS configuration

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0



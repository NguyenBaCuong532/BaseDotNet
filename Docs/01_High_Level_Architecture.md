# 01. High-Level Architecture

## 📋 TỔNG QUAN

Tài liệu này mô tả kiến trúc tổng thể (High-Level Architecture) của hệ thống **UNI Resident API**, bao gồm các thành phần chính, luồng dữ liệu, design patterns và các quyết định kiến trúc quan trọng.

---

## 🏗️ KIẾN TRÚC TỔNG THỂ

### Architecture Overview

Hệ thống được xây dựng theo mô hình **3-Layer Architecture** kết hợp với **Clean Architecture** principles:

```
┌──────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Web Client   │  │  Mobile App   │  │  Admin CMS   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼─────────────────┼──────────────────┼──────────────────┘
          │                 │                  │
          └─────────────────┼──────────────────┘
                            │
          ┌─────────────────▼──────────────────┐
          │      API GATEWAY / LOAD BALANCER    │
          └─────────────────┬──────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────┐
│                    PRESENTATION LAYER                            │
│                  UNI.RESIDENT.API                                │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              HTTP Request Pipeline                      │    │
│  │  1. Elastic APM                                        │    │
│  │  2. HTTPS Redirection                                  │    │
│  │  3. Static Files                                       │    │
│  │  4. Routing                                            │    │
│  │  5. OpenAPI/Swagger                                    │    │
│  │  6. CORS                                               │    │
│  │  7. Authentication (JWT Bearer)                       │    │
│  │  8. Authorization                                      │    │
│  │  9. Session                                            │    │
│  │  10. Error Handling Middleware                         │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              Controllers (Version2)                    │    │
│  │  • ApartmentController                                 │    │
│  │  • CardController                                      │    │
│  │  • CardVehicleController                               │    │
│  │  • RequestController                                   │    │
│  │  • NotifyController                                   │    │
│  │  • ...                                                 │    │
│  └────────────────────┬──────────────────────────────────┘    │
└───────────────────────┼──────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                            │
│                  UNI.Resident.BLL                                 │
│  ┌────────────────────────────────────────────────────────┐      │
│  │              Business Services                          │      │
│  │  • Validation Logic                                     │      │
│  │  • Business Rules                                       │      │
│  │  • Domain Logic                                        │      │
│  │  • Data Transformation (AutoMapper)                    │      │
│  └────────────────────┬──────────────────────────────────┘      │
└───────────────────────┼──────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│                   DATA ACCESS LAYER                               │
│                  UNI.Resident.DAL                                 │
│  ┌────────────────────────────────────────────────────────┐      │
│  │              Repositories (Repository Pattern)          │      │
│  │  • UniBaseRepository (Base Class)                       │      │
│  │  • Dapper ORM                                           │      │
│  │  • Stored Procedures                                     │      │
│  │  • Connection Management                                │      │
│  └────────────────────┬──────────────────────────────────┘      │
└───────────────────────┼──────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│                       DATA LAYER                                   │
│                  UNI.Resident.Model                               │
│  • Entity Models                                                  │
│  • DTOs                                                          │
│  • View Models                                                   │
└───────────────────────┬──────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│                       DATABASE                                     │
│                     SQL Server (dbSHome)                           │
│  • 193 Tables                                                     │
│  • 587 Stored Procedures                                          │
│  • 77 Functions                                                   │
│  • 21 User Defined Types                                          │
└───────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                              │
│  • Keycloak (Authentication)                                     │
│  • MinIO / Firebase Storage                                       │
│  • Elastic APM (Monitoring)                                       │
│  • Serilog (Logging)                                             │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 LUỒNG XỬ LÝ REQUEST

### Request Flow Diagram

```
Client Request
    │
    ▼
┌─────────────────────────────────────┐
│  1. API Gateway / Load Balancer    │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  2. HTTP Request Pipeline           │
│     • Elastic APM Tracking         │
│     • HTTPS Redirection             │
│     • Static Files Serving         │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  3. Routing                         │
│     • Route Matching                │
│     • Controller Selection          │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  4. Authentication Middleware       │
│     • JWT Token Validation         │
│     • Keycloak Integration         │
│     • Claims Mapping               │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  5. Authorization                  │
│     • Policy Evaluation             │
│     • Role-Based Access Control    │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  6. Controller Action              │
│     • Parameter Binding            │
│     • Model Validation             │
│     • Filter Execution              │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  7. Business Service Layer         │
│     • Business Logic                │
│     • Validation                    │
│     • Data Transformation           │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  8. Repository Layer               │
│     • Database Connection           │
│     • Stored Procedure Execution   │
│     • Data Mapping                  │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  9. SQL Server Database            │
│     • Query Execution               │
│     • Result Set Return             │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  10. Response Pipeline             │
│      • Error Handling              │
│      • Response Formatting          │
│      • Logging                     │
└────────────┬────────────────────────┘
             │
             ▼
       Client Response
```

---

## 🎯 DESIGN PATTERNS

### 1. Repository Pattern

**Mục đích**: Tách biệt business logic khỏi data access logic

**Implementation**:
```csharp
// Interface
public interface IApartmentRepository
{
    Task<Apartment> GetByIdAsync(int id);
    Task<IEnumerable<Apartment>> GetAllAsync();
}

// Implementation
public class ApartmentRepository : UniBaseRepository, IApartmentRepository
{
    public ApartmentRepository(IUniCommonBaseRepository common) : base(common)
    {
    }

    public async Task<Apartment> GetByIdAsync(int id)
    {
        return await GetFieldAsync<Apartment>(
            "sp_res_apartment_get", 
            param => param.Add("@ApartmentId", id)
        );
    }
}
```

**Lợi ích**:
- Dễ dàng test bằng mock repositories
- Tách biệt data access logic
- Dễ dàng thay đổi data source

---

### 2. Dependency Injection Pattern

**Mục đích**: Giảm coupling giữa các components

**Implementation**:
```csharp
// Service Registration
services.AddScoped<IApartmentRepository, ApartmentRepository>();
services.AddScoped<IApartmentService, ApartmentService>();

// Usage in Controller
public class ApartmentController : ControllerBase
{
    private readonly IApartmentService _apartmentService;
    
    public ApartmentController(IApartmentService apartmentService)
    {
        _apartmentService = apartmentService;
    }
}
```

**Lợi ích**:
- Loose coupling
- Dễ dàng test
- Single Responsibility Principle

---

### 3. Service Layer Pattern

**Mục đích**: Tách biệt business logic khỏi presentation layer

**Implementation**:
```csharp
public interface IApartmentService
{
    Task<ApartmentDto> GetApartmentAsync(int id);
    Task<ApartmentDto> CreateApartmentAsync(CreateApartmentRequest request);
}

public class ApartmentService : UniBaseService, IApartmentService
{
    private readonly IApartmentRepository _repository;
    private readonly IMapper _mapper;
    
    public ApartmentService(
        IApartmentRepository repository,
        IMapper mapper) : base(repository)
    {
        _repository = repository;
        _mapper = mapper;
    }
    
    public async Task<ApartmentDto> GetApartmentAsync(int id)
    {
        // Business validation
        if (id <= 0)
            throw new ArgumentException("Invalid apartment ID");
        
        // Data access
        var apartment = await _repository.GetByIdAsync(id);
        
        // Transformation
        return _mapper.Map<ApartmentDto>(apartment);
    }
}
```

**Lợi ích**:
- Tập trung business logic
- Reusability
- Transaction management

---

### 4. Base Repository Pattern

**Mục đích**: Giảm code duplication và chuẩn hóa data access

**Implementation**:
```csharp
public abstract class UniBaseRepository : IUniBaseRepository
{
    protected readonly IUniCommonBaseRepository CommonBase;
    public CommonInfo CommonInfo => CommonBase.CommonInfo;
    
    // Common methods
    protected async Task<T> GetFieldAsync<T>(
        string storedProcedure,
        ParametersHandler parametersHandler)
    {
        // Implementation
    }
    
    protected async Task<CommonDataPage> GetPageAsync(
        string storedProcedure,
        FilterInput filter,
        ParametersHandler parametersHandler)
    {
        // Implementation
    }
}
```

**Lợi ích**:
- Code reuse
- Consistent data access pattern
- Centralized connection management

---

### 5. Middleware Pattern

**Mục đích**: Xử lý cross-cutting concerns

**Implementation**:
```csharp
// Error Handler Middleware
public class ErrorHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ErrorHandlerMiddleware> _logger;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Exception occurred");
            // Handle error and return formatted response
        }
    }
}
```

**Lợi ích**:
- Separation of concerns
- Centralized error handling
- Reusable across requests

---

### 6. DTO Pattern (Data Transfer Object)

**Mục đích**: Transfer data giữa các layers

**Implementation**:
```csharp
// Entity (Database Model)
public class Apartment
{
    public int ApartmentId { get; set; }
    public string RoomCode { get; set; }
    // ... database fields
}

// DTO (Data Transfer Object)
public class ApartmentDto
{
    public int Id { get; set; }
    public string RoomCode { get; set; }
    // ... presentation fields
}

// Mapping with AutoMapper
CreateMap<Apartment, ApartmentDto>();
```

**Lợi ích**:
- Decouple presentation from data layer
- Version API independently
- Optimize data transfer

---

## 🔐 SECURITY ARCHITECTURE

### Authentication Flow

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ 1. Request với JWT Token
       ▼
┌─────────────────────────────────────┐
│   API Gateway / Load Balancer       │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│   JWT Bearer Authentication          │
│   • Token Extraction                 │
│   • Token Validation                 │
│   • Claims Extraction                │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│   Keycloak Integration               │
│   • Token Validation                │
│   • Realm Roles Mapping              │
│   • User Context                     │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│   Authorization                     │
│   • Policy Evaluation               │
│   • Role-Based Access               │
│   • Permission Check                │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────┐
│  Controller │
└─────────────┘
```

### Security Components

1. **JWT Bearer Authentication**
   - Token-based authentication
   - Stateless authentication
   - Integration với Keycloak

2. **Role-Based Access Control (RBAC)**
   - Realm roles từ Keycloak
   - Policy-based authorization
   - Claims-based permissions

3. **CORS Configuration**
   - Cross-Origin Resource Sharing
   - Allowed origins configuration
   - Security headers

4. **Session Management**
   - HTTP-only cookies
   - Secure cookies
   - Session timeout

5. **HTTPS Enforcement**
   - HTTPS redirection
   - Secure communication
   - SSL/TLS encryption

---

## 📊 REQUEST PIPELINE

### ASP.NET Core Middleware Pipeline

Thứ tự middleware trong `Startup.Configure()`:

```
1. Elastic APM
   ├─ Application Performance Monitoring
   ├─ SQL Client Diagnostics
   └─ HTTP Diagnostics

2. HTTPS Redirection
   └─ Redirect HTTP to HTTPS

3. Static Files
   └─ Serve static files

4. Routing
   └─ Route matching

5. OpenAPI / Swagger
   └─ API documentation

6. CORS
   └─ Cross-Origin Resource Sharing

7. Authentication
   └─ JWT Bearer token validation

8. Authorization
   └─ Policy evaluation

9. Session
   └─ Session management

10. Error Handling Middleware
    └─ Global exception handling

11. Endpoints
    └─ Controller actions
```

### Pipeline Flow

```
Request
  │
  ├─→ [Elastic APM] Track request
  │
  ├─→ [HTTPS Redirection] Redirect if HTTP
  │
  ├─→ [Static Files] Serve if static
  │
  ├─→ [Routing] Match route
  │
  ├─→ [Swagger] Serve API docs if needed
  │
  ├─→ [CORS] Add CORS headers
  │
  ├─→ [Authentication] Validate JWT token
  │     └─→ Keycloak validation
  │     └─→ Claims extraction
  │
  ├─→ [Authorization] Check permissions
  │
  ├─→ [Session] Load/save session
  │
  ├─→ [Error Handler] Catch exceptions
  │
  └─→ [Endpoints] Execute controller action
        │
        └─→ Business Service
              │
              └─→ Repository
                    │
                    └─→ Database
```

---

## 🔗 INTEGRATION POINTS

### External Services Integration

```
┌─────────────────────────────────────┐
│      UNI Resident API               │
└──────┬──────────────────────────────┘
       │
       ├─────────────────────────────────┐
       │                                 │
       ▼                                 ▼
┌──────────────┐                ┌──────────────┐
│  Keycloak    │                │  MinIO /     │
│  (Auth)      │                │  Firebase    │
│              │                │  (Storage)   │
└──────────────┘                └──────────────┘
       │                                 │
       ▼                                 ▼
┌──────────────┐                ┌──────────────┐
│  Elastic APM │                │  Serilog     │
│  (Monitoring)│                │  (Logging)   │
└──────────────┘                └──────────────┘
```

### Integration Details

1. **Keycloak Integration**
   - Authentication provider
   - Token validation
   - User management
   - Role management

2. **Storage Service (MinIO / Firebase)**
   - File upload/download
   - Object storage
   - CDN integration
   - Configurable provider

3. **Elastic APM**
   - Application performance monitoring
   - SQL query tracking
   - HTTP request tracking
   - Error tracking

4. **Serilog**
   - Structured logging
   - File logging
   - Elasticsearch integration
   - Log levels configuration

---

## 🚀 SCALABILITY & PERFORMANCE

### Scalability Considerations

1. **Horizontal Scaling**
   - Stateless API design
   - Session stored in database
   - Load balancer support

2. **Database Scaling**
   - Stored procedures for complex queries
   - Indexed tables
   - Connection pooling
   - Query optimization

3. **Caching Strategy**
   - Session caching
   - Configuration caching
   - Response caching (future)

4. **Async/Await Pattern**
   - Non-blocking I/O operations
   - Async repository methods
   - Async service methods

### Performance Optimizations

1. **Dapper ORM**
   - Lightweight ORM
   - Fast data access
   - Stored procedure support

2. **Connection Pooling**
   - SQL Server connection pooling
   - Efficient connection reuse

3. **Stored Procedures**
   - Pre-compiled queries
   - Reduced network traffic
   - Database-level optimization

4. **AutoMapper**
   - Efficient object mapping
   - Reduced boilerplate code

---

## 📐 DATA FLOW ARCHITECTURE

### Create Operation Flow

```
Client Request (POST /api/v2/apartment)
    │
    ▼
┌─────────────────────────────────────┐
│  ApartmentController.Create()       │
│  • Model Validation                 │
│  • Parameter Binding                │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  ApartmentService.CreateAsync()      │
│  • Business Validation               │
│  • Business Rules                    │
│  • Data Transformation               │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  ApartmentRepository.Create()       │
│  • Map to Entity                     │
│  • Prepare Parameters               │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Stored Procedure                    │
│  sp_res_apartment_create             │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  SQL Server Database                 │
│  • Insert Record                     │
│  • Return Result                      │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Response Transformation             │
│  • Entity → DTO                      │
│  • Format Response                    │
└────────────┬────────────────────────┘
             │
             ▼
      Client Response (JSON)
```

### Read Operation Flow

```
Client Request (GET /api/v2/apartment/{id})
    │
    ▼
┌─────────────────────────────────────┐
│  ApartmentController.Get()          │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  ApartmentService.GetAsync()         │
│  • Authorization Check               │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  ApartmentRepository.GetById()      │
│  • Execute Stored Procedure          │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Stored Procedure                    │
│  sp_res_apartment_get                │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  SQL Server Database                 │
│  • Query Execution                   │
│  • Return Data                        │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Response Transformation             │
│  • Entity → DTO                      │
└────────────┬────────────────────────┘
             │
             ▼
      Client Response (JSON)
```

---

## 🔧 CONFIGURATION ARCHITECTURE

### Configuration Hierarchy

```
1. appsettings.json (Base)
    │
    ├─→ appsettings.{Environment}.json
    │   ├─→ Development
    │   ├─→ Production
    │   └─→ Staging
    │
    └─→ Environment Variables
        └─→ Override configuration
```

### Configuration Sections

- **ConnectionStrings**: Database connections
- **Jwt**: JWT authentication settings
- **AppSettings**: Application settings
- **StorageService**: Storage provider configuration
- **Logging**: Serilog configuration
- **ElasticAPM**: APM configuration

---

## 📚 TÀI LIỆU LIÊN QUAN

- **00_Project_Structure.md**: Cấu trúc project chi tiết
- **DATABASE_STRUCTURE.md**: Cấu trúc database
- **02_API_Documentation.md**: Tài liệu API endpoints (sẽ tạo)
- **03_Authentication_Guide.md**: Hướng dẫn authentication (sẽ tạo)

---

## 🎯 TÓM TẮT

### Kiến Trúc Chính
- ✅ **3-Layer Architecture**: Separation of concerns rõ ràng
- ✅ **Repository Pattern**: Abstraction cho data access
- ✅ **Service Layer Pattern**: Business logic encapsulation
- ✅ **Dependency Injection**: Loose coupling
- ✅ **Middleware Pattern**: Cross-cutting concerns

### Security
- ✅ **JWT Authentication**: Token-based authentication
- ✅ **Keycloak Integration**: Identity management
- ✅ **RBAC**: Role-based access control
- ✅ **HTTPS**: Secure communication

### Performance
- ✅ **Async/Await**: Non-blocking I/O
- ✅ **Dapper ORM**: Lightweight data access
- ✅ **Stored Procedures**: Database optimization
- ✅ **Connection Pooling**: Efficient resource usage

### Monitoring & Logging
- ✅ **Elastic APM**: Application performance monitoring
- ✅ **Serilog**: Structured logging
- ✅ **Error Handling**: Centralized exception handling

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0



# 04. Data Flow Diagram

## 📋 TỔNG QUAN

Tài liệu này mô tả chi tiết các luồng dữ liệu (Data Flow) trong hệ thống **UNI Resident API**, bao gồm luồng từ client request đến database response, các luồng xử lý nghiệp vụ, và integration với external services.

---

## 🔄 LUỒNG DỮ LIỆU TỔNG QUAN

### Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT REQUEST                           │
│                    (HTTP Request with JWT Token)                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    HTTP REQUEST PIPELINE                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Request Validation (URL, Headers, Body)              │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  2. Authentication Middleware (JWT Token Validation)     │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  3. Authorization (Role/Permission Check)                │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  4. Routing (Controller Selection)                      │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CONTROLLER LAYER                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Parameter Binding (Query, Body, Route)               │  │
│  │  • Model Validation                                     │  │
│  │  • Context Extraction (UserId, ClientId)               │  │
│  │  • Error Handling (Try-Catch)                          │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                          │
│                      (Service Layer)                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Business Validation                                   │  │
│  │  • Business Rules                                        │  │
│  │  • Data Transformation (AutoMapper)                     │  │
│  │  • Cross-cutting Logic                                  │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                             │
│                    (Repository Layer)                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Parameter Preparation                                 │  │
│  │  • Stored Procedure Call                                 │  │
│  │  • Connection Management                                 │  │
│  │  • Result Mapping                                        │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATABASE LAYER                            │
│                      SQL Server (dbSHome)                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Stored Procedure Execution                            │  │
│  │  • Query Execution                                       │  │
│  │  • Data Retrieval                                        │  │
│  │  • Transaction Management                                │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        RESPONSE PIPELINE                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Data Transformation (Entity → DTO)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  2. Response Formatting (BaseResponse)                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  3. Logging (Serilog)                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  4. Error Handling (if any)                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT RESPONSE                          │
│                      (JSON Response)                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📥 CREATE OPERATION FLOW

### Create Apartment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  CLIENT                                                          │
│  POST /api/v2/apartment/SetApartmentAddInfo                     │
│  Body: { "RoomCode": "A101", "projectCd": "PROJ01", ... }      │
└────────────────────────┬─────────────────────────────────────────┘
                         │ HTTP Request + JWT Token
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller: ApartmentController                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [HttpPost]                                              │  │
│  │  SetApartmentAddInfo([FromBody] ApartmentInfo info)      │  │
│  │                                                           │  │
│  │  1. Extract UserId from JWT Claims                      │  │
│  │  2. Extract ClientId from Request Context               │  │
│  │  3. Validate Model (ModelState)                         │  │
│  │  4. Call Service: _apartmentService.SetApartmentAddInfo │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Service: ApartmentService                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SetApartmentAddInfo(ApartmentInfo info)                 │  │
│  │                                                           │  │
│  │  1. Business Validation:                                │  │
│  │     - Check RoomCode format                             │  │
│  │     - Check ProjectCd exists                            │  │
│  │     - Validate business rules                           │  │
│  │                                                           │  │
│  │  2. Data Transformation:                                │  │
│  │     - Map ApartmentInfo → Entity                        │  │
│  │     - Set audit fields (CreatedBy, CreatedDate)         │  │
│  │                                                           │  │
│  │  3. Call Repository:                                    │  │
│  │     _repository.SetApartmentAddInfo(info)               │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: ApartmentRepository                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SetApartmentAddInfo(ApartmentInfo info)                 │  │
│  │                                                           │  │
│  │  1. Prepare Parameters:                                 │  │
│  │     - Map info → DynamicParameters                      │  │
│  │     - Add userId, clientId                              │  │
│  │                                                           │  │
│  │  2. Execute Stored Procedure:                           │  │
│  │     await SetInfoAsync<BaseValidate>(                   │  │
│  │       "sp_res_apartment_add_set",                        │  │
│  │       info,                                              │  │
│  │       new { info.ApartmentId }                          │  │
│  │     )                                                    │  │
│  │                                                           │  │
│  │  3. Map Result: BaseValidate                            │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Database: SQL Server                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Stored Procedure: sp_res_apartment_add_set              │  │
│  │                                                           │  │
│  │  1. Validate Input Parameters                           │  │
│  │  2. Check Business Rules                                │  │
│  │  3. Insert into MAS_Apartments                          │  │
│  │  4. Create Related Records                              │  │
│  │  5. Return Result (valid, messages)                     │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Response Flow (Reverse)                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. BaseValidate → Service                              │  │
│  │  2. BaseValidate → Controller                            │  │
│  │  3. BaseResponse<string> → Client                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Create Flow - Detailed Steps

```
Step 1: Client Request
  │
  ├─→ HTTP POST Request
  ├─→ Headers: Authorization: Bearer <jwt_token>
  ├─→ Body: JSON (ApartmentInfo)
  └─→ Route: /api/v2/apartment/SetApartmentAddInfo

Step 2: Middleware Pipeline
  │
  ├─→ Elastic APM: Track request
  ├─→ HTTPS Redirection (if needed)
  ├─→ Static Files (skip)
  ├─→ Routing: Match route
  ├─→ CORS: Add headers
  ├─→ Authentication: Validate JWT
  │   ├─→ Extract token from header
  │   ├─→ Validate with Keycloak
  │   ├─→ Map realm roles to claims
  │   └─→ Set UserId, ClientId in context
  ├─→ Authorization: Check permissions
  ├─→ Session: Load session
  └─→ Error Handler: Ready to catch errors

Step 3: Controller
  │
  ├─→ Parameter Binding: [FromBody] ApartmentInfo
  ├─→ Model Validation: ModelState.IsValid
  ├─→ Extract Context:
  │   ├─→ UserId = Claims["sub"]
  │   └─→ ClientId = Headers["client-id"]
  ├─→ Call Service: _apartmentService.SetApartmentAddInfo(info)
  └─→ Format Response: BaseResponse<string>

Step 4: Service (Business Logic)
  │
  ├─→ Business Validation:
  │   ├─→ Check RoomCode uniqueness
  │   ├─→ Validate ProjectCd exists
  │   └─→ Check business rules
  ├─→ Data Transformation:
  │   ├─→ Set CreatedBy = UserId
  │   ├─→ Set CreatedDate = DateTime.Now
  │   └─→ Map DTO → Entity
  ├─→ Call Repository: _repository.SetApartmentAddInfo(info)
  └─→ Return BaseValidate

Step 5: Repository (Data Access)
  │
  ├─→ Prepare Parameters:
  │   ├─→ Create DynamicParameters
  │   ├─→ Add info properties
  │   ├─→ Add userId, clientId from CommonInfo
  │   └─→ Add @ApartmentId parameter
  ├─→ Execute Stored Procedure:
  │   ├─→ Connection: Get from CommonInfo.ConnectionString
  │   ├─→ Command: "sp_res_apartment_add_set"
  │   ├─→ CommandType: StoredProcedure
  │   └─→ Execute with Dapper
  └─→ Map Result: BaseValidate

Step 6: Database (Stored Procedure)
  │
  ├─→ sp_res_apartment_add_set
  ├─→ Input Parameters:
  │   ├─→ @ApartmentId, @RoomCode, @projectCd, ...
  │   ├─→ @userId, @clientId (from CommonInfo)
  │   └─→ @created_by, @created_dt
  ├─→ Business Logic:
  │   ├─→ Validate RoomCode uniqueness
  │   ├─→ Check projectCd exists
  │   └─→ Validate business rules
  ├─→ Data Operations:
  │   ├─→ INSERT INTO MAS_Apartments
  │   └─→ Create related records if needed
  └─→ Return Result:
      ├─→ valid (BIT)
      └─→ messages (NVARCHAR)

Step 7: Response Pipeline
  │
  ├─→ Repository → Service: BaseValidate
  ├─→ Service → Controller: BaseValidate
  ├─→ Controller Format:
  │   ├─→ BaseResponse<string>
  │   ├─→ status = rs.valid ? ApiResult.Success : ApiResult.Error
  │   └─→ message = rs.messages
  ├─→ Error Handler: Catch exceptions if any
  ├─→ Logging: Log with Serilog
  ├─→ Elastic APM: Track response
  └─→ HTTP Response: JSON to client
```

---

## 📖 READ OPERATION FLOW

### Get Apartment Page Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  CLIENT                                                          │
│  GET /api/v2/apartment/GetApartmentPage?projectCd=PROJ01&offSet=0&pageSize=10
└────────────────────────┬─────────────────────────────────────────┘
                         │ HTTP GET Request + JWT Token
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller: ApartmentController                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [HttpGet]                                               │  │
│  │  GetApartmentPage([FromQuery] ApartmentRequestModel1)    │  │
│  │                                                           │  │
│  │  1. Extract UserId, ClientId                            │  │
│  │  2. Set query.userId = UserId                           │  │
│  │  3. Set query.clientId = ClientId                       │  │
│  │  4. Call Service: _apartmentService.GetApartmentPage    │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Service: ApartmentService                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  GetApartmentPage(ApartmentRequestModel1 query)          │  │
│  │                                                           │  │
│  │  1. Business Validation:                                │  │
│  │     - Validate projectCd                                │  │
│  │     - Check user permissions                             │  │
│  │                                                           │  │
│  │  2. Call Repository:                                    │  │
│  │     return await _repository.GetApartmentPage(query)    │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: ApartmentRepository                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  GetApartmentPage(ApartmentRequestModel1 flt)             │  │
│  │                                                           │  │
│  │  1. Prepare Parameters:                                 │  │
│  │     - Map filter properties                             │  │
│  │     - Add pagination params (offSet, pageSize)          │  │
│  │                                                           │  │
│  │  2. Execute Stored Procedure:                           │  │
│  │     await GetDataListPageAsync(                          │  │
│  │       "sp_res_apartment_page",                           │  │
│  │       flt,                                               │  │
│  │       new { flt.ProjectCd, flt.Rent, ... }              │  │
│  │     )                                                    │  │
│  │                                                           │  │
│  │  3. Map Result: CommonDataPage                           │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Database: SQL Server                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Stored Procedure: sp_res_apartment_page                 │  │
│  │                                                           │  │
│  │  1. Input Parameters:                                   │  │
│  │     - @projectCd, @buildingCd, @filter                 │  │
│  │     - @offSet, @pageSize, @gridWidth                    │  │
│  │     - @userId, @clientId                                │  │
│  │                                                           │  │
│  │  2. Query Execution:                                    │  │
│  │     - Execute common filter (sp_common_filter)          │  │
│  │     - SELECT FROM MAS_Apartments with WHERE             │  │
│  │     - Apply pagination                                  │  │
│  │     - COUNT total records                               │  │
│  │                                                           │  │
│  │  3. Return Results:                                     │  │
│  │     - Result Set 1: Data (apartments list)              │  │
│  │     - Result Set 2: Total count                         │  │
│  │     - Result Set 3: Aggregates (if any)                │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Response Flow                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Multiple Result Sets → Dapper                       │  │
│  │  2. Map to CommonDataPage:                              │  │
│  │     - data: List<Apartment>                             │  │
│  │     - total: int                                        │  │
│  │     - offset: int                                       │  │
│  │     - pageSize: int                                     │  │
│  │  3. CommonDataPage → Service                            │  │
│  │  4. CommonDataPage → Controller                         │  │
│  │  5. BaseResponse<CommonDataPage> → Client               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Get Single Record Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  GET /api/v2/apartment/GetApartmentInfo?apartmentId=123         │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller → Service → Repository                               │
│                                                                   │
│  Repository.GetApartmentInfo(ApartmentId)                        │
│  └─→ GetFieldsAsync<ApartmentInfo>(                             │
│        "sp_res_apartment_field",                                │
│        new { ApartmentId }                                       │
│      )                                                           │
│                                                                   │
│  Database: sp_res_apartment_field                                │
│  └─→ SELECT * FROM MAS_Apartments WHERE ApartmentId = @id       │
│                                                                   │
│  Response: ApartmentInfo Entity                                  │
│  └─→ AutoMapper → ApartmentDto (if needed)                       │
│  └─→ BaseResponse<ApartmentInfo>                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 UPDATE OPERATION FLOW

### Update Apartment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  CLIENT                                                          │
│  POST /api/v2/apartment/SetApartmentInfo                        │
│  Body: { "ApartmentId": 123, "RoomCode": "A101", ... }         │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller → Service → Repository                               │
│                                                                   │
│  Service: SetApartmentInfo(viewBaseInfo info)                   │
│  └─→ Business Validation                                         │
│  └─→ Set UpdatedBy = UserId                                     │
│  └─→ Set UpdatedDate = DateTime.Now                             │
│                                                                   │
│  Repository: SetApartmentInfo(viewBaseInfo info)                │
│  └─→ GetFirstOrDefaultAsync<BaseValidate>(                     │
│        "sp_res_apartment_set",                                  │
│        new {                                                    │
│          ApartmentId = info.GetValueByFieldName("ApartmentId"), │
│          WaterwayArea = info.GetValueByFieldName("WaterwayArea") │
│        }                                                         │
│      )                                                           │
│                                                                   │
│  Database: sp_res_apartment_set                                 │
│  └─→ UPDATE MAS_Apartments                                       │
│  └─→ SET RoomCode = @RoomCode, ...                              │
│  └─→ WHERE ApartmentId = @ApartmentId                           │
│  └─→ Return BaseValidate                                        │
│                                                                   │
│  Response: BaseResponse<string>                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🗑️ DELETE OPERATION FLOW

### Delete Apartment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  CLIENT                                                          │
│  DELETE /api/v2/apartment/DeleteApartment?apartmentId=123        │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller → Service → Repository                               │
│                                                                   │
│  Service: DeleteApartmentAsync(int apartmentId)                 │
│  └─→ Business Validation:                                        │
│      - Check if apartment has related records                   │
│      - Check if can be deleted                                  │
│                                                                   │
│  Repository: DeleteApartmentAsync(int apartmentId)               │
│  └─→ DeleteAsync(                                               │
│        "sp_res_apartment_del",                                  │
│        new { apartmentId }                                      │
│      )                                                           │
│                                                                   │
│  Database: sp_res_apartment_del                                 │
│  └─→ Check constraints                                          │
│  └─→ Soft delete or hard delete (based on SP logic)             │
│  └─→ Return BaseValidate                                        │
│                                                                   │
│  Response: BaseResponse<string>                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 AUTHENTICATION DATA FLOW

### JWT Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  CLIENT                                                          │
│  Request with JWT Token in Header                                │
│  Authorization: Bearer <jwt_token>                              │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  JWT Bearer Authentication Middleware                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Extract Token from Header                           │  │
│  │  2. Validate Token with Keycloak:                        │  │
│  │     - Validate signature                                  │  │
│  │     - Validate audience (account)                         │  │
│  │     - Validate issuer (Authority)                         │  │
│  │     - Validate expiration                                 │  │
│  │                                                           │  │
│  │  3. OnTokenValidated Event:                               │  │
│  │     - Extract realm_access claim                         │  │
│  │     - Deserialize roles: {"roles": ["role1", "role2"]}  │  │
│  │     - Map to Claims:                                     │  │
│  │       claimsIdentity.AddClaim(                            │  │
│  │         new Claim(ClaimTypes.Role, role)                  │  │
│  │       )                                                   │  │
│  │     - Set UserId = Claims["sub"]                         │  │
│  │     - Set ClientId = Claims["client_id"]                  │  │
│  │                                                           │  │
│  │  4. Set HttpContext.User = ClaimsPrincipal               │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Authorization Middleware                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Check Policy Requirements                              │  │
│  │  • Evaluate Roles                                         │  │
│  │  • Check Permissions                                      │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller: Extract User Context                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • UserId = User.FindFirst(ClaimTypes.NameIdentifier)    │  │
│  │  • ClientId = Headers["client-id"]                        │  │
│  │  • Roles = User.Claims.Where(c => c.Type == ClaimTypes.Role)│ │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 DATA TRANSFORMATION FLOW

### AutoMapper Transformation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Entity (Database Model)                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  public class Apartment                                  │  │
│  │  {                                                       │  │
│  │      public int ApartmentId { get; set; }               │  │
│  │      public string RoomCode { get; set; }               │  │
│  │      public string projectCd { get; set; }              │  │
│  │      ...                                                 │  │
│  │  }                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │ AutoMapper.Map<ApartmentDto>()
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  DTO (Data Transfer Object)                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  public class ApartmentDto                               │  │
│  │  {                                                       │  │
│  │      public int Id { get; set; }                        │  │
│  │      public string RoomCode { get; set; }               │  │
│  │      public string ProjectCode { get; set; }            │  │
│  │      ...                                                 │  │
│  │  }                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  AutoMapper Profile Configuration                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CreateMap<Apartment, ApartmentDto>()                    │  │
│  │    .ForMember(dest => dest.Id, opt => opt.MapFrom(       │  │
│  │      src => src.ApartmentId))                            │  │
│  │    .ForMember(dest => dest.ProjectCode, opt => opt.MapFrom(│ │
│  │      src => src.projectCd))                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Transformation Points

1. **Repository → Service**: Entity → Entity (same type)
2. **Service → Controller**: Entity → DTO (AutoMapper)
3. **Controller → Client**: DTO → JSON (serialization)

---

## 💾 DATABASE INTERACTION FLOW

### Stored Procedure Call Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Repository Method                                               │
│  GetApartmentPage(ApartmentRequestModel1 flt)                   │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  UniBaseRepository.GetDataListPageAsync()                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Create DynamicParameters                            │  │
│  │     var param = new DynamicParameters();                │  │
│  │     param.Add("@projectCd", flt.ProjectCd);              │  │
│  │     param.Add("@offSet", flt.offSet);                   │  │
│  │     param.Add("@pageSize", flt.pageSize);               │  │
│  │     param.Add("@userId", CommonInfo.UserId);            │  │
│  │     param.Add("@clientId", CommonInfo.ClientId);         │  │
│  │                                                           │  │
│  │  2. Get Connection:                                      │  │
│  │     using var conn = new SqlConnection(                 │  │
│  │       CommonInfo.ConnectionString                        │  │
│  │     )                                                    │  │
│  │                                                           │  │
│  │  3. Execute Stored Procedure:                            │  │
│  │     var result = await conn.QueryMultipleAsync(          │  │
│  │       "sp_res_apartment_page",                           │  │
│  │       param,                                             │  │
│  │       commandType: CommandType.StoredProcedure          │  │
│  │     )                                                    │  │
│  │                                                           │  │
│  │  4. Read Multiple Result Sets:                           │  │
│  │     var data = result.Read<Apartment>().ToList();        │  │
│  │     var total = result.ReadFirst<int>();                 │  │
│  │                                                           │  │
│  │  5. Create CommonDataPage:                               │  │
│  │     return new CommonDataPage {                          │  │
│  │       data = data,                                        │  │
│  │       total = total,                                      │  │
│  │       offset = flt.offSet,                               │  │
│  │       pageSize = flt.pageSize                            │  │
│  │     }                                                    │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  SQL Server Connection Pool                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Get connection from pool                              │  │
│  │  • Execute stored procedure                               │  │
│  │  • Return connection to pool                             │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Database: dbSHome                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  EXEC sp_res_apartment_page                              │  │
│  │    @projectCd = 'PROJ01',                                │  │
│  │    @offSet = 0,                                          │  │
│  │    @pageSize = 10,                                       │  │
│  │    @userId = 'user123',                                  │  │
│  │    @clientId = 'client456'                                │  │
│  │                                                           │  │
│  │  -- Execute common filter                                │  │
│  │  EXEC sp_common_filter @userId, @clientId                │  │
│  │                                                           │  │
│  │  -- Query data                                           │  │
│  │  SELECT * FROM MAS_Apartments                            │  │
│  │  WHERE projectCd = @projectCd                             │  │
│  │  ORDER BY RoomCode                                       │  │
│  │  OFFSET @offSet ROWS                                     │  │
│  │  FETCH NEXT @pageSize ROWS ONLY                          │  │
│  │                                                           │  │
│  │  -- Return total count                                   │  │
│  │  SELECT COUNT(*) FROM MAS_Apartments                     │  │
│  │  WHERE projectCd = @projectCd                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔗 INTEGRATION DATA FLOW

### External Service Integration Flow

#### MinIO Storage Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Controller: StorageController                                    │
│  POST /api/v2/storage/Upload                                     │
│  FormData: file                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Service: StorageService                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  UploadFile(IFormFile file)                               │  │
│  │                                                           │  │
│  │  1. Validate file                                        │  │
│  │  2. Get Storage Service:                                  │  │
│  │     _storageService = IApiStorageService                  │  │
│  │     (MinIO or Firebase based on config)                   │  │
│  │                                                           │  │
│  │  3. Upload to Storage:                                   │  │
│  │     await _storageService.UploadAsync(file)              │  │
│  │                                                           │  │
│  │  4. Return file URL                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Storage Service: ApiMinIoStorageService                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Connect to MinIO:                                     │  │
│  │     var client = new MinioClient()                       │  │
│  │       .WithEndpoint(config.Endpoint)                     │  │
│  │       .WithCredentials(config.AccessKey, config.SecretKey)│ │
│  │                                                           │  │
│  │  2. Upload File:                                          │  │
│  │     await client.PutObjectAsync(                          │  │
│  │       config.BucketName,                                  │  │
│  │       objectName,                                         │  │
│  │       fileStream,                                        │  │
│  │       fileSize                                           │  │
│  │     )                                                    │  │
│  │                                                           │  │
│  │  3. Generate URL:                                        │  │
│  │     return config.ProxyEndpoint + "/" + objectName       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  MinIO Server                                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Receive file                                          │  │
│  │  • Store in bucket                                       │  │
│  │  • Return success                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

#### Keycloak Integration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  JWT Token Validation                                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Extract token from Authorization header              │  │
│  │                                                           │  │
│  │  2. Validate with Keycloak:                              │  │
│  │     GET /protocol/openid-connect/certs                    │  │
│  │     (Get public keys for signature validation)           │  │
│  │                                                           │  │
│  │  3. Validate Token:                                       │  │
│  │     - Signature validation                                │  │
│  │     - Audience validation                                │  │
│  │     - Issuer validation                                  │  │
│  │     - Expiration validation                              │  │
│  │                                                           │  │
│  │  4. Extract Claims:                                      │  │
│  │     - sub (UserId)                                       │  │
│  │     - realm_access.roles                                 │  │
│  │     - client_id                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 ERROR HANDLING FLOW

### Error Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  Exception Occurs                                                │
│  (Any Layer: Controller, Service, Repository, Database)          │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Error Handler Middleware                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  try                                                      │  │
│  │  {                                                       │  │
│  │      await _next(context);                             │  │
│  │  }                                                       │  │
│  │  catch (Exception exception)                            │  │
│  │  {                                                       │  │
│  │      // Log error with Serilog                         │  │
│  │      _logger.LogError(exception, exception.Message);    │  │
│  │                                                           │  │
│  │      // Capture in Elastic APM                          │  │
│  │      Agent.Tracer.CaptureException(exception);           │  │
│  │                                                           │  │
│  │      // Create error response                           │  │
│  │      var result = new ApiResponse<bool> {                │  │
│  │          StatusCode = HttpStatusCode.InternalServerError,│  │
│  │          Message = exception.Message,                    │  │
│  │          Status = Constants.Statusfail                   │  │
│  │      };                                                  │  │
│  │                                                           │  │
│  │      // Handle specific exception types                 │  │
│  │      switch (exception)                                  │  │
│  │      {                                                   │  │
│  │          case BusinessException ex:                    │  │
│  │              result.StatusCode = ex.ErrorCode;          │  │
│  │              result.Message = ex.ErrorMessage;           │  │
│  │              break;                                      │  │
│  │          case ReportException ex:                       │  │
│  │              result.StatusCode = ex.StatusCode;          │  │
│  │              result.Message = ex.Message;                │  │
│  │              break;                                      │  │
│  │      }                                                   │  │
│  │                                                           │  │
│  │      // Serialize and return                            │  │
│  │      var json = JsonConvert.SerializeObject(result);     │  │
│  │      await response.WriteAsync(json);                   │  │
│  │  }                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Error Response to Client                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  {                                                       │  │
│  │    "status": 0,                                          │  │
│  │    "statusCode": 500,                                    │  │
│  │    "message": "Error message",                           │  │
│  │    "data": null                                          │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 PAGINATION DATA FLOW

### Pagination Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Client Request                                                   │
│  GET /api/v2/apartment/GetApartmentPage?offSet=0&pageSize=10    │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller                                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ApartmentRequestModel1 query                            │  │
│  │  {                                                       │  │
│  │    offSet: 0,                                            │  │
│  │    pageSize: 10,                                         │  │
│  │    filter: "...",                                        │  │
│  │    gridWidth: 0                                          │  │
│  │  }                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: GetDataListPageAsync()                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Stored Procedure: sp_res_apartment_page                │  │
│  │                                                           │  │
│  │  Parameters:                                             │  │
│  │  - @offSet = 0                                           │  │
│  │  - @pageSize = 10                                        │  │
│  │  - @filter = "..."                                       │  │
│  │  - @gridWidth = 0                                        │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Database: Stored Procedure                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  -- Get total count                                       │  │
│  │  SELECT COUNT(*) AS Total                                 │  │
│  │  FROM MAS_Apartments                                      │  │
│  │  WHERE ...                                                │  │
│  │                                                           │  │
│  │  -- Get paged data                                        │  │
│  │  SELECT *                                                 │  │
│  │  FROM MAS_Apartments                                      │  │
│  │  WHERE ...                                                │  │
│  │  ORDER BY RoomCode                                        │  │
│  │  OFFSET @offSet ROWS                                      │  │
│  │  FETCH NEXT @pageSize ROWS ONLY                           │  │
│  │                                                           │  │
│  │  -- Return aggregates (optional)                           │  │
│  │  SELECT SUM(CurrBal) AS TotalBalance                      │  │
│  │  FROM MAS_Apartments                                      │  │
│  │  WHERE ...                                                │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: Map Results                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  using var result = await conn.QueryMultipleAsync(...);   │  │
│  │                                                           │  │
│  │  var data = result.Read<Apartment>().ToList();           │  │
│  │  var total = result.ReadFirst<int>();                    │  │
│  │  var aggregates = result.ReadFirst<Aggregates>();         │  │
│  │                                                           │  │
│  │  return new CommonDataPage {                              │  │
│  │    data = data,                                           │  │
│  │    total = total,                                         │  │
│  │    offset = query.offSet,                                 │  │
│  │    pageSize = query.pageSize                             │  │
│  │  };                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Response to Client                                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  {                                                       │  │
│  │    "status": 1,                                          │  │
│  │    "statusCode": 200,                                    │  │
│  │    "data": {                                             │  │
│  │      "data": [ /* apartments */ ],                       │  │
│  │      "total": 100,                                       │  │
│  │      "offset": 0,                                        │  │
│  │      "pageSize": 10                                      │  │
│  │    }                                                     │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 IMPORT DATA FLOW

### Excel Import Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Client: Upload Excel File                                       │
│  POST /api/v2/apartment/ApartmentImport                          │
│  FormData: file (Excel .xlsx)                                    │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Controller: ApartmentController                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Validate file:                                        │  │
│  │     - Check file exists                                   │  │
│  │     - Check extension (.xlsx)                            │  │
│  │                                                           │  │
│  │  2. Read Excel with FlexCel:                            │  │
│  │     var cards = FlexcellUtils.ReadToObject<              │  │
│  │       ApartmentImportItem                                 │  │
│  │     >(fs.ToArray(), 5);                                   │  │
│  │                                                           │  │
│  │  3. Upload file to Storage:                              │  │
│  │     fileUrl = await FireBaseServices.UploadFileCdn(...)  │  │
│  │                                                           │  │
│  │  4. Create ApartmentImportSet:                           │  │
│  │     card.imports = cards;                                 │  │
│  │     card.importFile = new uImportFile { ... };           │  │
│  │                                                           │  │
│  │  5. Call Service: _apartmentService.ImportApartmentAsync │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Service: ApartmentService                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ImportApartmentAsync(ApartmentImportSet importSet)        │  │
│  │                                                           │  │
│  │  1. Validate import data:                                │  │
│  │     - Check required fields                              │  │
│  │     - Validate business rules                            │  │
│  │                                                           │  │
│  │  2. Call Repository: _repository.ImportApartmentAsync   │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: ApartmentRepository                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ImportApartmentAsync(ApartmentImportSet importSet)       │  │
│  │                                                           │  │
│  │  await base.SetImport<                                    │  │
│  │    ApartmentImportItem,                                   │  │
│  │    ApartmentImportSet                                     │  │
│  │  >(                                                       │  │
│  │    "sp_res_apartment_import",                             │  │
│  │    importSet,                                             │  │
│  │    "apartments",                                          │  │
│  │    TableTypes.APARTMENT_IMPORT_TYPE,                      │  │
│  │    new { }                                                │  │
│  │  )                                                        │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Database: Stored Procedure                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  sp_res_apartment_import                                  │  │
│  │                                                           │  │
│  │  Input: @apartments Table-Valued Parameter                │  │
│  │  (Type: apartment_import_type)                           │  │
│  │                                                           │  │
│  │  1. Validate each row                                    │  │
│  │  2. Check duplicates                                     │  │
│  │  3. Insert valid records                                 │  │
│  │  4. Return ImportListPage with:                          │  │
│  │     - Valid records                                      │  │
│  │     - Error records                                      │  │
│  │     - Summary                                            │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Response: ImportListPage                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  {                                                       │  │
│  │    "validRecords": [ ... ],                             │  │
│  │    "errorRecords": [                                     │  │
│  │      {                                                   │  │
│  │        "row": 5,                                         │  │
│  │        "errors": ["RoomCode is required"]               │  │
│  │      }                                                   │  │
│  │    ],                                                    │  │
│  │    "summary": {                                          │  │
│  │      "total": 100,                                       │  │
│  │      "valid": 95,                                        │  │
│  │      "errors": 5                                         │  │
│  │    }                                                     │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔔 NOTIFICATION DATA FLOW

### Send Notification Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Controller: NotifyController                                    │
│  POST /api/v2/notify/SendNotify                                 │
│  Body: { "subject": "...", "content": "...", "recipients": [...] }
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Service: NotifyService                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SendNotify(NotifyInfo info)                            │  │
│  │                                                           │  │
│  │  1. Create notification record in database               │  │
│  │  2. Prepare recipients list                             │  │
│  │  3. Create notification job                             │  │
│  │  4. Trigger notification sending                         │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: NotifyRepository                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Insert into NotifyInbox                             │  │
│  │  2. Insert into NotifyTo (recipients)                   │  │
│  │  3. Insert into NotifyJob                               │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Background Service / Job                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Process NotifyJob:                                       │  │
│  │                                                           │  │
│  │  1. Get pending jobs                                     │  │
│  │  2. For each notification:                               │  │
│  │     - Send Push Notification                            │  │
│  │     - Send SMS (if configured)                          │  │
│  │     - Send Email (if configured)                        │  │
│  │  3. Update NotifySent                                    │  │
│  │  4. Update NotifyJob status                             │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  External Services                                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • Firebase Cloud Messaging (Push)                      │  │
│  │  • SMS Gateway (SMS)                                    │  │
│  │  • Email Service (Email)                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 TRANSACTION FLOW

### Transaction Management

```
┌─────────────────────────────────────────────────────────────────┐
│  Service: Complex Business Operation                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SetCardInfoV2(CardInfoV2 info)                          │  │
│  │  {                                                       │  │
│  │    // Multiple operations                                │  │
│  │    1. Create/Update Apartment Card                        │  │
│  │    2. Create/Update Vehicle Card                         │  │
│  │    3. Create/Update Credit Card                          │  │
│  │    4. Update Related Records                            │  │
│  │  }                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Stored Procedure: Transaction Management                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  BEGIN TRANSACTION                                       │  │
│  │                                                           │  │
│  │  BEGIN TRY                                               │  │
│  │    -- Operation 1                                        │  │
│  │    INSERT INTO MAS_Cards ...                             │  │
│  │                                                           │  │
│  │    -- Operation 2                                        │  │
│  │    INSERT INTO MAS_CardVehicle ...                       │  │
│  │                                                           │  │
│  │    -- Operation 3                                        │  │
│  │    UPDATE MAS_Apartments ...                             │  │
│  │                                                           │  │
│  │    COMMIT TRANSACTION                                    │  │
│  │  END TRY                                                 │  │
│  │                                                           │  │
│  │  BEGIN CATCH                                             │  │
│  │    ROLLBACK TRANSACTION                                 │  │
│  │    RETURN ERROR                                          │  │
│  │  END CATCH                                               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 DATA VALIDATION FLOW

### Validation Layers

```
┌─────────────────────────────────────────────────────────────────┐
│  Validation Flow                                                 │
│                                                                   │
│  Layer 1: Client-Side Validation                                 │
│  └─→ HTML5 validation, JavaScript validation                     │
│                                                                   │
│  Layer 2: API Gateway / Load Balancer                            │
│  └─→ Request size, rate limiting                                 │
│                                                                   │
│  Layer 3: ASP.NET Core Model Validation                          │
│  └─→ ModelState.IsValid, Data Annotations                        │
│                                                                   │
│  Layer 4: Controller Validation                                   │
│  └─→ Manual validation, custom checks                            │
│                                                                   │
│  Layer 5: Service Layer Business Validation                      │
│  └─→ Business rules, domain validation                           │
│                                                                   │
│  Layer 6: Repository Validation                                  │
│  └─→ Parameter validation, data integrity                        │
│                                                                   │
│  Layer 7: Database Constraints                                  │
│  └─→ Primary keys, foreign keys, check constraints             │
│                                                                   │
│  Layer 8: Stored Procedure Validation                            │
│  └─→ Business logic validation, data validation                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 COMMON INFO FLOW

### CommonInfo Context Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  Request with JWT Token                                          │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  UniCommonBaseRepository                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CommonInfo Property:                                     │  │
│  │  {                                                       │  │
│  │    UserId: "extracted from JWT claims",                  │  │
│  │    ClientId: "from header or claims",                   │  │
│  │    ConnectionString: "from configuration",                │  │
│  │    AcceptLanguage: "from header",                        │  │
│  │    ProjectCd: "from header or user context"             │  │
│  │  }                                                       │  │
│  └────────────────────────┬────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repository: Auto-Inject CommonInfo                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  GetPageAsync(filter)                                     │  │
│  │  {                                                       │  │
│  │    // CommonInfo automatically added to SP parameters    │  │
│  │    await GetDataListPageAsync(                           │  │
│  │      "sp_res_apartment_page",                            │  │
│  │      filter,                                             │  │
│  │      param => {                                          │  │
│  │        // CommonInfo.UserId, CommonInfo.ClientId         │  │
│  │        // automatically added by base method             │  │
│  │      }                                                   │  │
│  │    )                                                     │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 TÀI LIỆU LIÊN QUAN

- **00_Project_Structure.md**: Cấu trúc project
- **01_High_Level_Architecture.md**: Kiến trúc tổng thể
- **02_DATABASE_STRUCTURE.md**: Cấu trúc database
- **03_API_Documentation.md**: Tài liệu API endpoints

---

## 🎯 TÓM TẮT

### Data Flow Patterns

- ✅ **Controller → Service → Repository → Database**: Standard flow
- ✅ **Repository Pattern**: Abstraction cho data access
- ✅ **Stored Procedures**: Business logic ở database layer
- ✅ **AutoMapper**: Data transformation giữa layers
- ✅ **Dapper**: Lightweight ORM cho data access
- ✅ **CommonInfo**: Context propagation qua các layers
- ✅ **Error Handling**: Centralized exception handling
- ✅ **Transaction Management**: Database-level transactions

### Key Flows

- ✅ **CRUD Operations**: Create, Read, Update, Delete flows
- ✅ **Authentication Flow**: JWT token validation và claims extraction
- ✅ **Pagination Flow**: Efficient data paging
- ✅ **Import Flow**: Excel file import với validation
- ✅ **Notification Flow**: Multi-channel notification sending
- ✅ **Storage Flow**: File upload/download với MinIO/Firebase

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0



# 03. API Documentation

## 📋 TỔNG QUAN

Tài liệu này mô tả các API endpoints của **UNI Resident API**, bao gồm các thông tin về routes, HTTP methods, request/response models, và authentication requirements.

### Base URL

```
Development: http://localhost:5000
Production: https://api.sunshinegroup.vn:5000
```

### API Version

Hệ thống hỗ trợ 2 phiên bản API:
- **Version 1**: `/api/v1/shome/[action]` - Legacy API
- **Version 2**: `/api/v2/[module]/[action]` - Main API (Recommended)

### Authentication

Tất cả API endpoints yêu cầu **JWT Bearer Token** authentication.

```http
Authorization: Bearer <your_jwt_token>
```

### Response Format

Tất cả API responses đều có format chuẩn:

```json
{
  "status": 1,
  "statusCode": 200,
  "message": "Success",
  "data": { ... }
}
```

#### Response Status Codes:
- `1` - Success
- `2` - Error/Warning
- `0` - Failed

---

## 📁 API MODULES

### 1. 🏠 APARTMENT MANAGEMENT (`/api/v2/apartment`)

Module quản lý căn hộ, bao gồm thông tin căn hộ, thành viên, hộ gia đình.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetApartmentSearch` | Tìm kiếm căn hộ |
| GET | `/GetApartmentFilter` | Lấy bộ lọc căn hộ |
| GET | `/GetApartmentPage` | Danh sách căn hộ (paged) |
| GET | `/GetApartmentInfo` | Chi tiết căn hộ |
| POST | `/SetApartmentInfo` | Cập nhật thông tin căn hộ |
| POST | `/SetApartmentAddInfo` | Thêm mới căn hộ |
| DELETE | `/DeleteApartment` | Xóa căn hộ |
| GET | `/GetApartmentAddInfo` | Form thêm mới căn hộ |
| GET | `/GetApartmentChangeRoomCodeInfo` | Form đổi mã căn hộ |
| POST | `/SetApartmentChangeRoomCodeInfo` | Đổi mã căn hộ |
| GET | `/GetApartmentImportTemp` | Template import Excel |
| POST | `/ApartmentImport` | Import căn hộ từ Excel |
| POST | `/ImportApartmentAccepted` | Xác nhận import |
| GET | `/GetHistoryNotifyByApartmentPage` | Lịch sử thông báo theo căn hộ |
| GET | `/GetHistoryEmailByApartmentPage` | Lịch sử email theo căn hộ |
| GET | `/GetHistorySmsByApartmentPage` | Lịch sử SMS theo căn hộ |

#### Examples

**Get Apartment Page:**
```http
GET /api/v2/apartment/GetApartmentPage?projectCd=PROJECT01&buildCd=BLD01&offSet=0&pageSize=10
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": 1,
  "statusCode": 200,
  "message": "Success",
  "data": {
    "data": [...],
    "total": 100,
    "offset": 0,
    "pageSize": 10
  }
}
```

**Get Apartment Info:**
```http
GET /api/v2/apartment/GetApartmentInfo?apartmentId=123
Authorization: Bearer <token>
```

**Set Apartment Info:**
```http
POST /api/v2/apartment/SetApartmentInfo
Authorization: Bearer <token>
Content-Type: application/json

{
  "ApartmentId": 123,
  "RoomCode": "A101",
  "projectCd": "PROJECT01",
  ...
}
```

---

### 2. 🎫 CARD MANAGEMENT (`/api/v2/card`)

Module quản lý thẻ cư dân, thẻ khách, thẻ nội bộ.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetCardPage` | Danh sách thẻ theo căn hộ |
| GET | `/GetGuestCardPage` | Danh sách thẻ khách |
| GET | `/GetCardInfo` | Chi tiết thẻ |
| GET | `/GetCardInfoV2` | Form thêm/sửa thẻ (V2) |
| POST | `/SetCardInfo` | Cập nhật thông tin thẻ |
| POST | `/SetCardInfoV2` | Thêm/sửa thẻ (V2) |
| POST | `/SetGuestCardInfo` | Thêm/sửa thẻ khách |
| DELETE | `/DeleteCard` | Xóa thẻ |
| PUT | `/SetCardLocked` | Mở/khóa thẻ |
| GET | `/GetVehicleCardPage` | Danh sách thẻ xe theo căn hộ |
| GET | `/GetVehicleCardInfo` | Chi tiết thẻ xe |
| POST | `/SetVehicleCardInfo` | Thêm/sửa thẻ xe |
| POST | `/SetVehicleLocked` | Mở/khóa thẻ xe |
| POST | `/SetVehicleLockedWithReason` | Mở/khóa thẻ xe kèm lý do |
| POST | `/SetCardReturnRequest` | Yêu cầu trả thẻ |
| GET | `/GetVehiclePaymentByDayInfo` | Tính gia hạn thẻ xe |
| POST | `/SetVehiclePaymentByDayInfo` | Gia hạn thẻ xe |
| DELETE | `/DeleteVehicleCard` | Xóa thẻ xe |
| GET | `/GetResidentCardFilter` | Bộ lọc thẻ cư dân |
| GET | `/GetResidentCardPage` | Danh sách thẻ cư dân |
| GET | `/GetResidentVehicleFilter` | Bộ lọc xe cư dân |
| GET | `/GetResidentVehiclePage` | Danh sách xe cư dân |
| GET | `/GetVehicleCardDailyFilter` | Bộ lọc thẻ lượt |
| GET | `/GetVehicleCardDailyPage` | Danh sách thẻ lượt |
| GET | `/GetVehicleHistoryChange` | Lịch sử thay đổi thẻ xe |
| GET | `/GetImportPage` | Lịch sử import |
| POST | `/Import` | Import thẻ từ Excel |
| POST | `/ImportAccepted` | Xác nhận import thẻ |
| POST | `/ImportVehicleCardBaseAccepted` | Xác nhận import thẻ xe |
| GET | `/GetVehicleCardBaseImportTemp` | Template import thẻ xe |
| POST | `/VehicleCardImport` | Import thẻ xe từ Excel |

#### Examples

**Get Card Page:**
```http
GET /api/v2/card/GetCardPage?apartmentId=123&offSet=0&pageSize=10
Authorization: Bearer <token>
```

**Set Card Locked:**
```http
PUT /api/v2/card/SetCardLocked
Authorization: Bearer <token>
Content-Type: application/json

{
  "CardCd": "CARD001",
  "Status": 1  // 0: Mở, 1: Khóa
}
```

---

### 3. 🚗 CARD VEHICLE MANAGEMENT (`/api/v2/cardvehicle`)

Module quản lý thẻ xe chi tiết, bao gồm xe cư dân, xe khách, xe nội bộ.

#### Sub-modules:
- **VehicleResidentController** - Xe cư dân
- **VehicleGuestController** - Xe khách
- **VehicleInternalController** - Xe nội bộ
- **VehiclePaymentController** - Thanh toán thẻ xe

#### Examples

**Get Vehicle Resident Page:**
```http
GET /api/v2/cardvehicle/VehicleResident/GetPage?projectCd=PROJECT01&offSet=0&pageSize=10
Authorization: Bearer <token>
```

---

### 4. 🔔 REQUEST MANAGEMENT (`/api/v2/request`)

Module quản lý yêu cầu và phản ánh từ cư dân.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetApartmentRequestPage` | Danh sách yêu cầu theo căn hộ |
| GET | `/GetRequestInfo` | Chi tiết yêu cầu |
| GET | `/GetRequestFilter` | Bộ lọc yêu cầu |
| GET | `/GetRequestPage` | Danh sách yêu cầu (xử lý) |
| GET | `/GetRequestProcessPage` | Danh sách quy trình xử lý |
| POST | `/SetRequestInfo` | Tạo/cập nhật yêu cầu |
| POST | `/SetRequestProcess` | Xử lý yêu cầu |
| POST | `/SetRequestAssign` | Phân công xử lý |
| POST | `/SetRequestReview` | Đánh giá yêu cầu |
| DELETE | `/DeleteRequest` | Xóa yêu cầu |

#### Examples

**Get Request Page:**
```http
GET /api/v2/request/GetRequestPage?projectCd=PROJECT01&status=0&offSet=0&pageSize=10
Authorization: Bearer <token>
```

**Set Request Info:**
```http
POST /api/v2/request/SetRequestInfo
Authorization: Bearer <token>
Content-Type: application/json

{
  "RequestId": null,
  "ApartmentId": 123,
  "RequestTypeId": 1,
  "Comment": "Yêu cầu sửa chữa",
  "IsNow": true
}
```

---

### 5. 📧 NOTIFICATION MANAGEMENT (`/api/v2/visitor/notify`)

Module quản lý thông báo, visitor notifications.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetNotifyPage` | Danh sách thông báo |
| GET | `/GetNotifyInfo` | Chi tiết thông báo |
| POST | `/SetNotifyInfo` | Tạo/cập nhật thông báo |
| POST | `/SendNotify` | Gửi thông báo |
| DELETE | `/DeleteNotify` | Xóa thông báo |

---

### 6. 🛗 ELEVATOR MANAGEMENT (`/api/v2/elevator`)

Module quản lý thang máy, thẻ thang máy, thiết bị.

#### Sub-modules:
- **ElevatorController** - Quản lý thang máy chính
- **ElevatorBuildingController** - Quản lý tòa nhà thang máy
- **ElevatorCardController** - Quản lý thẻ thang máy
- **ElevatorDeviceController** - Quản lý thiết bị thang máy
- **ElevatorParamController** - Quản lý tham số

---

### 7. 💰 SERVICE FEE MANAGEMENT (`/api/v2/servicefee`)

Module quản lý phí dịch vụ, biên lai, hóa đơn.

#### Sub-modules:
- **FeeServiceController** - Quản lý phí dịch vụ
- **FeeElectricWaterController** - Quản lý phí điện nước
- **ReceiptController** - Quản lý biên lai
- **InvoiceController** - Quản lý hóa đơn
- **BankTransactionController** - Giao dịch ngân hàng
- **ServiceController** - Dịch vụ

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/Receipt/GetReceiptPage` | Danh sách biên lai |
| GET | `/Receipt/GetReceiptInfo` | Chi tiết biên lai |
| POST | `/Receipt/SetReceiptInfo` | Tạo/cập nhật biên lai |
| POST | `/Receipt/PrintReceipt` | In biên lai |

---

### 8. 💵 SERVICE PRICE MANAGEMENT (`/api/v2/serviceprice`)

Module quản lý bảng giá dịch vụ.

#### Sub-modules:
- **ServicePriceCommonController** - Bảng giá chung
- **ServicePriceElectricController** - Bảng giá điện
- **ServicePriceElectricDetailController** - Chi tiết giá điện
- **ServicePriceWaterController** - Bảng giá nước
- **ServicePriceWaterDetailController** - Chi tiết giá nước
- **ServicePriceVehicleController** - Bảng giá xe
- **ServicePriceVehicleDetailController** - Chi tiết giá xe
- **ServicePriceVehicleDailyController** - Giá xe ngày
- **ServicePriceVehicleDailyDetailController** - Chi tiết giá xe ngày
- **ServicePriceMaintenanceController** - Giá bảo trì
- **ServicePriceResidenceTypeController** - Giá theo loại căn hộ
- **ServicePriceTypeController** - Loại giá
- **PaymentPriorityConfigsController** - Cấu hình ưu tiên thanh toán

---

### 9. 👥 FAMILY MEMBER MANAGEMENT (`/api/v2/apartment/familymember`)

Module quản lý thành viên căn hộ.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetFamilyMemberPage` | Danh sách thành viên |
| GET | `/GetFamilyMemberInfo` | Chi tiết thành viên |
| POST | `/SetFamilyMemberInfo` | Thêm/sửa thành viên |
| DELETE | `/DeleteFamilyMember` | Xóa thành viên |

---

### 10. 👨‍👩‍👧‍👦 HOUSEHOLD MANAGEMENT (`/api/v2/apartment/household`)

Module quản lý hộ gia đình.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetHouseholdPage` | Danh sách hộ gia đình |
| GET | `/GetHouseholdInfo` | Chi tiết hộ gia đình |
| POST | `/SetHouseholdInfo` | Thêm/sửa hộ gia đình |

---

### 11. 🏢 PROJECT MANAGEMENT (`/api/v2/apartment/project`)

Module quản lý dự án.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetProjectPage` | Danh sách dự án |
| GET | `/GetProjectInfo` | Chi tiết dự án |
| POST | `/SetProjectInfo` | Cập nhật thông tin dự án |

---

### 12. 📊 REPORTS (`/api/v2/reports`)

Module quản lý báo cáo.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetReportList` | Danh sách báo cáo |
| POST | `/GenerateReport` | Tạo báo cáo |
| GET | `/DownloadReport` | Tải báo cáo |

---

### 13. 👤 USER MANAGEMENT (`/api/v2/user`)

Module quản lý người dùng.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetUserInfo` | Thông tin người dùng |
| POST | `/SetUserInfo` | Cập nhật thông tin người dùng |
| GET | `/GetUserConfig` | Cấu hình người dùng |
| POST | `/SetUserConfig` | Cập nhật cấu hình |

---

### 14. 🎨 ADVERTISEMENT (`/api/v2/advertisement`)

Module quản lý quảng cáo.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/GetAdvertisementPage` | Danh sách quảng cáo |
| GET | `/GetAdvertisementInfo` | Chi tiết quảng cáo |
| POST | `/SetAdvertisementInfo` | Tạo/cập nhật quảng cáo |
| DELETE | `/DeleteAdvertisement` | Xóa quảng cáo |
| GET | `/GetAdvertisementAnalytics` | Thống kê quảng cáo |

---

### 15. ⚙️ SETTINGS (`/api/v2/settings`)

Module cài đặt hệ thống.

#### Sub-modules:
- **CommonController** - Cấu hình chung
- **ImportController** - Quản lý import
- **UIConfigController** - Cấu hình UI
- **VehicleTypeController** - Loại xe
- **SysManageController** - Quản lý hệ thống

---

### 16. 📁 STORAGE (`/api/v2/storage`)

Module quản lý file storage.

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/Upload` | Upload file |
| GET | `/Download` | Download file |
| DELETE | `/Delete` | Xóa file |

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### JWT Token Flow

1. Client gửi credentials đến Keycloak
2. Keycloak trả về JWT token
3. Client sử dụng token trong header `Authorization: Bearer <token>`
4. API validate token và extract claims

### Required Headers

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
projectcode: <project_code>  // Optional, một số endpoints
```

### Role-Based Access Control

Một số endpoints yêu cầu specific roles:
- `SHOME_MAN` - Manager role
- `SHOME_USR` - User role

---

## 📝 REQUEST/RESPONSE MODELS

### Common Request Models

#### Pagination Filter
```json
{
  "projectCd": "string",
  "filter": "string",
  "offSet": 0,
  "pageSize": 10,
  "gridWidth": 0
}
```

#### Common View Info Request
```json
{
  "id": "guid",
  "parentId": "guid"
}
```

### Common Response Models

#### Base Response
```typescript
interface BaseResponse<T> {
  status: number;      // 1: Success, 2: Warning, 0: Error
  statusCode: number;  // HTTP status code
  message: string;
  data: T;
  errors?: string[];
}
```

#### Paged Response
```typescript
interface CommonDataPage {
  data: any[];
  total: number;
  offset: number;
  pageSize: number;
}
```

---

## 🔄 ERROR HANDLING

### Error Response Format

```json
{
  "status": 0,
  "statusCode": 400,
  "message": "Error message",
  "data": null,
  "errors": [
    "Validation error 1",
    "Validation error 2"
  ]
}
```

### HTTP Status Codes

- `200 OK` - Success
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

---

## 📚 SWAGGER DOCUMENTATION

API documentation có sẵn tại Swagger UI khi chạy application:

```
http://localhost:5000/swagger
```

Swagger UI cho phép:
- Xem tất cả endpoints
- Test API trực tiếp
- Xem request/response schemas
- OAuth2 authentication

---

## 🧪 TESTING EXAMPLES

### Using cURL

```bash
# Get Apartment Page
curl -X GET "http://localhost:5000/api/v2/apartment/GetApartmentPage?projectCd=PROJECT01&offSet=0&pageSize=10" \
  -H "Authorization: Bearer <your_token>" \
  -H "Content-Type: application/json"

# Create Apartment
curl -X POST "http://localhost:5000/api/v2/apartment/SetApartmentAddInfo" \
  -H "Authorization: Bearer <your_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "RoomCode": "A101",
    "projectCd": "PROJECT01",
    "buildingCd": "BLD01"
  }'
```

### Using Postman

1. Import collection từ Swagger
2. Set environment variables:
   - `base_url`: http://localhost:5000
   - `token`: <your_jwt_token>
3. Use `{{base_url}}` và `{{token}}` trong requests

---

## 📚 TÀI LIỆU LIÊN QUAN

- **00_Project_Structure.md**: Cấu trúc project
- **01_High_Level_Architecture.md**: Kiến trúc tổng thể
- **02_DATABASE_STRUCTURE.md**: Cấu trúc database

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0



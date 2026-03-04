# 07. Resident App API - Architecture & Endpoints Documentation

## 📋 TỔNG QUAN

**UNI Resident App API** là API backend dành cho **Mobile Application**, phục vụ 3 đối tượng người dùng chính:

1. **Khách (Guest)** - `userType = 0`
2. **Cư dân (Resident)** - `userType = 1`
3. **Quản lý (Manager)** - `userType = 2` (Ban quản lý tòa nhà, Bên cung cấp dịch vụ)

### Mục Đích

API này cung cấp các endpoint cho mobile app để:
- Quản lý thông tin căn hộ và thành viên
- Quản lý thẻ (thẻ cư dân, thẻ xe, thẻ thang máy)
- Tạo và xử lý yêu cầu/phản ánh
- Xem hóa đơn và thanh toán
- Nhận thông báo
- Quản lý điểm tích lũy
- Chat và hỗ trợ

---

## 🏗️ KIẾN TRÚC

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Mobile Applications (iOS/Android)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Guest App    │  │ Resident App│  │ Manager App  │      │
│  │ (userType=0) │  │ (userType=1)│  │ (userType=2) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTPS/REST API
                         │ JWT Bearer Token
                         │
┌────────────────────────▼────────────────────────────────────┐
│          UNI Resident App API (ASP.NET Core 8.0)            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Controllers (Version1)                               │   │
│  │ - LoginController                                    │   │
│  │ - HomeController                                     │   │
│  │ - ApartmentController                                │   │
│  │ - CardController                                     │   │
│  │ - RequestController                                  │   │
│  │ - InvoiceController                                  │   │
│  │ - NotifyController                                   │   │
│  │ - ...                                                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Middleware                                           │   │
│  │ - ErrorHandlerMiddleware                             │   │
│  │ - DraftFieldMiddleware                               │   │
│  │ - JsonResponseModifierFilter                         │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Business Logic Layer
                         │
┌────────────────────────▼────────────────────────────────────┐
│              UNI.ResidentApp.BLL                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Business Services                                   │   │
│  │ - AppUserService                                    │   │
│  │ - AppApartmentService                               │   │
│  │ - AppCardService                                    │   │
│  │ - AppRequestService                                 │   │
│  │ - AppInvoiceService                                 │   │
│  │ - AppNotifyService                                  │   │
│  │ - ...                                               │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Data Access Layer
                         │
┌────────────────────────▼────────────────────────────────────┐
│              UNI.ResidentApp.DAL                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Repositories                                         │   │
│  │ - AppUserRepository                                  │   │
│  │ - AppApartmentRepository                             │   │
│  │ - AppCardRepository                                  │   │
│  │ - AppRequestRepository                               │   │
│  │ - ...                                                │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Database (SQL Server)
                         │
┌────────────────────────▼────────────────────────────────────┐
│              Database (dbSHome, dbAppManager)                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Tables:                                              │   │
│  │ - core_user_profile (user info)                     │   │
│  │ - MAS_Apartment (apartments)                        │   │
│  │ - MAS_Card (cards)                                   │   │
│  │ - MAS_Request (requests)                            │   │
│  │ - MAS_Invoice (invoices)                            │   │
│  │ - ...                                                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
                         │ External Services
                         │
┌────────────────────────▼────────────────────────────────────┐
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Keycloak     │  │ MinIO/       │  │ RocketChat  │      │
│  │ (Auth)       │  │ Firebase     │  │ (Chat)      │      │
│  │              │  │ (Storage)    │  │             │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### JWT Bearer Authentication

**Provider**: Keycloak

**Configuration** (`appsettings.json`):
```json
{
  "Jwt": {
    "BaseUrl": "https://idp-dev.unicloudgroup.com.vn",
    "Authority": "https://idp-dev.unicloudgroup.com.vn/realms/realm_ssg_service",
    "ClientId": "api_resident_app",
    "Realm": "realm_ssg_service"
  }
}
```

**Authentication Flow**:
1. Client gửi credentials (username/password) đến `/api/v1/login/Login`
2. API gọi Keycloak để authenticate
3. Keycloak trả về access token và refresh token
4. Client sử dụng access token trong header: `Authorization: Bearer {token}`
5. API validate token và extract user info (userId, userType, roles)

**Token Validation**:
- Validate Issuer
- Validate Audience
- Validate Lifetime
- Map Realm Roles to .NET Claims

---

## 👥 USER TYPES & ROLES

### UserType Enum

```csharp
public enum UserType
{
    Guest = 0,      // Khách
    Resident = 1,    // Cư dân
    Manager = 2     // Quản lý (Ban quản lý tòa nhà, Bên cung cấp dịch vụ)
}
```

### Phân Quyền Theo UserType

**userType = 0 (Khách/Guest)**:
- Xem thông tin căn hộ (nếu được mời)
- Xem thông báo công khai
- Tạo yêu cầu/đăng ký dịch vụ
- Quản lý thẻ khách (guest card)

**userType = 1 (Cư dân/Resident)**:
- Tất cả quyền của Guest
- Quản lý căn hộ và thành viên
- Quản lý thẻ cư dân, thẻ xe
- Xem và thanh toán hóa đơn
- Tạo yêu cầu/phản ánh
- Quản lý điểm tích lũy
- Chat với hỗ trợ

**userType = 2 (Quản lý/Manager)**:
- Tất cả quyền của Resident
- Xử lý yêu cầu của cư dân
- Quản lý thông báo
- Xem báo cáo và thống kê
- Quản lý thẻ thang máy
- Quản lý dịch vụ

---

## 📱 USER INTERFACE & USER EXPERIENCE

### Màn Hình Chính Theo UserType

Hệ thống cung cấp 3 giao diện khác nhau cho từng đối tượng người dùng, được phân biệt rõ ràng qua `userType`.

---

### 1. Guest (userType = 0) - Màn Hình Khách

#### Header Section
- **Greeting**: "Xin chào, [Tên người dùng]"
- **Profile Picture**: Ảnh đại diện người dùng (hình tròn)
- **Illustration**: Nhân vật hoạt hình ngồi thiền (màu xanh lá)

#### Apartment Registration Card
- **Background**: Thẻ màu trắng với bo góc
- **Message**: "Quý khách hiện chưa phải là cư dân của UniHomes."
- **Action Button**: 
  - Nút màu cam lớn: **"Đăng ký cư dân"** (Register as a resident)
  - Khi nhấp sẽ chuyển đến màn hình đăng ký căn hộ

#### Module "Khám phá" (Explore)
Hiển thị 4 module chính:
1. **Thẻ** (Card): Icon thẻ với hình người
   - Quản lý thẻ khách
   - Endpoint: `GET /api/v1/card/GetPage`
2. **Tiện ích** (Utilities/Amenities): Icon nhà với sóng Wi-Fi
   - Đăng ký dịch vụ tiện ích
   - Endpoint: `GET /api/v1/service/GetServicePage`
3. **Thang máy** (Elevator): Icon thang máy với mũi tên lên/xuống
   - Xem thông tin thang máy
   - Endpoint: `GET /api/v1/elevator/GetElevatorCardPage`
4. **Góp ý** (Feedback): Icon bong bóng chat
   - Gửi phản ánh/ý kiến
   - Endpoint: `POST /api/v1/feedback/SetFeedback`

#### Banner Quảng Cáo
- **KienlongBank**: Banner quảng cáo ngân hàng
- **Content**: "TIẾT KIỆM HÔM NAY TRÚNG NGAY CĂN HỘ CAO CẤP"
- **Lãi suất**: "Lãi suất 8,6%"
- **Contact**: Phone "1900 629", Website "kienlongbank.com"
- **Carousel**: 3 dots (1 màu cam, 2 màu xám)

#### Tin Tức Nổi Bật
- **Section Title**: "Tin tức nổi bật"
- **Layout**: Grid 2x2 (4 cards)
- **Content**: Tin tức về khóa đào tạo "KỸ NĂNG..."
- **Image**: Người đàn ông và phụ nữ high-five trong môi trường văn phòng

#### Floating Action Buttons (FABs)
- **Blue FAB**: Icon tài liệu/thẻ (có thể là quick action)
- **Orange FAB**: Icon chat bubble (hỗ trợ nhanh)

#### Bottom Navigation
5 tabs:
- **Trang chủ** (Home): Icon tòa nhà (active - màu cam)
- **Cộng đồng** (Community): Icon 2 người
- **App Menu**: Icon lưới 9 ô (active - màu cam)
- **Thông báo** (Notifications): Icon chuông
- **Hồ sơ** (Profile): Icon người dùng

---

### 2. Resident (userType = 1) - Màn Hình Cư Dân

#### Header Section
- **Greeting**: "Xin chào, Trần Đình Đức" (hoặc tên cư dân)
- **Profile Picture**: Ảnh đại diện người dùng (hình tròn)
- **Illustration**: Nhân vật hoạt hình màu xanh lá (giống quả dưa chuột, đội băng đô đỏ, cầm xẻng)

#### Apartment Information Card
- **Background**: Thẻ màu trắng với bo góc
- **Left Side**: Icon tòa nhà màu cam
- **Center**: 
  - **Mã căn hộ**: "R1.0912A12"
  - **Tên dự án**: "Sunshine Place"
- **Right Side**: 
  - Vòng tròn màu đỏ với số "12" và mũi tên xuống
  - Cho phép chọn/xem chi tiết căn hộ khác (nếu có nhiều căn hộ)
- **Endpoint**: `GET /api/v1/apartment/GetApartmentInfo?apartmentId={id}`

#### Invoice Notification Banner
- **Background**: Banner màu cam
- **Message**: "Quý khách có 3 hóa đơn chưa thanh toán"
- **Action**: Mũi tên sang phải (khuyến khích nhấp để xem chi tiết)
- **Endpoint**: `GET /api/v1/invoice/GetInvoicePage?status=unpaid`
- **Badge**: Hiển thị số "3" trên icon Hóa đơn

#### Module "Khám phá" (Explore)
Hiển thị 9 module trong grid 3x3:

**Hàng 1:**
1. **Hóa đơn** (Invoice): Icon hóa đơn màu cam
   - **Badge**: Số đỏ "3" (số hóa đơn chưa thanh toán)
   - Endpoint: `GET /api/v1/invoice/GetInvoicePage`
2. **Thẻ** (Card): Icon thẻ màu xanh dương nhạt
   - Quản lý thẻ cư dân, thẻ xe
   - Endpoint: `GET /api/v1/card/GetPage`
3. **Dịch vụ** (Service): Icon 2 cờ lê bắt chéo màu xanh dương nhạt
   - Đăng ký dịch vụ
   - Endpoint: `GET /api/v1/service/GetServicePage`
4. **Hỗ trợ** (Support): Icon tai nghe màu cam
   - Chat với hỗ trợ
   - Endpoint: `GET /api/v1/chat/GetChatRooms`

**Hàng 2:**
5. **Thành viên** (Members): Icon 2 người màu xanh dương nhạt
   - **Badge**: Số đỏ "3" (có thể là số thành viên mới hoặc thông báo)
   - Quản lý thành viên trong căn hộ
   - Endpoint: `GET /api/v1/apartment/GetFamilyMemberPage`
6. **Góp ý** (Feedback): Icon bong bóng chat màu xanh dương nhạt
   - Gửi phản ánh/ý kiến
   - Endpoint: `POST /api/v1/feedback/SetFeedback`
7. **Tiện ích** (Utilities/Amenities): Icon nhà thông minh màu xanh dương nhạt
   - Đăng ký dịch vụ tiện ích
   - Endpoint: `GET /api/v1/service/GetServicePage`
8. **Thang máy** (Elevator): Icon thang máy màu xanh dương nhạt
   - Quản lý thẻ thang máy
   - Endpoint: `GET /api/v1/elevator/GetElevatorCardPage`

**Hàng 3:**
9. **Tích điểm** (Accumulate Points): Icon vương miện màu cam
   - Xem điểm tích lũy và lịch sử giao dịch
   - Endpoint: `GET /api/v1/point/GetPointBalance`

#### Banner Quảng Cáo
- **Image**: Ngôi nhà hiện đại và gia đình đứng trước nhà
- **Content**: "ƯU ĐÃI CHO VAY" - "MUA/NHẬN CHUYỂN NHƯỢNG BẤT ĐỘNG SẢN"
- **Lãi suất**: "Lãi suất từ 7.8%"
- **Carousel**: 3 dots (1 màu cam, 2 màu xám)

#### Tin Tức Nổi Bật
- **Section Title**: "Tin tức nổi bật"
- **Layout**: Grid 2x2 (4 cards)
- **Content**: Tin tức về khóa đào tạo "KỸ NĂNG..."
- **Image**: Người đàn ông và phụ nữ high-five trong môi trường văn phòng

#### Floating Action Buttons (FABs)
- **Blue FAB**: Icon tài liệu/thẻ màu trắng (có thể là quick action)
- **Orange FAB**: Icon chat bubble màu trắng (chat hỗ trợ nhanh)

#### Bottom Navigation
5 tabs:
- **Trang chủ** (Home): Icon tòa nhà (active - màu cam)
- **Cộng đồng** (Community): Icon 2 người
- **App Menu**: Icon lưới 9 ô (active - màu cam)
- **Thông báo** (Notifications): Icon chuông
- **Hồ sơ** (Profile): Icon người dùng

---

### 3. Manager (userType = 2) - Màn Hình Quản Lý

#### Header Section
- **Greeting**: "Xin chào, BQL tòa nhà" (Building Management Board)
- **Profile Picture**: Ảnh đại diện người dùng (hình tròn)
- **Illustration**: Nhân vật hoạt hình ngồi trên mảng màu xanh lá

#### Building Information Card
- **Background**: Thẻ màu trắng với bo góc
- **Title**: "Sunshine Place"
- **Subtitle**: "Quản lý tòa nhà" (Building Management)
- **Manager-Specific Notification Banner**:
  - **Background**: Banner màu cam nhạt
  - **Message**: "Bạn có 03 yêu cầu cần xem xét"
  - **Action**: Mũi tên sang phải (khuyến khích nhấp để xem chi tiết)
  - **Endpoint**: `GET /api/v1/request/GetPage?status=pending&userType=2`
  - **Badge**: Hiển thị số "3" trên icon Thành viên (có thể là số yêu cầu mới)

#### Module "Khám phá" (Explore)
Hiển thị 9 module trong grid 3x3:

**Hàng 1:**
1. **Hóa đơn** (Invoice): Icon hóa đơn
   - **Badge**: Số đỏ "3" (số hóa đơn cần xử lý hoặc thống kê)
   - Quản lý và xem thống kê hóa đơn
   - Endpoint: `GET /api/v1/invoice/GetInvoicePage`
2. **Thẻ** (Card): Icon thẻ
   - Quản lý tất cả thẻ trong tòa nhà
   - Endpoint: `GET /api/v1/card/GetPage`
3. **Dịch vụ** (Service): Icon 2 cờ lê bắt chéo
   - Quản lý dịch vụ
   - Endpoint: `GET /api/v1/service/GetServicePage`
4. **Hỗ trợ** (Support): Icon tai nghe
   - Chat hỗ trợ cư dân
   - Endpoint: `GET /api/v1/chat/GetChatRooms`

**Hàng 2:**
5. **Thành viên** (Members): Icon 2 người
   - **Badge**: Số đỏ "3" (có thể là số yêu cầu đăng ký căn hộ mới)
   - Quản lý thành viên trong tòa nhà
   - Endpoint: `GET /api/v1/apartment/GetFamilyMemberPage`
6. **Góp ý** (Feedback): Icon bong bóng chat
   - Xem và xử lý phản ánh từ cư dân
   - Endpoint: `GET /api/v1/feedback/GetFeedbackPage`
7. **Tiện ích** (Utilities/Amenities): Icon nhà thông minh
   - Quản lý dịch vụ tiện ích
   - Endpoint: `GET /api/v1/service/GetServicePage`
8. **Thang máy** (Elevator): Icon thang máy
   - Quản lý thẻ thang máy
   - Endpoint: `GET /api/v1/elevator/GetElevatorCardPage`

**Hàng 3:**
9. **Tích điểm** (Accumulate Points): Icon vương miện
   - Xem thống kê điểm tích lũy của cư dân
   - Endpoint: `GET /api/v1/point/GetPointTransactions`

#### Banner Quảng Cáo
- **Image**: Ngôi nhà hiện đại và gia đình đứng trước nhà
- **Content**: "ƯU ĐÃI CHO VAY" - "MUA/NHẬN CHUYỂN NHƯỢNG BẤT ĐỘNG SẢN"
- **Lãi suất**: "Lãi suất từ 7.8%"
- **Carousel**: 3 dots (1 màu cam, 2 màu xám)

#### Tin Tức Nổi Bật
- **Section Title**: "Tin tức nổi bật"
- **Layout**: Grid 2x2 (4 cards)
- **Content**: Tin tức về khóa đào tạo "KỸ NĂNG..."
- **Image**: Người đàn ông và phụ nữ high-five trong môi trường văn phòng

#### Floating Action Buttons (FABs)
- **Blue FAB**: Icon tài liệu/hóa đơn màu trắng (có thể là quick action hoặc tạo thông báo)
- **Orange FAB**: Icon chat bubble màu trắng (chat hỗ trợ cư dân)

#### Bottom Navigation
5 tabs:
- **Trang chủ** (Home): Icon tòa nhà (active - màu cam)
- **Cộng đồng** (Community): Icon 2 người
- **App Menu**: Icon lưới 9 ô (active - màu cam)
- **Thông báo** (Notifications): Icon chuông
- **Hồ sơ** (Profile): Icon người dùng

---

### So Sánh Giao Diện Theo UserType

| Feature | Guest (0) | Resident (1) | Manager (2) |
|---------|-----------|--------------|-------------|
| **Header Greeting** | Tên người dùng | Tên người dùng + Căn hộ | "BQL tòa nhà" |
| **Apartment Info** | ❌ Không có | ✅ Hiển thị mã căn hộ | ✅ "Quản lý tòa nhà" |
| **Registration Card** | ✅ "Đăng ký cư dân" | ❌ Không có | ❌ Không có |
| **Invoice Notification** | ❌ Không có | ✅ "3 hóa đơn chưa thanh toán" | ✅ "3 hóa đơn" (thống kê) |
| **Request Notification** | ❌ Không có | ❌ Không có | ✅ "03 yêu cầu cần xem xét" |
| **Module Count** | 4 modules | 9 modules | 9 modules |
| **Module Access** | Hạn chế (Thẻ, Tiện ích, Thang máy, Góp ý) | Đầy đủ (tất cả 9 modules) | Đầy đủ + Quản lý |
| **Badge Notifications** | ❌ Không có | ✅ Hóa đơn (3), Thành viên (3) | ✅ Hóa đơn (3), Thành viên (3) |

---

### API Endpoints Mapping to UI Components

#### Guest UI Components
- **Đăng ký cư dân**: `POST /api/v1/login/SetUserRegister` → `POST /api/v1/apartment/SetApartmentRegInfo`
- **Thẻ**: `GET /api/v1/card/GetPage` (guest cards only)
- **Tiện ích**: `GET /api/v1/service/GetServicePage`
- **Thang máy**: `GET /api/v1/elevator/GetElevatorCardPage` (view only)
- **Góp ý**: `POST /api/v1/feedback/SetFeedback`

#### Resident UI Components
- **Thông tin căn hộ**: `GET /api/v1/apartment/GetApartmentInfo`
- **Hóa đơn**: `GET /api/v1/invoice/GetInvoicePage` (with badge count)
- **Thẻ**: `GET /api/v1/card/GetPage`
- **Dịch vụ**: `GET /api/v1/service/GetServicePage`
- **Hỗ trợ**: `GET /api/v1/chat/GetChatRooms`
- **Thành viên**: `GET /api/v1/apartment/GetFamilyMemberPage` (with badge count)
- **Góp ý**: `POST /api/v1/feedback/SetFeedback`
- **Tiện ích**: `GET /api/v1/service/GetServicePage`
- **Thang máy**: `GET /api/v1/elevator/GetElevatorCardPage`
- **Tích điểm**: `GET /api/v1/point/GetPointBalance`

#### Manager UI Components
- **Thông tin tòa nhà**: `GET /api/v1/apartment/GetApartmentPage` (all apartments)
- **Yêu cầu cần xem xét**: `GET /api/v1/request/GetPage?status=pending` (with badge count)
- **Hóa đơn**: `GET /api/v1/invoice/GetInvoicePage` (statistics)
- **Thẻ**: `GET /api/v1/card/GetPage` (all cards in building)
- **Dịch vụ**: `GET /api/v1/service/GetServicePage` (management)
- **Hỗ trợ**: `GET /api/v1/chat/GetChatRooms` (support residents)
- **Thành viên**: `GET /api/v1/apartment/GetFamilyMemberPage` (all members)
- **Góp ý**: `GET /api/v1/feedback/GetFeedbackPage` (review and process)
- **Tiện ích**: `GET /api/v1/service/GetServicePage` (management)
- **Thang máy**: `GET /api/v1/elevator/GetElevatorCardPage` (management)
- **Tích điểm**: `GET /api/v1/point/GetPointTransactions` (statistics)

---

## 📡 API ENDPOINTS

### Base URL

```
http://dev.api.resident-appv2.unicloudgroup.com.vn
```

### API Versioning

- **Version**: `v1`
- **Route Pattern**: `api/v1/{controller}/{action}`

---

## 🔑 LOGIN & AUTHENTICATION

### LoginController

**Base Route**: `api/v1/login/[action]`

#### 1. Register User

**Endpoint**: `POST /api/v1/login/SetUserRegister`

**Description**: Đăng ký người dùng mới

**Request**:
```json
{
  "phone": "0912345678",
  "email": "user@example.com",
  "verifyType": 0,  // 0: SMS, 1: Email
  "loginName": "0912345678"
}
```

**Response**:
```json
{
  "result": "success",
  "data": {
    "reg_id": "guid",
    "phone": "0912345678",
    "email": "user@example.com",
    "verifyType": 0,
    "valid": true,
    "secret_cd": "otp-secret-code"
  }
}
```

**UserType**: Xác định khi đăng ký (mặc định: 1 - Resident)

---

#### 2. Verify OTP

**Endpoint**: `PUT /api/v1/login/SetVerifyCode`

**Description**: Xác minh OTP khi đăng ký

**Request**:
```json
{
  "reg_id": "guid",
  "code": "123456",
  "secret_cd": "otp-secret-code"
}
```

**Response**:
```json
{
  "result": "success",
  "data": {
    "loginName": "0912345678",
    "loginSecret": "guid",
    "token": "jwt-access-token",
    "refreshToken": "refresh-token"
  }
}
```

---

#### 3. Resend OTP

**Endpoint**: `PUT /api/v1/login/SetResendCode`

**Description**: Gửi lại mã OTP

**Request**:
```json
{
  "reg_id": "guid"
}
```

---

#### 4. Login

**Endpoint**: `POST /api/v1/login/Login`

**Description**: Đăng nhập với username/password

**Request**:
```json
{
  "username": "0912345678",
  "password": "password123"
}
```

**Response**:
```json
{
  "result": "success",
  "data": {
    "token": "jwt-access-token",
    "refreshToken": "refresh-token"
  }
}
```

---

#### 5. Login with Refresh Token

**Endpoint**: `POST /api/v1/login/LoginWithToken`

**Description**: Lấy access token mới từ refresh token

**Request**:
```json
{
  "token": "refresh-token"
}
```

---

#### 6. Forgot Password

**Endpoint**: `POST /api/v1/login/SetUserForgetPassword`

**Description**: Gửi yêu cầu quên mật khẩu

**Request**:
```json
{
  "loginName": "0912345678",
  "udid": "device-id"
}
```

---

#### 7. Verify Forgot Password OTP

**Endpoint**: `PUT /api/v1/login/SetUserForgetVerifyCode`

**Description**: Xác minh OTP để reset password

---

#### 8. Change Password

**Endpoint**: `POST /api/v1/login/SetChangePassword`

**Description**: Đổi mật khẩu (cần authenticate)

**Request**:
```json
{
  "oldPassword": "old123",
  "newPassword": "new123"
}
```

---

#### 9. Get User Profile

**Endpoint**: `GET /api/v1/login/GetProfileById`

**Description**: Lấy thông tin hồ sơ cá nhân

**Response**:
```json
{
  "result": "success",
  "data": {
    "userId": "guid",
    "loginName": "0912345678",
    "fullName": "Nguyễn Văn A",
    "phone": "0912345678",
    "email": "user@example.com",
    "userType": 1,
    "isVerify": 1
  }
}
```

---

## 🏠 HOME & MODULES

### HomeController

**Base Route**: `api/v1/apphome/[action]`

#### 1. Get Module Desktop

**Endpoint**: `GET /api/v1/apphome/GetModuleDestop`

**Description**: Lấy danh sách các icon/module trên màn hình chính

**Response**:
```json
{
  "result": "success",
  "data": {
    "modules": [
      {
        "mod_cd": "apartment",
        "mod_name": "Căn hộ",
        "icon": "apartment.svg",
        "bannerType": "LOCAL_SVG",
        "order": 1
      },
      {
        "mod_cd": "card",
        "mod_name": "Thẻ",
        "icon": "card.svg",
        "bannerType": "NETWORK_IMAGE",
        "order": 2
      }
    ]
  }
}
```

---

#### 2. Get Module App

**Endpoint**: `GET /api/v1/apphome/GetModuleApp?mod_cd={moduleCode}`

**Description**: Lấy thông tin chi tiết module

---

#### 3. Get Module More

**Endpoint**: `GET /api/v1/apphome/GetModuleMore`

**Description**: Lấy danh sách module "Xem thêm"

---

## 🏢 APARTMENT MANAGEMENT

### ApartmentController

**Base Route**: `api/v1/apartment/[action]`

**UserType Access**: 1 (Resident), 2 (Manager)

#### 1. Get Apartment Registration Info

**Endpoint**: `GET /api/v1/apartment/GetApartmentRegInfo?apartmentId={id}&apartmentRegId={regId}&isPreview={bool}`

**Description**: Lấy thông tin đăng ký căn hộ

**Response**:
```json
{
  "result": "success",
  "data": {
    "apartmentId": 123,
    "apartmentCode": "A101",
    "projectId": 1,
    "projectName": "Sunshine City",
    "members": [
      {
        "memberId": 1,
        "fullName": "Nguyễn Văn A",
        "relationType": "Chủ hộ",
        "phone": "0912345678",
        "idCard": "123456789012"
      }
    ]
  }
}
```

---

#### 2. Set Apartment Registration

**Endpoint**: `POST /api/v1/apartment/SetApartmentRegInfo`

**Description**: Đăng ký căn hộ

**Request**:
```json
{
  "apartmentId": 123,
  "projectId": 1,
  "members": [
    {
      "fullName": "Nguyễn Văn A",
      "relationType": "Chủ hộ",
      "phone": "0912345678",
      "idCard": "123456789012",
      "birthDate": "1990-01-01"
    }
  ]
}
```

---

#### 3. Delete Registration

**Endpoint**: `DELETE /api/v1/apartment/DeleteReg?apartmentRegId={id}`

**Description**: Xóa đăng ký căn hộ

---

#### 4. Get Apartment Relations

**Endpoint**: `GET /api/v1/apartment/GetApartmentRations`

**Description**: Lấy danh sách loại quan hệ thành viên (Chủ hộ, Vợ/Chồng, Con, v.v.)

---

#### 5. Get Apartment List

**Endpoint**: `GET /api/v1/apartment/GetApartmentPage`

**Description**: Lấy danh sách căn hộ của user

**Query Parameters**:
- `offSet`: int (pagination)
- `pageSize`: int
- `projectId`: long?
- `status`: int?

---

#### 6. Get Apartment Info

**Endpoint**: `GET /api/v1/apartment/GetApartmentInfo?apartmentId={id}`

**Description**: Lấy thông tin chi tiết căn hộ

---

#### 7. Get Family Members

**Endpoint**: `GET /api/v1/apartment/GetFamilyMemberPage`

**Description**: Lấy danh sách thành viên trong căn hộ

---

#### 8. Set Family Member

**Endpoint**: `POST /api/v1/apartment/SetFamilyMember`

**Description**: Thêm/thêm thành viên vào căn hộ

---

#### 9. Delete Family Member

**Endpoint**: `DELETE /api/v1/apartment/DeleteFamilyMember?memberId={id}`

**Description**: Xóa thành viên khỏi căn hộ

---

## 💳 CARD MANAGEMENT

### CardController

**Base Route**: `api/v1/card/[action]`

**UserType Access**: 0 (Guest), 1 (Resident), 2 (Manager)

#### 1. Get Card Types

**Endpoint**: `GET /api/v1/card/GetCardTypes`

**Description**: Lấy danh sách loại thẻ (Thẻ cư dân, Thẻ xe, Thẻ khách, Thẻ thang máy)

---

#### 2. Get Card Status

**Endpoint**: `GET /api/v1/card/GetCardStatus`

**Description**: Lấy danh sách trạng thái thẻ (Hoạt động, Khóa, Hết hạn, v.v.)

---

#### 3. Get Vehicle Types

**Endpoint**: `GET /api/v1/card/GetVehicleTypes`

**Description**: Lấy danh sách loại phương tiện (Xe máy, Ô tô, Xe đạp, v.v.)

---

#### 4. Get Card Filter

**Endpoint**: `GET /api/v1/card/GetCardFilter`

**Description**: Lấy thông tin filter cho danh sách thẻ

---

#### 5. Get Card Page

**Endpoint**: `GET /api/v1/card/GetPage`

**Description**: Lấy danh sách thẻ với pagination

**Query Parameters**:
- `offSet`: int
- `pageSize`: int
- `cardType`: int?
- `status`: int?
- `apartmentId`: long?

---

#### 6. Get Card Info

**Endpoint**: `GET /api/v1/card/GetCardInfo?cardId={id}`

**Description**: Lấy thông tin chi tiết thẻ

---

#### 7. Set Card

**Endpoint**: `POST /api/v1/card/SetCard`

**Description**: Tạo/cập nhật thẻ

**Request**:
```json
{
  "cardId": null,
  "cardType": 1,
  "apartmentId": 123,
  "memberId": 1,
  "cardNumber": "CARD001",
  "expireDate": "2025-12-31",
  "vehicleType": 1,
  "vehiclePlate": "30A-12345"
}
```

---

#### 8. Lock/Unlock Card

**Endpoint**: `PUT /api/v1/card/SetCardLock`

**Description**: Khóa/Mở khóa thẻ

**Request**:
```json
{
  "cardId": 1,
  "isLocked": true,
  "reason": "Mất thẻ"
}
```

---

#### 9. Return Card

**Endpoint**: `DELETE /api/v1/card/ReturnCard?cardId={id}`

**Description**: Trả thẻ

---

#### 10. Renew Card

**Endpoint**: `PUT /api/v1/card/RenewCard`

**Description**: Gia hạn thẻ

**Request**:
```json
{
  "cardId": 1,
  "expireDate": "2026-12-31"
}
```

---

## 📝 REQUEST MANAGEMENT

### RequestController

**Base Route**: `api/v1/request/[action]`

**UserType Access**: 0 (Guest), 1 (Resident), 2 (Manager)

#### 1. Get Request Filter

**Endpoint**: `GET /api/v1/request/GetFilter`

**Description**: Lấy thông tin filter cho danh sách yêu cầu

---

#### 2. Get Request Page

**Endpoint**: `GET /api/v1/request/GetPage`

**Description**: Lấy danh sách yêu cầu với pagination

**Query Parameters**:
- `offSet`: int
- `pageSize`: int
- `status`: int?
- `categoryId`: string?
- `projectId`: long?

---

#### 3. Get Category List

**Endpoint**: `GET /api/v1/request/GetCategoryList`

**Description**: Lấy danh sách loại yêu cầu (Sửa chữa, Dịch vụ, Tiện ích, v.v.)

---

#### 4. Get Statuses

**Endpoint**: `GET /api/v1/request/GetStatuses`

**Description**: Lấy danh sách trạng thái yêu cầu (Chờ xử lý, Đang xử lý, Hoàn thành, v.v.)

---

#### 5. Get Request Info

**Endpoint**: `GET /api/v1/request/GetInfo?requestId={id}&categoryId={categoryId}`

**Description**: Lấy thông tin chi tiết yêu cầu

**Response**:
```json
{
  "result": "success",
  "data": {
    "requestId": "guid",
    "title": "Yêu cầu sửa chữa cửa",
    "content": "Cửa phòng khách bị hỏng",
    "categoryId": "repair",
    "status": 1,
    "apartmentId": 123,
    "createDate": "2024-01-15T10:30:00Z",
    "attachments": [
      {
        "attachUrl": "minio://bucket/file.jpg",
        "attachFileName": "hinh-anh.jpg"
      }
    ],
    "processes": [
      {
        "processId": 1,
        "status": "Chờ xử lý",
        "note": "Đã tiếp nhận",
        "createDate": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

---

#### 6. Set Request

**Endpoint**: `POST /api/v1/request/SetRequest`

**Description**: Tạo yêu cầu mới

**Request**:
```json
{
  "title": "Yêu cầu sửa chữa cửa",
  "content": "Cửa phòng khách bị hỏng",
  "categoryId": "repair",
  "apartmentId": 123,
  "attachments": [
    {
      "attachUrl": "minio://bucket/file.jpg",
      "attachFileName": "hinh-anh.jpg",
      "attachType": "image/jpeg"
    }
  ]
}
```

---

#### 7. Update Request

**Endpoint**: `PUT /api/v1/request/SetRequest`

**Description**: Cập nhật yêu cầu

---

#### 8. Delete Request

**Endpoint**: `DELETE /api/v1/request/DeleteRequest?requestId={id}`

**Description**: Xóa yêu cầu (chỉ khi ở trạng thái chờ xử lý)

---

#### 9. Process Request (Manager only)

**Endpoint**: `PUT /api/v1/request/ProcessRequest`

**Description**: Xử lý yêu cầu (chỉ userType = 2)

**Request**:
```json
{
  "requestId": "guid",
  "status": 2,
  "note": "Đã sửa xong",
  "attachments": []
}
```

---

## 📄 INVOICE MANAGEMENT

### InvoiceController

**Base Route**: `api/v1/invoice/[action]`

**UserType Access**: 1 (Resident), 2 (Manager)

#### 1. Get Invoice Filter

**Endpoint**: `GET /api/v1/invoice/GetInvoiceFilter`

**Description**: Lấy thông tin filter cho danh sách hóa đơn

---

#### 2. Get Invoice Page

**Endpoint**: `GET /api/v1/invoice/GetInvoicePage`

**Description**: Lấy danh sách hóa đơn với pagination

**Query Parameters**:
- `offSet`: int
- `pageSize`: int
- `apartmentId`: long?
- `status`: int?
- `fromDate`: DateTime?
- `toDate`: DateTime?

---

#### 3. Get Invoice Info

**Endpoint**: `GET /api/v1/invoice/GetInvoiceInfo?invoiceId={id}`

**Description**: Lấy thông tin chi tiết hóa đơn

**Response**:
```json
{
  "result": "success",
  "data": {
    "invoiceId": 1,
    "invoiceNumber": "INV-2024-001",
    "apartmentId": 123,
    "apartmentCode": "A101",
    "totalAmount": 5000000,
    "paidAmount": 3000000,
    "remainingAmount": 2000000,
    "status": "Chưa thanh toán",
    "dueDate": "2024-02-15",
    "items": [
      {
        "itemName": "Phí quản lý",
        "amount": 2000000,
        "quantity": 1
      },
      {
        "itemName": "Phí điện",
        "amount": 3000000,
        "quantity": 1
      }
    ]
  }
}
```

---

#### 4. Get Electric Water Meter Details

**Endpoint**: `GET /api/v1/invoice/GetElectricWaterMeterDetails`

**Description**: Lấy chi tiết hóa đơn điện/nước

---

#### 5. Pay Invoice

**Endpoint**: `POST /api/v1/invoice/PayInvoice`

**Description**: Thanh toán hóa đơn

**Request**:
```json
{
  "invoiceId": 1,
  "amount": 2000000,
  "paymentMethod": "bank_transfer"
}
```

---

## 📢 NOTIFICATION MANAGEMENT

### NotifyController

**Base Route**: `api/v1/notify/[action]`

**UserType Access**: 0 (Guest), 1 (Resident), 2 (Manager)

#### 1. Get Notify Filter

**Endpoint**: `GET /api/v1/notify/GetNotifyFilter`

**Description**: Lấy thông tin filter cho danh sách thông báo

---

#### 2. Get Notify Ref List

**Endpoint**: `GET /api/v1/notify/GetNotifyRefList`

**Description**: Lấy danh sách loại thông báo

---

#### 3. Get Notify Page

**Endpoint**: `GET /api/v1/notify/GetNotifyPage`

**Description**: Lấy danh sách thông báo với pagination

**Query Parameters**:
- `offSet`: int
- `pageSize`: int
- `projectCd`: string?
- `source_ref`: Guid?
- `isHighLight`: int? (1: chỉ lấy thông báo nổi bật)

---

#### 4. Get Notify Info

**Endpoint**: `GET /api/v1/notify/GetNotifyInfo?notifyId={id}`

**Description**: Lấy thông tin chi tiết thông báo

---

#### 5. Mark as Read

**Endpoint**: `PUT /api/v1/notify/MarkAsRead`

**Description**: Đánh dấu thông báo đã đọc

**Request**:
```json
{
  "notifyId": "guid"
}
```

---

#### 6. Mark All as Read

**Endpoint**: `PUT /api/v1/notify/MarkAllAsRead`

**Description**: Đánh dấu tất cả thông báo đã đọc

---

## 🛎️ SERVICE MANAGEMENT

### ServiceController

**Base Route**: `api/v1/service/[action]`

**UserType Access**: 0 (Guest), 1 (Resident), 2 (Manager)

#### 1. Get Service Page

**Endpoint**: `GET /api/v1/service/GetServicePage`

**Description**: Lấy danh sách dịch vụ

---

#### 2. Get Service Info

**Endpoint**: `GET /api/v1/service/GetServiceInfo?serviceId={id}`

**Description**: Lấy thông tin chi tiết dịch vụ

---

#### 3. Register Service

**Endpoint**: `POST /api/v1/service/RegisterService`

**Description**: Đăng ký dịch vụ

---

## 🛗 ELEVATOR MANAGEMENT

### ElevatorController

**Base Route**: `api/v1/elevator/[action]`

**UserType Access**: 1 (Resident), 2 (Manager)

#### 1. Get Elevator Card Page

**Endpoint**: `GET /api/v1/elevator/GetElevatorCardPage`

**Description**: Lấy danh sách thẻ thang máy

---

#### 2. Set Elevator Card

**Endpoint**: `POST /api/v1/elevator/SetElevatorCard`

**Description**: Đăng ký thẻ thang máy

---

## 💬 FEEDBACK & CHAT

### FeedbackController

**Base Route**: `api/v1/feedback/[action]`

#### 1. Get Feedback Page

**Endpoint**: `GET /api/v1/feedback/GetFeedbackPage`

**Description**: Lấy danh sách phản ánh

---

#### 2. Set Feedback

**Endpoint**: `POST /api/v1/feedback/SetFeedback`

**Description**: Gửi phản ánh

---

### ChatController

**Base Route**: `api/v1/chat/[action]`

**Integration**: RocketChat

#### 1. Get Chat Rooms

**Endpoint**: `GET /api/v1/chat/GetChatRooms`

**Description**: Lấy danh sách phòng chat

---

#### 2. Send Message

**Endpoint**: `POST /api/v1/chat/SendMessage`

**Description**: Gửi tin nhắn

---

## 📊 POINTS & REWARDS

### PointController

**Base Route**: `api/v1/point/[action]`

**UserType Access**: 1 (Resident)

#### 1. Get Point Balance

**Endpoint**: `GET /api/v1/point/GetPointBalance`

**Description**: Lấy số điểm hiện tại

---

#### 2. Get Point Transactions

**Endpoint**: `GET /api/v1/point/GetPointTransactions`

**Description**: Lấy lịch sử giao dịch điểm

---

## 📁 STORAGE & FILE MANAGEMENT

### StorageController

**Base Route**: `Storage/[action]`

Tương tự như Resident API, cung cấp endpoints:
- `UploadFile`: Upload file
- `GetFile`: Download file
- `CreateUploadUrl`: Pre-signed upload URL
- `RemoveFiles`: Xóa file

---

## 🔧 COMMON ENDPOINTS

### CommonController

**Base Route**: `api/v1/common/[action]`

#### 1. Get Common Values

**Endpoint**: `GET /api/v1/common/GetCommonValues?type={type}`

**Description**: Lấy danh sách giá trị chung (dropdown options)

---

#### 2. Get Projects

**Endpoint**: `GET /api/v1/common/GetProjects`

**Description**: Lấy danh sách dự án

---

## 📋 ENDPOINT SUMMARY BY USER TYPE

### Guest (userType = 0)

**Available Endpoints**:
- Login/Register endpoints
- Home/Module endpoints
- Card endpoints (guest cards only)
- Request endpoints (create only)
- Notification endpoints (read only)
- Service endpoints (register only)
- Common endpoints

**Restricted**:
- Apartment management
- Invoice management
- Manager functions

---

### Resident (userType = 1)

**Available Endpoints**:
- Tất cả endpoints của Guest
- Apartment management
- Card management (all types)
- Invoice management
- Request management (full)
- Feedback
- Points & Rewards
- Elevator card management

**Restricted**:
- Request processing (Manager only)
- Notification management (Manager only)
- Reports & Statistics

---

### Manager (userType = 2)

**Available Endpoints**:
- Tất cả endpoints của Resident
- Request processing
- Notification management (create/send)
- Reports & Statistics
- Service management
- Elevator management

---

## 🔄 DATA FLOW

### Request Flow

```
Mobile App
  ↓
[API Request with JWT Token]
  ↓
Resident App API
  ├─→ Validate JWT Token
  ├─→ Extract UserId & UserType
  └─→ Check Authorization
  ↓
Business Logic Layer (BLL)
  ├─→ Validate Request
  ├─→ Apply Business Rules
  └─→ Call DAL
  ↓
Data Access Layer (DAL)
  ├─→ Execute Stored Procedure
  └─→ Return Data
  ↓
BLL
  ├─→ Transform Data
  └─→ Return Response
  ↓
API Controller
  ├─→ Format Response
  └─→ Return JSON
  ↓
Mobile App
```

---

## 🛠️ TECHNICAL STACK

### Framework & Libraries

- **.NET 8.0**: Target framework
- **ASP.NET Core Web API**: Web framework
- **AutoMapper**: Object mapping
- **Dapper**: Micro-ORM for data access
- **Serilog**: Logging
- **Elastic APM**: Application Performance Monitoring
- **NSwag**: OpenAPI/Swagger documentation
- **Keycloak.Net**: Keycloak integration
- **RocketChat**: Chat integration

### External Services

- **Keycloak**: Authentication & Authorization
- **MinIO/Firebase**: File storage
- **RocketChat**: Chat service
- **SQL Server**: Database (dbSHome, dbAppManager)

---

## 📝 BEST PRACTICES

### 1. Authentication

- Luôn sử dụng JWT Bearer token trong header
- Validate token expiration
- Refresh token khi hết hạn

### 2. Error Handling

- Trả về lỗi dạng chuẩn:
```json
{
  "result": "error",
  "errorCode": 1001,
  "message": "Error message"
}
```

### 3. Pagination

- Luôn sử dụng `offSet` và `pageSize` cho list endpoints
- Default `pageSize`: 20
- Max `pageSize`: 100

### 4. UserType Validation

- Validate userType trước khi cho phép truy cập endpoint
- Return 403 Forbidden nếu không có quyền

### 5. File Upload

- Sử dụng pre-signed URL cho file lớn (>5MB)
- Validate file type và size
- Lưu metadata vào database

---

## 📊 SUMMARY

### Key Features

1. **Multi-User Support**: 3 user types với phân quyền rõ ràng
2. **JWT Authentication**: Keycloak-based authentication
3. **RESTful API**: Standard REST endpoints
4. **Versioning**: API versioning (v1)
5. **Swagger Documentation**: Interactive API docs
6. **File Storage**: MinIO/Firebase integration
7. **Chat Integration**: RocketChat support

### Endpoint Categories

- **Authentication**: Login, Register, OTP, Password
- **Home**: Modules, Desktop, App info
- **Apartment**: Registration, Members, Info
- **Card**: Management, Lock/Unlock, Renew
- **Request**: Create, View, Process
- **Invoice**: View, Pay, Details
- **Notification**: List, Read, Mark as read
- **Service**: Register, View
- **Feedback**: Submit, View
- **Chat**: Rooms, Messages
- **Points**: Balance, Transactions
- **Common**: Common values, Projects

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0


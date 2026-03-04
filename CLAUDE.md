# CLAUDE.md

Tệp này cung cấp hướng dẫn cho Claude Code (claude.ai/code) khi làm việc với mã nguồn trong repository này.

## Cấu Trúc Solution

Đây là hệ thống API quản lý cư dân .NET 8.0 với kiến trúc modular:

- **UNI.RESIDENT.API** - Dự án Web API chính (.NET 8.0, ASP.NET Core)
- **UNI.Resident.BLL** - Tầng Logic Nghiệp Vụ (Business Logic Layer)
- **UNI.Resident.DAL** - Tầng Truy Cập Dữ Liệu (Data Access Layer)
- **UNI.Resident.Model** - Các Model Dữ Liệu và DTOs
- **UNI.SUPAPP.API** - Dự án Super App API
- **UNI.HomeApp.API** - Dự án Home App API
- **dbSHome** - Dự án Cơ Sở Dữ Liệu SQL Server
- **uni-common/** - Thư viện tiện ích dùng chung được tổ chức trong thư mục con

Solution tuân theo mô hình kiến trúc 3 tầng với sự phân tách rõ ràng giữa API, logic nghiệp vụ và tầng truy cập dữ liệu.

## Các Lệnh Phát Triển

### Build và Chạy
```bash
# Build toàn bộ solution
dotnet build UNI.RESIDENT.API.sln

# Chạy API chính
dotnet run --project UNI.RESIDENT.API

# Chạy với môi trường cụ thể
dotnet run --project UNI.RESIDENT.API --environment Development
```

### Endpoints Phát Triển
- **API Chính**: http://localhost:5000 (HTTP) / https://localhost:5001 (HTTPS)
- **IIS Express**: http://localhost:3090
- **Swagger UI**: Có sẵn tại endpoint /swagger khi chạy

### Cơ Sở Dữ Liệu
- Sử dụng SQL Server với Entity Framework Core 6.0
- Dự án database: dbSHome (SQL Server Database Project)
- Connection strings được cấu hình trong appsettings.json

## Công Nghệ Chính

- **.NET 8.0** với ASP.NET Core Web API
- **Entity Framework Core 6.0** cho truy cập dữ liệu
- **Swagger/NSwag** cho tài liệu API
- **JWT Bearer Authentication** với tích hợp Keycloak
- **AutoMapper** cho việc ánh xạ đối tượng
- **Serilog** cho logging với tích hợp Elastic APM
- **Newtonsoft.Json** cho serialization JSON

## Cấu Hình

- **appsettings.json** - Cấu hình cơ bản
- **appsettings.development.json** - Cài đặt môi trường phát triển
- **appsettings.production.json** - Cài đặt môi trường production
- Các config theo môi trường được load tự động dựa trên ASPNETCORE_ENVIRONMENT

## Xác Thực & Phân Quyền

- Sử dụng JWT Bearer tokens
- Tích hợp Keycloak cho quản lý danh tính
- OAuth2 flow được cấu hình cho Swagger UI
- Realm roles được ánh xạ thành .NET claims trong Startup.cs:233

## Thư Viện Tiện Ích Chung (uni-common/)

Các thư viện chia sẻ bao gồm:
- **UNI.Common** - Tiện ích và helper cốt lõi
- **UNI.Model** - Các model dữ liệu chia sẻ
- **UNI.Utils** - Tiện ích tổng quát
- **UNI.Document** - Tiện ích xử lý tài liệu
- **UNI.Utilities.*** - Các gói tiện ích khác nhau (Email, Storage, Encryption, v.v.)

## Phụ Thuộc Dự Án

Dự án API chính tham chiếu:
- UNI.Resident.BLL (bao gồm cả DAL và Model layers một cách bắc cầu)
- Các thư viện uni-common được tham chiếu bởi từng dự án riêng lẻ khi cần
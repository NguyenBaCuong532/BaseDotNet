# 06. File Management Documentation

## 📋 TỔNG QUAN

Tài liệu này mô tả hệ thống **Quản Lý File** của **UNI Resident API**, bao gồm các nguyên tắc triển khai, kiến trúc, và best practices cho việc quản lý file trong hệ thống.

### Mục Đích

Hệ thống quản lý file được thiết kế để:
- Quản lý file đính kèm cho các module (yêu cầu, phản ánh, thông báo, v.v.)
- Hỗ trợ nhiều storage provider (MinIO, Firebase, AWS S3)
- Cung cấp API thống nhất cho upload/download file
- Hỗ trợ pre-signed URLs cho upload/download trực tiếp
- Quản lý metadata và tracking file trong database

---

## 🏗️ KIẾN TRÚC

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Applications                        │
│              (Web, Mobile App, Admin Portal)                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTP/REST API
                         │
┌────────────────────────▼────────────────────────────────────┐
│              UNI Resident API (Controllers)                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ StorageController (Upload/Download/List/Delete)      │   │
│  │ - UploadFile()                                       │   │
│  │ - GetFile()                                          │   │
│  │ - CreateUploadUrl()                                  │   │
│  │ - RemoveFiles()                                      │   │
│  │ - ListFiles()                                        │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ IApiStorageService Interface
                         │
┌────────────────────────▼────────────────────────────────────┐
│              Business Logic Layer (BLL)                      │
│  ┌──────────────────┐         ┌──────────────────┐        │
│  │ApiMinIoStorage   │         │ApiFireBaseStorage│        │
│  │     Service      │         │     Service       │        │
│  └──────────────────┘         └──────────────────┘        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Storage Provider SDK
                         │
┌────────────────────────▼────────────────────────────────────┐
│              External Storage Providers                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │   MinIO    │  │  Firebase   │  │   AWS S3   │          │
│  │  (S3 API)  │  │   Storage   │  │            │          │
│  └────────────┘  └────────────┘  └────────────┘          │
└─────────────────────────────────────────────────────────────┘
                         │
                         │ File Metadata
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   Database (SQL Server)                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ meta_info (File metadata)                            │   │
│  │ MAS_Request_Attach (Request attachments)            │   │
│  │ MAS_FeedbackAttach (Feedback attachments)           │   │
│  │ NotifyAttach (Notification attachments)              │   │
│  │ ImportFiles (Import file tracking)                  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 STORAGE SERVICE PROVIDERS

### 1. MinIO Storage

**Provider**: MinIO (S3-compatible object storage)

**Configuration** (`appsettings.json`):
```json
{
  "StorageService": {
    "Provider": "MinIo",
    "MinIo": {
      "Endpoint": "127.0.0.1:9000",
      "AccessKey": "your-access-key",
      "SecretKey": "your-secret-key",
      "BucketName": "bizzone-yamaha-dev",
      "Region": "us-east-1",
      "UseSSL": "false",
      "ProxyEndpoint": "http://localhost:3185/Storage/GetFile",
      "PrefixFolder": ""
    }
  }
}
```

**Features**:
- S3-compatible API
- Pre-signed URLs (upload/download)
- Metadata support (x-file-name, x-file-name-encode)
- Bucket và object management
- Proxy endpoint cho public access

**Scheme**: `minio://bucket-name/path/to/file`

---

### 2. Firebase Storage

**Provider**: Google Firebase Cloud Storage

**Configuration** (`appsettings.json`):
```json
{
  "StorageService": {
    "Provider": "Firebase",
    "Firebase": {
      "Endpoint": "firebase-storage-endpoint",
      "AccessKey": "service-account-key",
      "SecretKey": "service-account-secret",
      "BucketName": "your-firebase-bucket",
      "Region": "asia-southeast1",
      "UseSSL": "true",
      "ProxyEndpoint": "https://firebasestorage.googleapis.com",
      "PrefixFolder": ""
    }
  }
}
```

**Features**:
- Firebase Storage API
- CDN support
- Service account authentication
- Direct upload via Firebase SDK

---

### 3. Storage Service Interface

**Interface**: `IApiStorageService`

```csharp
public interface IApiStorageService
{
    string GetScheme { get; }
    
    // Upload file trực tiếp qua API
    Task<UploadResponse> UploadFile(IFormFile file, string path = null);
    
    // Lấy pre-signed URL để upload trực tiếp
    Task<string> GetPreSignedUploadUrl(UploadRequest request);
    
    // Lấy download URL (pre-signed)
    Task<string> GetDownloadUrl(string objectName, string bucketName = null);
    
    // Lấy thông tin file
    Task<FileStorageInfo> GetInfo(string objectName, string bucketName = null);
    
    // Xóa file
    Task Remove(List<string> files);
    
    // Xóa folder
    void RemoveFolder(string folder);
    
    // List files trong folder
    Task<IList<Item>> List(string folder, bool? recursive);
    
    // Map relative path to absolute URL
    void MapRelativePathToAbsolutePath(object obj);
}
```

---

## 📤 UPLOAD FILE

### 1. Upload Trực Tiếp Qua API

**Endpoint**: `POST /Storage/UploadFile`

**Description**: Upload file trực tiếp qua API Service. **Không khuyến khích** cho file lớn vì phụ thuộc vào bộ nhớ tạm của API Service.

**Request**:
```http
POST /api/v2/Storage/UploadFile?path=apartments/123
Content-Type: multipart/form-data

file: [binary data]
path: apartments/123 (optional)
```

**Response**:
```json
{
  "result": "success",
  "data": {
    "bucket": "bizzone-yamaha-dev",
    "objectName": "apartments/123/a1b2c3d4_file.pdf",
    "filePath": "minio://bizzone-yamaha-dev/apartments/123/a1b2c3d4_file.pdf",
    "fileName": "file.pdf",
    "size": 1024000,
    "contentType": "application/pdf",
    "url": "https://storage.example.com/download?token=...",
    "urlExpiration": 86400
  }
}
```

**Process Flow**:
```
1. Client gửi file qua multipart/form-data
   ↓
2. API nhận file từ IFormFile
   ↓
3. Validate file name
   ├─→ Check length <= 256 characters
   ├─→ Check special characters
   └─→ Remove non-ASCII characters
   ↓
4. Generate unique object name
   ├─→ GUID + normalized file name
   └─→ Format: {Guid}_{fileName}
   ↓
5. Upload to Storage Provider
   ├─→ Set Content-Type
   ├─→ Set metadata (x-file-name, x-file-name-encode)
   └─→ Upload stream
   ↓
6. Generate download URL (pre-signed)
   ↓
7. Return UploadResponse với:
   ├─→ FilePath (minio://bucket/object)
   ├─→ FileName (original name)
   ├─→ Size, ContentType
   └─→ Download URL
```

---

### 2. Upload Trực Tiếp (Pre-Signed URL)

**Endpoint**: `POST /Storage/CreateUploadUrl`

**Description**: Lấy pre-signed URL để upload trực tiếp từ client lên Storage Provider, **khuyến khích** cho file lớn.

**Request**:
```http
POST /api/v2/Storage/CreateUploadUrl
Content-Type: application/json

{
  "path": "apartments/123",
  "name": "document.pdf"
}
```

**Response**:
```json
{
  "https://storage.example.com/upload?token=...&expires=86400"
}
```

**Client Usage** (JavaScript):
```javascript
// 1. Lấy pre-signed URL
const response = await fetch('/api/v2/Storage/CreateUploadUrl', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    path: 'apartments/123',
    name: 'document.pdf'
  })
});
const uploadUrl = await response.text();

// 2. Upload trực tiếp lên Storage
const uploadResponse = await fetch(uploadUrl, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/pdf' },
  body: fileBlob
});

// 3. Lưu file path vào database
const filePath = `minio://bucket/${path}/${name}`;
await saveFileMetadata(filePath);
```

**Flow.js Example** (Angular):
```typescript
// Sử dụng Flow.js cho upload file lớn với chunking
import { Flow } from '@flowjs/ngx-flow';

const flow = new Flow({
  target: uploadUrl,
  chunkSize: 1024 * 1024, // 1MB chunks
  simultaneousUploads: 4
});

flow.upload();
```

---

### 3. File Name Processing

**Validation Rules**:
- Length: <= 256 characters
- Special characters: Chỉ cho phép ` `, `.`, `_`, `-`, `(`, `)`
- Non-ASCII: Tự động remove non-ASCII characters

**Normalization Process**:
```csharp
// 1. Trim whitespace
fileName = fileName.Trim();

// 2. Remove duplicate spaces → replace with underscore
fileName = RemoveDuplicateSpaces(fileName, "_");

// 3. Encode original name to Base64 (store in metadata)
fileNameBase64 = Convert.ToBase64String(UTF8.GetBytes(fileName));

// 4. Remove non-ASCII characters
fileName = RemoveNonAscii(fileName);

// 5. Generate unique object name
objectName = $"{Guid.NewGuid()}_{fileName}";
// Example: "a1b2c3d4-e5f6-7890-abcd-ef1234567890_document.pdf"
```

**Metadata**:
- `x-file-name`: Base64 encoded original file name
- `x-file-name-encode`: "base64"

---

## 📥 DOWNLOAD FILE

### 1. Download File (Stream)

**Endpoint**: `GET /Storage/GetFile?path={filePath}&action=default`

**Description**: Stream file từ Storage Provider về client.

**Request**:
```http
GET /api/v2/Storage/GetFile?path=minio://bucket/apartments/123/file.pdf&action=default
```

**Response**:
- Content-Type: File's content type
- Content-Disposition: attachment; filename="file.pdf"
- Binary stream

**Process Flow**:
```
1. Parse file path
   ├─→ Check scheme (minio:// or http://)
   ├─→ Extract bucket name
   └─→ Extract object name
   ↓
2. Get download URL từ Storage Provider
   ├─→ Pre-signed URL (expires in 24 hours)
   └─→ For MinIO: PresignedGetObjectAsync
   ↓
3. Redirect client đến download URL
   └─→ Return 302 Redirect
```

---

### 2. Get Download URL

**Endpoint**: `GET /Storage/GetFile?path={filePath}&action=url`

**Description**: Lấy download URL (pre-signed) để client tự download.

**Request**:
```http
GET /api/v2/Storage/GetFile?path=minio://bucket/apartments/123/file.pdf&action=url
```

**Response**:
```json
{
  "https://storage.example.com/download?token=...&expires=86400"
}
```

**Client Usage**:
```javascript
// Lấy download URL
const url = await fetch(`/api/v2/Storage/GetFile?path=${filePath}&action=url`)
  .then(r => r.text());

// Download file
window.open(url, '_blank');
```

---

### 3. Get File Info

**Endpoint**: `GET /Storage/GetFile?path={filePath}&action=info`

**Description**: Lấy thông tin chi tiết của file.

**Response**:
```json
{
  "result": "success",
  "data": {
    "objectName": "apartments/123/a1b2c3d4_file.pdf",
    "fileName": "file.pdf",
    "size": 1024000,
    "contentType": "application/pdf",
    "lastModified": "2024-01-15T10:30:00Z",
    "etag": "d41d8cd98f00b204e9800998ecf8427e",
    "url": "https://storage.example.com/download?token=...",
    "filePath": "minio://bucket/apartments/123/a1b2c3d4_file.pdf"
  }
}
```

---

## 🗄️ FILE METADATA TRONG DATABASE

### 1. Meta Info Table

**Table**: `meta_info`

**Purpose**: Lưu metadata của file để tracking và quản lý.

**Schema**:
```sql
CREATE TABLE [dbo].[meta_info] (
    [Oid]         UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [sourceOid]   UNIQUEIDENTIFIER NOT NULL,        -- ID của entity liên quan
    [source_type] NVARCHAR (50)    NULL,            -- Loại entity: request, feedback, notify, etc.
    [meta_title]  NVARCHAR (200)   NULL,            -- Tiêu đề file
    [meta_note]   NVARCHAR (400)   NULL,            -- Ghi chú
    [meta_type]   INT              NULL,             -- Loại meta
    [file_name]   NVARCHAR (200)   NULL,            -- Tên file gốc
    [file_size]   INT              NULL,             -- Kích thước file (bytes)
    [file_url]    NVARCHAR (500)   NULL,            -- URL/file path
    [file_type]   NVARCHAR (100)   NULL,            -- Loại file: pdf, jpg, etc.
    [objectName]  NVARCHAR (250)   NULL,            -- Object name trong storage
    [bucket]      NVARCHAR (250)   NULL,            -- Bucket name
    [created]     DATETIME         DEFAULT (getdate()) NULL,
    [created_by]  NVARCHAR (50)    NULL,
    [updated]     DATETIME         NULL,
    [updated_by]  NVARCHAR (50)    NULL,
    [path_temple] NVARCHAR (250)   NULL,            -- Template path
    CONSTRAINT [PK_meta_info] PRIMARY KEY CLUSTERED ([Oid] ASC)
);
```

**Usage Example**:
```csharp
// Lưu metadata sau khi upload
var metaInfo = new MetaInfo
{
    Oid = Guid.NewGuid(),
    sourceOid = requestId,           // Request ID
    source_type = "request",          // Loại entity
    file_name = uploadResponse.FileName,
    file_size = uploadResponse.Size,
    file_url = uploadResponse.FilePath, // minio://bucket/object
    file_type = uploadResponse.ContentType,
    objectName = uploadResponse.ObjectName,
    bucket = uploadResponse.Bucket,
    created_by = userId
};

await _metaRepository.SetInfo(metaInfo);
```

---

### 2. Request Attachments

**Table**: `MAS_Request_Attach`

**Purpose**: Lưu file đính kèm cho yêu cầu.

**Schema**:
```sql
CREATE TABLE [dbo].[MAS_Request_Attach] (
    [id]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [requestId]      BIGINT         NOT NULL,         -- ID yêu cầu
    [processId]      BIGINT         NULL,              -- ID quy trình (nếu có)
    [attachUrl]      NVARCHAR (455) NOT NULL,          -- File path hoặc URL
    [attachType]     NVARCHAR (50)  NULL,              -- Loại file: image, document, etc.
    [attachFileName] NVARCHAR (200) NULL,              -- Tên file gốc
    [createDt]       DATETIME       NULL
);
```

**Usage**:
```csharp
// Lưu attachment cho request
var attachment = new RequestAttachment
{
    RequestId = requestId,
    ProcessId = processId,
    AttachUrl = uploadResponse.FilePath,  // minio://bucket/object
    AttachType = uploadResponse.ContentType,
    AttachFileName = uploadResponse.FileName
};

await _requestRepository.SetRequestAttach(attachment);
```

---

### 3. Feedback Attachments

**Table**: `MAS_FeedbackAttach`

**Purpose**: Lưu file đính kèm cho phản ánh.

**Schema**: Tương tự `MAS_Request_Attach`, nhưng `feedbackId` thay vì `requestId`.

---

### 4. Notification Attachments

**Table**: `NotifyAttach`

**Purpose**: Lưu file đính kèm cho thông báo.

**User Defined Type**: `user_notify_attach`
```sql
CREATE TYPE [dbo].[user_notify_attach] AS TABLE (
    [n_id]        UNIQUEIDENTIFIER NULL,    -- Notification ID
    [attach_name] NVARCHAR (200)   NULL,    -- Tên file
    [attach_url]  NVARCHAR (MAX)   NOT NULL,-- File URL/path
    [attach_type] NVARCHAR (100)   NULL,    -- Loại file
    [attach_size] INT              NULL     -- Kích thước
);
```

---

## 🗑️ DELETE FILE

### 1. Delete Files

**Endpoint**: `POST /Storage/RemoveFiles`

**Description**: Xóa một hoặc nhiều file từ Storage Provider.

**Request**:
```http
POST /api/v2/Storage/RemoveFiles
Content-Type: application/json

[
  "minio://bucket/apartments/123/file1.pdf",
  "minio://bucket/apartments/123/file2.jpg"
]
```

**Response**:
```json
{
  "true"  // Success
}
```

**Process Flow**:
```
1. Parse file paths
   ├─→ Extract object names
   └─→ Validate scheme
   ↓
2. Delete từ Storage Provider
   ├─→ For MinIO: RemoveObjectsAsync (batch)
   └─→ Async processing với observable
   ↓
3. Log kết quả
   ├─→ Success: Log info
   └─→ Error: Log error
   ↓
4. Return result
```

**Note**: Việc xóa file trong database (metadata) phải được thực hiện riêng.

---

### 2. Delete Folder

**Endpoint**: `POST /Storage/RemoveFolder?folder={folderPath}`

**Description**: Xóa toàn bộ folder và các file bên trong.

**Request**:
```http
POST /api/v2/Storage/RemoveFolder?folder=apartments/123
```

**Response**:
```json
{
  "true"  // Success
}
```

**Process Flow**:
```
1. List tất cả objects trong folder
   ├─→ Recursive = true
   └─→ Prefix = folder path
   ↓
2. Delete từng object
   ├─→ Async processing
   └─→ Log từng file đã xóa
   ↓
3. Return result
```

---

## 📂 LIST FILES

### List Files in Folder

**Endpoint**: `GET /Storage/ListFiles?folder={folderPath}&recursive={true|false}`

**Description**: Liệt kê tất cả files trong folder.

**Request**:
```http
GET /api/v2/Storage/ListFiles?folder=apartments/123&recursive=true
```

**Response**:
```json
[
  {
    "key": "apartments/123/file1.pdf",
    "size": 1024000,
    "lastModified": "2024-01-15T10:30:00Z",
    "etag": "d41d8cd98f00b204e9800998ecf8427e",
    "isDir": false
  },
  {
    "key": "apartments/123/subfolder/",
    "isDir": true
  }
]
```

---

## 🎯 NGUYÊN TẮC TRIỂN KHAI

### 1. Storage Provider Selection

**Configuration-Based**:
- Provider được chọn dựa trên `appsettings.json`
- Switch provider dễ dàng bằng cách thay đổi config

**Implementation** (`ServiceCollectionExtensions.cs`):
```csharp
static void AddStorageService(this IServiceCollection services,
    IConfiguration configuration)
{
    var storageProvider = configuration["StorageService:Provider"];
    
    if (storageProvider == "MinIo")
    {
        services.AddSingleton<IApiStorageService, ApiMinIoStorageService>(sp =>
            new ApiMinIoStorageService(
                sp.GetRequiredService<ILogger<ApiMinIoStorageService>>(),
                new StorageConfig() { /* MinIO config */ }));
    }
    else if (storageProvider == "Firebase")
    {
        services.AddSingleton<IApiStorageService, ApiFireBaseStorageService>(sp =>
            new ApiFireBaseStorageService(
                sp.GetRequiredService<ILogger<ApiFireBaseStorageService>>(),
                new StorageConfig() { /* Firebase config */ }));
    }
}
```

**Best Practice**:
- Sử dụng **Singleton** lifecycle cho Storage Service
- Validate configuration khi startup
- Fallback to default provider nếu config không hợp lệ

---

### 2. File Path Format

**Scheme Format**: `{scheme}://{bucket}/{objectName}`

**Examples**:
```
minio://bizzone-yamaha-dev/apartments/123/a1b2c3d4_document.pdf
http://storage.example.com/files/document.pdf
```

**Parsing**:
```csharp
// Parse file path
if (path.StartsWith("http"))
{
    // Direct HTTP URL
    return Redirect(path);
}

if (path.StartsWith("minio://"))
{
    var uri = new Uri(path);
    var bucketName = uri.Host;
    var objectName = uri.AbsolutePath.TrimStart('/').UrlDecode();
    
    // Use bucketName and objectName to interact with storage
}
```

---

### 3. File Naming Convention

**Object Name Format**: `{PrefixFolder}/{path}/{Guid}_{NormalizedFileName}`

**Examples**:
```
// Path: apartments/123
// File: document.pdf
// Result: apartments/123/a1b2c3d4-e5f6-7890-abcd-ef1234567890_document.pdf

// Path: requests/456
// File: hình ảnh.jpg (non-ASCII)
// Result: requests/456/b2c3d4e5-f6g7-8901-bcde-f23456789012_hinh_anh.jpg
```

**Rules**:
- GUID đảm bảo uniqueness
- Normalized file name: ASCII only, spaces → underscores
- Original name lưu trong metadata (Base64)

---

### 4. Pre-Signed URL Expiration

**Default Expiration**: 24 hours (86400 seconds)

**Configuration**:
```csharp
private readonly int _defaultExpire = 60 * 60 * 24; // 24 hours
```

**Usage**:
- Download URL: Expires in 24 hours
- Upload URL: Expires in 24 hours
- Client phải re-generate URL nếu hết hạn

**Best Practice**:
- Không cache pre-signed URL quá lâu
- Re-generate URL khi cần thiết
- Validate URL expiration trước khi sử dụng

---

### 5. File Size Limits

**Recommended Limits**:
- **Small files (< 5MB)**: Upload trực tiếp qua API
- **Medium files (5MB - 100MB)**: Pre-signed URL upload
- **Large files (> 100MB)**: Chunked upload với Flow.js

**Configuration**:
```json
{
  "FileUpload": {
    "MaxFileSize": 104857600,  // 100MB (in bytes)
    "AllowedExtensions": [".pdf", ".jpg", ".png", ".doc", ".docx", ".xlsx"],
    "MaxFilesPerRequest": 10
  }
}
```

---

### 6. Content Type Validation

**Allowed Types**:
- Documents: `application/pdf`, `application/msword`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- Images: `image/jpeg`, `image/png`, `image/gif`
- Spreadsheets: `application/vnd.ms-excel`, `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

**Validation**:
```csharp
private static readonly string[] AllowedContentTypes = new[]
{
    "application/pdf",
    "image/jpeg",
    "image/png",
    // ...
};

public bool IsAllowedContentType(string contentType)
{
    return AllowedContentTypes.Contains(contentType);
}
```

---

## ✅ BEST PRACTICES

### 1. Upload Best Practices

**✅ DO**:
- Sử dụng pre-signed URL cho file > 5MB
- Validate file size và content type trước khi upload
- Normalize file name để tránh conflict
- Lưu metadata vào database sau khi upload thành công
- Generate unique object name (GUID + filename)

**❌ DON'T**:
- Không upload file quá lớn qua API Service (dễ quá tải server)
- Không trust file name từ client (có thể chứa path traversal)
- Không quên lưu metadata vào database
- Không hard-code storage configuration

---

### 2. Download Best Practices

**✅ DO**:
- Sử dụng pre-signed URL cho public access
- Validate user permissions trước khi download
- Set proper Content-Type và Content-Disposition headers
- Cache download URL trong thời gian ngắn (nếu hợp lệ)

**❌ DON'T**:
- Không expose direct storage credentials
- Không cache pre-signed URL quá lâu (expires)
- Không stream file lớn qua API Service (dùng redirect)

---

### 3. Security Best Practices

**✅ DO**:
- Validate file extensions và content types
- Sanitize file names (remove special characters, path traversal)
- Implement access control (user permissions)
- Use HTTPS for file transfer
- Validate file size limits

**❌ DON'T**:
- Không trust file extension từ client
- Không cho phép upload executable files (.exe, .bat, .sh)
- Không expose storage credentials
- Không allow path traversal (../, ..\\)

---

### 4. Error Handling

**Common Errors**:
```csharp
try
{
    var result = await _storageService.UploadFile(file, path);
    return GetResponse(ApiResult.Success, result);
}
catch (FileNotFoundException ex)
{
    _logger.LogError(ex, "File not found: {FileName}", file.FileName);
    return GetResponse<UploadResponse>(ApiResult.Fail, null, "File not found");
}
catch (UnauthorizedAccessException ex)
{
    _logger.LogError(ex, "Unauthorized access");
    return GetResponse<UploadResponse>(ApiResult.Fail, null, "Unauthorized");
}
catch (Exception ex)
{
    _logger.LogError(ex, "Upload failed: {FileName}", file.FileName);
    return GetResponse<UploadResponse>(ApiResult.Fail, null, ex.Message);
}
```

---

## 📊 FILE USAGE PATTERNS

### 1. Request Attachments

**Pattern**: Upload file đính kèm cho yêu cầu

```csharp
// 1. Upload file
var uploadResult = await _storageService.UploadFile(file, $"requests/{requestId}");

// 2. Lưu attachment
var attachment = new RequestAttachment
{
    RequestId = requestId,
    AttachUrl = uploadResult.FilePath,
    AttachType = uploadResult.ContentType,
    AttachFileName = uploadResult.FileName
};

await _requestRepository.SetRequestAttach(attachment);
```

---

### 2. Import Files

**Pattern**: Upload file Excel để import dữ liệu

```csharp
// 1. Upload import file
var uploadResult = await _storageService.UploadFile(file, $"imports/{userId}");

// 2. Lưu metadata
var metaInfo = new MetaInfo
{
    sourceOid = importJobId,
    source_type = "import",
    file_name = uploadResult.FileName,
    file_url = uploadResult.FilePath,
    file_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
};

await _metaRepository.SetInfo(metaInfo);

// 3. Process import
await ProcessImport(uploadResult.FilePath);
```

---

### 3. Notification Attachments

**Pattern**: Đính kèm file trong thông báo

```csharp
// 1. Upload file
var uploadResult = await _storageService.UploadFile(file, $"notifications/{notificationId}");

// 2. Lưu attachment
var attach = new NotifyAttachment
{
    NId = notificationId,
    AttachName = uploadResult.FileName,
    AttachUrl = uploadResult.FilePath,
    AttachType = uploadResult.ContentType,
    AttachSize = (int)uploadResult.Size
};

await _notifyRepository.SetNotifyAttach(attach);
```

---

## 🔄 FILE LIFECYCLE

### Lifecycle States

```
Upload Request
  ↓
Validation (Size, Type, Name)
  ↓
Upload to Storage Provider
  ├─→ Success → Save Metadata → Return Response
  └─→ Failure → Return Error
  ↓
File Stored in Storage
  ├─→ Accessible via pre-signed URL
  └─→ Metadata in database
  ↓
[Use File]
  ├─→ Download
  ├─→ Share
  └─→ View
  ↓
[Delete Request]
  ├─→ Delete from Storage Provider
  └─→ Delete Metadata from Database
  ↓
File Deleted
```

---

## 📝 SUMMARY

### Key Points

1. **Multi-Provider Support**: MinIO, Firebase, AWS S3 (configurable)
2. **Two Upload Methods**: Direct API upload (small files), Pre-signed URL (large files)
3. **File Metadata**: Lưu trong database (`meta_info`, attachment tables)
4. **File Path Format**: `{scheme}://{bucket}/{objectName}`
5. **Pre-signed URLs**: Expires in 24 hours
6. **Security**: Validate file type, size, name sanitization
7. **Best Practices**: Use pre-signed URLs for large files, validate everything

### File Management Checklist

- ✅ Validate file size và content type
- ✅ Sanitize file name (normalize, remove non-ASCII)
- ✅ Generate unique object name (GUID + filename)
- ✅ Upload to storage provider
- ✅ Save metadata to database
- ✅ Return file path (scheme://bucket/object)
- ✅ Generate pre-signed URL cho download
- ✅ Implement access control
- ✅ Handle errors properly
- ✅ Log operations

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0



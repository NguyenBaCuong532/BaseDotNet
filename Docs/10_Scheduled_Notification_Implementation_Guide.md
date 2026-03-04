# Hướng Dẫn Triển Khai Scheduled Notification Service

## 📋 Tổng Quan

Tài liệu này hướng dẫn các cách triển khai trigger/scheduled job để tự động xử lý thông báo đã đến lịch gửi qua Kafka.

---

## 🎯 Các Phương Pháp Triển Khai

### 1. Background Service (Đã Triển Khai - Khuyến Nghị) ✅

**Ưu điểm:**
- ✅ Đơn giản, không cần thêm package
- ✅ Tự động chạy khi ứng dụng khởi động
- ✅ Tích hợp sẵn với .NET Core
- ✅ Dễ quản lý và monitor

**Cách hoạt động:**
- Service chạy nền trong suốt vòng đời của ứng dụng
- Tự động kiểm tra và xử lý thông báo mỗi 1 phút
- Sử dụng `IServiceProvider` để resolve dependencies

**File đã tạo:**
- `UNI.RESIDENT.API/BackgroundServices/ScheduledNotificationBackgroundService.cs`
- Đã đăng ký trong `Startup.cs`

**Cấu hình:**
```csharp
// Trong ScheduledNotificationBackgroundService.cs
private readonly TimeSpan _checkInterval = TimeSpan.FromMinutes(1); // Thay đổi interval tại đây
private readonly int _maxRecordsPerRun = 100; // Số lượng thông báo tối đa mỗi lần
```

**Cách sử dụng:**
1. Service tự động chạy khi ứng dụng khởi động
2. Không cần cấu hình thêm
3. Kiểm tra logs để theo dõi hoạt động

**Tắt/Bật Service:**
- Comment/Uncomment dòng trong `Startup.cs`:
```csharp
// services.AddHostedService<ScheduledNotificationBackgroundService>();
```

---

### 2. SQL Server Agent Job

**Ưu điểm:**
- ✅ Chạy độc lập với ứng dụng
- ✅ Có thể schedule linh hoạt
- ✅ Quản lý qua SQL Server Management Studio

**Cách triển khai:**

#### Bước 1: Tạo Stored Procedure gọi API

```sql
-- Tạo stored procedure để gọi API endpoint
CREATE PROCEDURE [dbo].[sp_res_notify_scheduled_trigger]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @url NVARCHAR(500) = 'http://your-api-url/api/v1/task/ProcessScheduledNotifications?maxRecords=100';
    DECLARE @apiKey NVARCHAR(100) = 'your-api-key'; -- API key từ appsettings
    
    -- Sử dụng SQL Server để gọi HTTP endpoint
    -- Cần enable OLE Automation Procedures
    DECLARE @Object AS INT;
    DECLARE @ResponseText AS VARCHAR(8000);
    
    EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
    EXEC sp_OAMethod @Object, 'open', NULL, 'POST', @url, 'false';
    EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
    EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'X-API-Key', @apiKey;
    EXEC sp_OAMethod @Object, 'send', NULL, '';
    EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
    
    EXEC sp_OADestroy @Object;
    
    SELECT @ResponseText AS Response;
END
GO
```

#### Bước 2: Tạo SQL Server Agent Job

```sql
-- Tạo SQL Server Agent Job
USE msdb;
GO

EXEC dbo.sp_add_job
    @job_name = N'Process Scheduled Notifications';

EXEC dbo.sp_add_jobstep
    @job_name = N'Process Scheduled Notifications',
    @step_name = N'Call API to process notifications',
    @subsystem = N'TSQL',
    @command = N'EXEC [dbSHome].[dbo].[sp_res_notify_scheduled_trigger]';

EXEC dbo.sp_add_schedule
    @schedule_name = N'Every 1 Minute',
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @freq_subday_type = 4, -- Minutes
    @freq_subday_interval = 1,
    @active_start_time = 000000; -- 00:00:00

EXEC dbo.sp_attach_schedule
    @job_name = N'Process Scheduled Notifications',
    @schedule_name = N'Every 1 Minute';

EXEC dbo.sp_add_jobserver
    @job_name = N'Process Scheduled Notifications';
GO
```

**Lưu ý:**
- Cần enable OLE Automation Procedures trong SQL Server
- Cần cấu hình API key và URL chính xác
- Có thể sử dụng PowerShell script thay vì OLE Automation

---

### 3. Windows Task Scheduler

**Ưu điểm:**
- ✅ Chạy độc lập với ứng dụng
- ✅ Dễ cấu hình qua GUI
- ✅ Có thể chạy trên máy khác

**Cách triển khai:**

#### Bước 1: Tạo PowerShell Script

Tạo file `ProcessScheduledNotifications.ps1`:

```powershell
# ProcessScheduledNotifications.ps1
$apiUrl = "http://your-api-url/api/v1/task/ProcessScheduledNotifications?maxRecords=100"
$apiKey = "your-api-key"

$headers = @{
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers
    Write-Host "Success: $($response | ConvertTo-Json)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
```

#### Bước 2: Tạo Task trong Task Scheduler

1. Mở **Task Scheduler** (taskschd.msc)
2. Click **Create Basic Task**
3. Đặt tên: "Process Scheduled Notifications"
4. Trigger: **Daily** hoặc **When the computer starts**
5. Action: **Start a program**
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "C:\Path\To\ProcessScheduledNotifications.ps1"`
6. Chọn **Run whether user is logged on or not**
7. Hoàn tất

**Lưu ý:**
- Cần cấu hình user account có quyền chạy task
- Có thể set trigger để chạy mỗi phút

---

### 4. Hangfire (Nếu muốn có Dashboard)

**Ưu điểm:**
- ✅ Có web dashboard để quản lý
- ✅ Retry mechanism tự động
- ✅ Lịch sử job chi tiết
- ✅ Hỗ trợ distributed processing

**Cách triển khai:**

#### Bước 1: Cài đặt Package

```bash
dotnet add UNI.RESIDENT.API package Hangfire.Core
dotnet add UNI.RESIDENT.API package Hangfire.AspNetCore
dotnet add UNI.RESIDENT.API package Hangfire.SqlServer
```

#### Bước 2: Cấu hình trong Startup.cs

```csharp
// Thêm vào ConfigureServices
services.AddHangfire(config => config
    .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
    .UseSimpleAssemblyNameTypeSerializer()
    .UseRecommendedSerializerSettings()
    .UseSqlServerStorage(Configuration.GetConnectionString("SHomeConnection"), new SqlServerStorageOptions
    {
        CommandBatchMaxTimeout = TimeSpan.FromMinutes(5),
        SlidingInvisibilityTimeout = TimeSpan.FromMinutes(5),
        QueuePollInterval = TimeSpan.Zero,
        UseRecommendedIsolationLevel = true,
        DisableGlobalLocks = true
    }));

services.AddHangfireServer();

// Thêm vào Configure
app.UseHangfireDashboard("/hangfire", new DashboardOptions
{
    Authorization = new[] { new HangfireAuthorizationFilter() }
});

// Tạo recurring job
RecurringJob.AddOrUpdate(
    "process-scheduled-notifications",
    () => ProcessScheduledNotifications(),
    "*/1 * * * *", // Chạy mỗi 1 phút (Cron expression)
    TimeZoneInfo.Local);
```

#### Bước 3: Tạo Job Method

```csharp
public class NotificationJobService
{
    private readonly INotifyService _notifyService;
    private readonly ILogger<NotificationJobService> _logger;

    public NotificationJobService(INotifyService notifyService, ILogger<NotificationJobService> logger)
    {
        _notifyService = notifyService;
        _logger = logger;
    }

    public async Task ProcessScheduledNotifications()
    {
        var result = await _notifyService.ProcessScheduledNotifications(100);
        _logger.LogInformation("Processed {Count} notifications", result.Data);
    }
}
```

**Truy cập Dashboard:**
- URL: `http://your-api-url/hangfire`

---

### 5. Quartz.NET

**Ưu điểm:**
- ✅ Mạnh mẽ, linh hoạt
- ✅ Hỗ trợ Cron expressions
- ✅ Clustering support

**Cách triển khai:**

#### Bước 1: Cài đặt Package

```bash
dotnet add UNI.RESIDENT.API package Quartz
dotnet add UNI.RESIDENT.API package Quartz.Extensions.Hosting
```

#### Bước 2: Tạo Job Class

```csharp
public class ScheduledNotificationJob : IJob
{
    private readonly INotifyService _notifyService;
    private readonly ILogger<ScheduledNotificationJob> _logger;

    public ScheduledNotificationJob(INotifyService notifyService, ILogger<ScheduledNotificationJob> logger)
    {
        _notifyService = notifyService;
        _logger = logger;
    }

    public async Task Execute(IJobExecutionContext context)
    {
        var result = await _notifyService.ProcessScheduledNotifications(100);
        _logger.LogInformation("Processed {Count} notifications", result.Data);
    }
}
```

#### Bước 3: Cấu hình trong Startup.cs

```csharp
services.AddQuartz(q =>
{
    var jobKey = new JobKey("ScheduledNotificationJob");
    q.AddJob<ScheduledNotificationJob>(opts => opts.WithIdentity(jobKey));
    q.AddTrigger(opts => opts
        .ForJob(jobKey)
        .WithIdentity("ScheduledNotificationJob-trigger")
        .WithCronSchedule("0 * * * * ?")); // Mỗi phút
});

services.AddQuartzHostedService(q => q.WaitForJobsToComplete = true);
```

---

## 🔧 Cấu Hình Nâng Cao

### Thay Đổi Interval trong Background Service

Mở file `ScheduledNotificationBackgroundService.cs` và thay đổi:

```csharp
// Kiểm tra mỗi 5 phút
private readonly TimeSpan _checkInterval = TimeSpan.FromMinutes(5);

// Hoặc mỗi 30 giây
private readonly TimeSpan _checkInterval = TimeSpan.FromSeconds(30);
```

### Thay Đổi Số Lượng Thông Báo Mỗi Lần

```csharp
// Xử lý 200 thông báo mỗi lần
private readonly int _maxRecordsPerRun = 200;
```

### Thêm Cấu Hình từ appsettings.json

Thêm vào `appsettings.json`:

```json
{
  "ScheduledNotification": {
    "CheckIntervalMinutes": 1,
    "MaxRecordsPerRun": 100,
    "Enabled": true
  }
}
```

Cập nhật `ScheduledNotificationBackgroundService.cs`:

```csharp
public class ScheduledNotificationBackgroundService : BackgroundService
{
    private readonly IConfiguration _configuration;
    
    public ScheduledNotificationBackgroundService(
        ILogger<ScheduledNotificationBackgroundService> logger,
        IServiceProvider serviceProvider,
        IConfiguration configuration)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
        _configuration = configuration;
        
        var intervalMinutes = _configuration.GetValue<int>("ScheduledNotification:CheckIntervalMinutes", 1);
        _checkInterval = TimeSpan.FromMinutes(intervalMinutes);
        _maxRecordsPerRun = _configuration.GetValue<int>("ScheduledNotification:MaxRecordsPerRun", 100);
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var enabled = _configuration.GetValue<bool>("ScheduledNotification:Enabled", true);
        if (!enabled)
        {
            _logger.LogInformation("ScheduledNotificationBackgroundService đã bị tắt trong cấu hình");
            return;
        }
        
        // ... rest of code
    }
}
```

---

## 📊 Monitoring & Logging

### Xem Logs

Service tự động log các hoạt động:
- Khởi động/dừng service
- Số lượng thông báo đã xử lý
- Lỗi nếu có

Xem logs trong:
- File logs: `LogServers/log-{Date}.txt`
- Console output
- Elastic APM (nếu đã cấu hình)

### Kiểm Tra Hoạt Động

1. **Kiểm tra logs:**
```bash
tail -f LogServers/log-2025-01-XX.txt | grep ScheduledNotification
```

2. **Gọi API thủ công để test:**
```bash
POST /api/v1/task/ProcessScheduledNotifications?maxRecords=10
```

3. **Kiểm tra database:**
```sql
-- Xem thông báo đã đến lịch
SELECT * FROM NotifyInbox 
WHERE Schedule <= GETDATE() 
AND isPublish = 1
ORDER BY Schedule ASC
```

---

## 🚀 Khuyến Nghị

**Cho Production:**
- ✅ Sử dụng **Background Service** (đã triển khai)
- ✅ Cấu hình interval phù hợp (1-5 phút)
- ✅ Monitor logs thường xuyên
- ✅ Có backup plan (SQL Agent Job hoặc Task Scheduler)

**Cho Development:**
- ✅ Sử dụng **Background Service** với interval ngắn hơn (30 giây)
- ✅ Test bằng cách gọi API thủ công

**Cho High Availability:**
- ✅ Sử dụng **Hangfire** với SQL Server storage
- ✅ Hoặc **Quartz.NET** với clustering

---

## ❓ Troubleshooting

### Service không chạy
- Kiểm tra logs để xem có lỗi khởi động không
- Kiểm tra service đã được đăng ký trong `Startup.cs` chưa
- Kiểm tra application đang chạy

### Thông báo không được gửi
- Kiểm tra Kafka connection
- Kiểm tra stored procedure có trả về dữ liệu không
- Kiểm tra logs để xem có lỗi gì

### Service chạy quá chậm
- Giảm `maxRecordsPerRun`
- Tăng `checkInterval` để giảm tần suất
- Kiểm tra performance của stored procedure

---

**Tài liệu được cập nhật:** 2025-01-XX  
**Phiên bản:** 1.0.0


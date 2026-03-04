using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Notify;

namespace UNI.Resident.API.BackgroundServices
{
    /// <summary>
    /// Background Service để tự động xử lý thông báo đã đến lịch gửi
    /// Chạy định kỳ theo cấu hình để kiểm tra và gửi thông báo
    /// Cấu hình trong appsettings.json: ScheduledNotification
    /// </summary>
    public class ScheduledNotificationBackgroundService : BackgroundService
    {
        private readonly ILogger<ScheduledNotificationBackgroundService> _logger;
        private readonly IServiceProvider _serviceProvider;
        private readonly IConfiguration _configuration;
        private readonly TimeSpan _checkInterval;
        private readonly int _maxRecordsPerRun;
        private readonly bool _enabled;
        private readonly string _logLevel;

        public ScheduledNotificationBackgroundService(
            ILogger<ScheduledNotificationBackgroundService> logger,
            IServiceProvider serviceProvider,
            IConfiguration configuration)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
            _configuration = configuration;

            // Đọc cấu hình từ appsettings.json
            _enabled = _configuration.GetValue<bool>("ScheduledNotification:Enabled", true);
            var checkIntervalMinutes = _configuration.GetValue<int>("ScheduledNotification:CheckIntervalMinutes", 1);
            _checkInterval = TimeSpan.FromMinutes(checkIntervalMinutes);
            _maxRecordsPerRun = _configuration.GetValue<int>("ScheduledNotification:MaxRecordsPerRun", 100);
            _logLevel = _configuration.GetValue<string>("ScheduledNotification:LogLevel", "Information");

            _logger.LogInformation(
                "ScheduledNotificationBackgroundService được khởi tạo với cấu hình: Enabled={Enabled}, Interval={Interval} phút, MaxRecords={MaxRecords}, LogLevel={LogLevel}",
                _enabled, checkIntervalMinutes, _maxRecordsPerRun, _logLevel);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // Kiểm tra nếu service bị tắt trong cấu hình
            if (!_enabled)
            {
                _logger.LogWarning("ScheduledNotificationBackgroundService đã bị tắt trong cấu hình (ScheduledNotification:Enabled = false)");
                return;
            }

            _logger.LogInformation(
                "ScheduledNotificationBackgroundService đã khởi động. Sẽ kiểm tra thông báo mỗi {Interval} phút, tối đa {MaxRecords} thông báo mỗi lần",
                _checkInterval.TotalMinutes, _maxRecordsPerRun);

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessScheduledNotifications(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Lỗi trong ScheduledNotificationBackgroundService");
                }

                // Đợi đến lần kiểm tra tiếp theo
                await Task.Delay(_checkInterval, stoppingToken);
            }

            _logger.LogInformation("ScheduledNotificationBackgroundService đã dừng");
        }

        private async Task ProcessScheduledNotifications(CancellationToken cancellationToken)
        {
            // Tạo scope để resolve service từ DI container
            using (var scope = _serviceProvider.CreateScope())
            {
                var notifyService = scope.ServiceProvider.GetRequiredService<INotifyService>();

                try
                {
                    // Log theo level được cấu hình
                    if (_logLevel == "Debug" || _logLevel == "Information")
                    {
                        _logger.LogDebug("Bắt đầu kiểm tra thông báo đã đến lịch gửi...");
                    }

                    var result = await notifyService.ProcessScheduledNotifications(_maxRecordsPerRun);

                    if (result.Result == ApiResult.Success)
                    {
                        if (result.Data > 0)
                        {
                            _logger.LogInformation(
                                "Đã xử lý thành công {Count} thông báo đã đến lịch gửi (MaxRecords: {MaxRecords})",
                                result.Data, _maxRecordsPerRun);
                        }
                        else
                        {
                            // Chỉ log debug nếu không có thông báo
                            if (_logLevel == "Debug")
                            {
                                _logger.LogDebug("Không có thông báo nào cần xử lý");
                            }
                        }
                    }
                    else
                    {
                        _logger.LogWarning("Lỗi khi xử lý thông báo đã đến lịch gửi: {Error}", result.Error);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Lỗi khi xử lý thông báo đã đến lịch gửi trong Background Service");
                }
            }
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("ScheduledNotificationBackgroundService đang dừng...");
            await base.StopAsync(cancellationToken);
        }
    }
}


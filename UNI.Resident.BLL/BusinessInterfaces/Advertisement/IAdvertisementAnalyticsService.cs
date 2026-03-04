using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.BLL.BusinessInterfaces.Advertisement
{
    public interface IAdvertisementAnalyticsService
    {
        // CMS Pattern APIs
        Task<CommonViewInfo> GetFilter(string filterName);
        Task<List<AdvertisementAnalytics>> GetPage(AdvertisementAnalyticsFilter filter);
        Task<AdvertisementAnalytics> GetInfo(Guid id);

        // Analytics specific methods
        Task<Dictionary<string, int>> GetAnalyticsByAction(Guid advertisementId, DateTime? fromDate, DateTime? toDate);
        Task<Dictionary<string, int>> GetAnalyticsByDeviceType(Guid advertisementId, DateTime? fromDate, DateTime? toDate);
        Task<Dictionary<string, int>> GetAnalyticsByPlatform(Guid advertisementId, DateTime? fromDate, DateTime? toDate);
        Task<List<AdvertisementAnalytics>> GetHourlyAnalytics(Guid advertisementId, DateTime date);
        Task<List<AdvertisementAnalytics>> GetDailyAnalytics(Guid advertisementId, DateTime fromDate, DateTime toDate);
        Task<List<AdvertisementAnalytics>> GetUserClickHistory(string userId, int limit = 50);
    }
}
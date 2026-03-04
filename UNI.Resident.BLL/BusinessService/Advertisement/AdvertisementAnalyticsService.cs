using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Advertisement;
using UNI.Resident.DAL.Interfaces.Advertisement;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.BLL.BusinessService.Advertisement
{
    public class AdvertisementAnalyticsService : IAdvertisementAnalyticsService
    {
        private readonly IAdvertisementAnalyticsRepository _analyticsRepository;

        public AdvertisementAnalyticsService(IAdvertisementAnalyticsRepository analyticsRepository)
        {
            _analyticsRepository = analyticsRepository ?? throw new ArgumentNullException(nameof(analyticsRepository));
        }

        // CMS Pattern APIs
        public async Task<CommonViewInfo> GetFilter(string filterName)
        {
            return await _analyticsRepository.GetFilter(filterName);
        }

        public async Task<List<AdvertisementAnalytics>> GetPage(AdvertisementAnalyticsFilter filter)
        {
            return await _analyticsRepository.GetPage(filter);
        }

        public async Task<AdvertisementAnalytics> GetInfo(Guid id)
        {
            return await _analyticsRepository.GetInfo(id);
        }

        // Analytics specific methods
        public async Task<Dictionary<string, int>> GetAnalyticsByAction(Guid advertisementId, DateTime? fromDate, DateTime? toDate)
        {
            return await _analyticsRepository.GetAnalyticsByAction(advertisementId, fromDate, toDate);
        }

        public async Task<Dictionary<string, int>> GetAnalyticsByDeviceType(Guid advertisementId, DateTime? fromDate, DateTime? toDate)
        {
            return await _analyticsRepository.GetAnalyticsByDeviceType(advertisementId, fromDate, toDate);
        }

        public async Task<Dictionary<string, int>> GetAnalyticsByPlatform(Guid advertisementId, DateTime? fromDate, DateTime? toDate)
        {
            return await _analyticsRepository.GetAnalyticsByPlatform(advertisementId, fromDate, toDate);
        }

        public async Task<List<AdvertisementAnalytics>> GetHourlyAnalytics(Guid advertisementId, DateTime date)
        {
            return await _analyticsRepository.GetHourlyAnalytics(advertisementId, date);
        }

        public async Task<List<AdvertisementAnalytics>> GetDailyAnalytics(Guid advertisementId, DateTime fromDate, DateTime toDate)
        {
            if (fromDate > toDate)
            {
                throw new ArgumentException("From date must be before to date");
            }

            // Limit the date range to prevent performance issues
            var maxDays = 90;
            if ((toDate - fromDate).TotalDays > maxDays)
            {
                throw new ArgumentException($"Date range cannot exceed {maxDays} days");
            }

            return await _analyticsRepository.GetDailyAnalytics(advertisementId, fromDate, toDate);
        }

        public async Task<List<AdvertisementAnalytics>> GetUserClickHistory(string userId, int limit = 50)
        {
            if (!Guid.TryParse(userId, out var customerGuid))
            {
                throw new ArgumentException("Invalid user ID format", nameof(userId));
            }

            return await _analyticsRepository.GetUserClickHistory(customerGuid, limit);
        }
    }
}
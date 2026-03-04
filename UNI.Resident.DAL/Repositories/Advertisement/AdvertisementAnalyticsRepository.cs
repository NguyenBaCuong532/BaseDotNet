using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Advertisement;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.DAL.Repositories.Advertisement
{
    public class AdvertisementAnalyticsRepository : UniBaseRepository, IAdvertisementAnalyticsRepository
    {
        public AdvertisementAnalyticsRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        // CMS Pattern APIs
        public async Task<CommonViewInfo> GetFilter(string filterName)
        {
            const string storedProcedure = "sp_common_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { tableKey = filterName });
        }

        public async Task<List<AdvertisementAnalytics>> GetPage(AdvertisementAnalyticsFilter filter)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_page";
            return await GetListAsync<AdvertisementAnalytics>(storedProcedure, param =>
            {
                param.Add("@advertisement_id", filter.AdvertisementId);
                param.Add("@action", filter.Action);
                param.Add("@from_date", filter.FromDate);
                param.Add("@to_date", filter.ToDate);
                param.Add("@device_type", filter.DeviceType);
                param.Add("@platform", filter.Platform);
                param.Add("@filter", filter.filter);
                return param;
            });
        }

        public async Task<AdvertisementAnalytics> GetInfo(Guid id)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_info";
            return await GetFieldsAsync<AdvertisementAnalytics>(storedProcedure, new { id });
        }

        // Analytics specific methods
        public async Task<Dictionary<string, int>> GetAnalyticsByAction(Guid advertisementId, DateTime? fromDate, DateTime? toDate)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_by_action";
            var result = await GetListAsync<dynamic>(storedProcedure, new { advertisement_id = advertisementId, from_date = fromDate, to_date = toDate });

            var dictionary = new Dictionary<string, int>();
            foreach (var item in result)
            {
                dictionary.Add(item.action, item.count);
            }
            return dictionary;
        }

        public async Task<Dictionary<string, int>> GetAnalyticsByDeviceType(Guid advertisementId, DateTime? fromDate, DateTime? toDate)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_by_device";
            var result = await GetListAsync<dynamic>(storedProcedure, new { advertisement_id = advertisementId, from_date = fromDate, to_date = toDate });

            var dictionary = new Dictionary<string, int>();
            foreach (var item in result)
            {
                dictionary.Add(item.device_type ?? "Unknown", item.count);
            }
            return dictionary;
        }

        public async Task<Dictionary<string, int>> GetAnalyticsByPlatform(Guid advertisementId, DateTime? fromDate, DateTime? toDate)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_by_platform";
            var result = await GetListAsync<dynamic>(storedProcedure, new { advertisement_id = advertisementId, from_date = fromDate, to_date = toDate });

            var dictionary = new Dictionary<string, int>();
            foreach (var item in result)
            {
                dictionary.Add(item.platform ?? "Unknown", item.count);
            }
            return dictionary;
        }

        public async Task<List<AdvertisementAnalytics>> GetHourlyAnalytics(Guid advertisementId, DateTime date)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_hourly";
            return await GetListAsync<AdvertisementAnalytics>(storedProcedure, new { advertisement_id = advertisementId, date });
        }

        public async Task<List<AdvertisementAnalytics>> GetDailyAnalytics(Guid advertisementId, DateTime fromDate, DateTime toDate)
        {
            const string storedProcedure = "sp_res_advertisement_analytics_daily";
            return await GetListAsync<AdvertisementAnalytics>(storedProcedure, new { advertisement_id = advertisementId, from_date = fromDate, to_date = toDate });
        }

        public async Task<List<AdvertisementAnalytics>> GetUserClickHistory(Guid customerId, int limit = 50)
        {
            const string storedProcedure = "sp_res_advertisement_user_click_history";
            return await GetListAsync<AdvertisementAnalytics>(storedProcedure, new { customer_id = customerId, limit });
        }
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.BLL.BusinessInterfaces.Advertisement
{
    public interface IAdvertisementService
    {
        // CMS Pattern APIs
        Task<CommonViewInfo> GetFilter(string filterName);
        Task<List<AdvertisementInfo>> GetPage(AdvertisementFilter filter);
        Task<AdvertisementInfo> GetInfo(Guid id);
        Task<BaseValidate> SetInfo(AdvertisementCreateDto dto, string userId);
        Task<BaseValidate> SetInfo(AdvertisementUpdateDto dto, string userId);
        Task<BaseValidate> DelInfo(Guid id, string userId);

        // Additional methods for statistics
        Task<List<AdvertisementStatsDto>> GetAdvertisementStats(DateTime? fromDate, DateTime? toDate);
    }
}
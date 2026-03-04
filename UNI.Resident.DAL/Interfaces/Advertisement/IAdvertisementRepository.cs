using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.DAL.Interfaces.Advertisement
{
    public interface IAdvertisementRepository
    {
        // CMS Pattern APIs
        Task<CommonViewInfo> GetFilter(string filterName);
        Task<List<AdvertisementInfo>> GetPage(AdvertisementFilter filter);
        Task<AdvertisementInfo> GetInfo(Guid id);
        Task<BaseValidate> SetInfo(AdvertisementCreateDto dto, Guid userId);
        Task<BaseValidate> SetInfo(AdvertisementUpdateDto dto, Guid userId);
        Task<BaseValidate> DelInfo(Guid id, Guid userId);

        // Additional APIs for statistics and analytics
        Task<List<AdvertisementStatsDto>> GetAdvertisementStats(DateTime? fromDate, DateTime? toDate);
        Task<BaseValidate> UpdateViewCount(Guid id);
        Task<BaseValidate> UpdateClickCount(Guid id);
    }
}
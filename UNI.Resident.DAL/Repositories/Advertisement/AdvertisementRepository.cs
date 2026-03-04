using DocumentFormat.OpenXml.Office2016.Drawing.Command;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Advertisement;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.DAL.Repositories.Advertisement
{
    public class AdvertisementRepository : UniBaseRepository, IAdvertisementRepository
    {
        public AdvertisementRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        // CMS Pattern APIs
        public async Task<CommonViewInfo> GetFilter(string filterName)
        {
            const string storedProcedure = "sp_common_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { tableKey = filterName });
        }

        public async Task<List<AdvertisementInfo>> GetPage(AdvertisementFilter filter)
        {
            const string storedProcedure = "sp_res_advertisement_page";
            return await GetListAsync<AdvertisementInfo>(storedProcedure, param =>
            {
                param.Add("@title", filter.Title);
                param.Add("@company_name", filter.CompanyName);
                param.Add("@is_active", filter.IsActive);
                param.Add("@start_date", filter.StartDate);
                param.Add("@end_date", filter.EndDate);
                param.Add("@position", filter.Position);
                param.Add("@filter", filter.filter);
                return param;
            });
        }

        public async Task<AdvertisementInfo> GetInfo(Guid id)
        {
            const string storedProcedure = "sp_res_advertisement_info";
            return await GetFieldsAsync<AdvertisementInfo>(storedProcedure, new { id });
        }

        public async Task<BaseValidate> SetInfo(AdvertisementCreateDto dto, Guid userId)
        {
            const string storedProcedure = "sp_res_advertisement_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("@id", Guid.Empty); // New record
                param.Add("@title", dto.Title);
                param.Add("@description", dto.Description);
                param.Add("@image_url", dto.ImageUrl);
                param.Add("@link_url", dto.LinkUrl);
                param.Add("@position", dto.Position);
                param.Add("@priority", dto.Priority);
                param.Add("@start_date", dto.StartDate);
                param.Add("@end_date", dto.EndDate);
                param.Add("@is_active", dto.IsActive);
                param.Add("@company_name", dto.CompanyName);
                param.Add("@company_contact", dto.CompanyContact);
                param.Add("@company_phone", dto.CompanyPhone);
                param.Add("@company_email", dto.CompanyEmail);
                param.Add("@user_id", userId);
                return param;
            });
        }

        public async Task<BaseValidate> SetInfo(AdvertisementUpdateDto dto, Guid userId)
        {
            const string storedProcedure = "sp_res_advertisement_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("@id", dto.Id);
                param.Add("@title", dto.Title);
                param.Add("@description", dto.Description);
                param.Add("@image_url", dto.ImageUrl);
                param.Add("@link_url", dto.LinkUrl);
                param.Add("@position", dto.Position);
                param.Add("@priority", dto.Priority);
                param.Add("@start_date", dto.StartDate);
                param.Add("@end_date", dto.EndDate);
                param.Add("@is_active", dto.IsActive);
                param.Add("@company_name", dto.CompanyName);
                param.Add("@company_contact", dto.CompanyContact);
                param.Add("@company_phone", dto.CompanyPhone);
                param.Add("@company_email", dto.CompanyEmail);
                param.Add("@user_id", userId);
                return param;
            });
        }

        public async Task<BaseValidate> DelInfo(Guid id, Guid userId)
        {
            const string storedProcedure = "sp_res_advertisement_del";
            return await base.DeleteAsync(storedProcedure, new { id, user_id = userId });
        }

        // Additional methods for statistics
        public async Task<List<AdvertisementStatsDto>> GetAdvertisementStats(DateTime? fromDate, DateTime? toDate)
        {
            const string storedProcedure = "sp_res_advertisement_stats";
            return await GetListAsync<AdvertisementStatsDto>(storedProcedure, new { from_date = fromDate, to_date = toDate });
        }

        public async Task<BaseValidate> UpdateViewCount(Guid id)
        {
            const string storedProcedure = "sp_res_advertisement_update_view_count";
            return await SetAsync(storedProcedure, new { id });
        }

        public async Task<BaseValidate> UpdateClickCount(Guid id)
        {
            const string storedProcedure = "sp_res_advertisement_update_click_count";
            return await SetAsync(storedProcedure, new { id });
        }
    }
}
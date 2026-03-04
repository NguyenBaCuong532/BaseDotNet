using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Settings;

namespace UNI.Resident.DAL.Repositories.Settings
{
    /// <summary>
    /// Cấu hình chung cho dự án
    /// </summary>
    public class ProjectConfigRepository : ResidentBaseRepository, IProjectConfigRepository
    {
        public ProjectConfigRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetProjectConfigFilter()
            => GetTableFilter("config_sp_res_ProjectConfig_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetProjectConfigPage(FilterBase filter)
            => GetDataListPageAsync("sp_res_ProjectConfig_page", filter, objParams: null);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetProjectConfigFields(Guid? oid)
            => GetFieldsAsync<viewBaseInfo>("sp_res_ProjectConfig_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetProjectConfig(CommonViewInfo inputData)
            => GetFirstOrDefaultAsync<BaseValidate>("sp_res_ProjectConfig_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetProjectConfigDelete(List<Guid> arrOid)
            => await GetFirstOrDefaultAsync<BaseValidate>("sp_res_ProjectConfig_del", new { ArrOid = string.Join(",", arrOid) });

        /// <summary>
        /// Thay đổi giá trị cấu hình mặc định
        /// </summary>
        /// <param name="configCode"></param>
        /// <param name="configValue"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetProjectConfigDefaultValue(string configCode, string configValue)
            => GetFirstOrDefaultAsync<BaseValidate>("sp_res_ProjectConfig_set_default_value",
                objParams: new
                {
                    config_code = configCode,
                    config_value = configValue
                });

        public Task<BaseValidate<string>> GetProjectConfigValue(string configCode, long? receiveId)
            => GetFirstOrDefaultAsync<BaseValidate<string>>("sp_res_ProjectConfig_get_config_value",
                objParams: new
                {
                    config_code = configCode
                    , receive_id = receiveId.ToString()
                });
    }
}
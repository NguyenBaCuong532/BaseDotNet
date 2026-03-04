using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Settings;

namespace UNI.Resident.DAL.Repositories.Settings
{
    /// <summary>
    /// Config Repository
    /// </summary>
    /// Author: taint
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="UIConfigRepository" />
    public class UIConfigRepository : UniBaseRepository, IUIConfigRepository
    {
        public UIConfigRepository(IUniCommonBaseRepository commonBaseInfo) : base(commonBaseInfo)
        {
        }
        #region config_formview
        public async Task<CommonDataPage> GetFormViewPage(FilterInpTableKey filter)
        {
            const string storedProcedure = "sp_config_formview_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { table_name = filter.tableKey });
        }

        public async Task<BaseValidate> SetFormViewInfo(ConfigField para)
        {
            const string storedProcedure = "sp_config_formview_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, para);
        }
        public async Task<BaseValidate> DelFormViewInfo(long fieldId)
        {
            const string storedProcedure = "sp_config_formview_del";
            return await base.DeleteAsync(storedProcedure, new { id = fieldId });
        }
        public async Task<CommonDataPage> GetGridViewPage(FilterInpGridKey filter)
        {
            const string storedProcedure = "sp_config_gridview_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { view_grid = filter.gridKey });
        }
        public async Task<BaseValidate> SetGridViewInfo(ConfigColumn para)
        {
            const string storedProcedure = "sp_config_gridview_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, para);
        }

        public async Task<BaseValidate> DelGridViewInfo(long gridId)
        {
            const string storedProcedure = "sp_config_gridview_del";
            return await base.DeleteAsync(storedProcedure, new { id = gridId });
        }

        public async Task<CommonViewInfo> GetGroupInfo(string key_1, string key_2)
        {
            const string storedProcedure = "sp_config_group_get";
            return await base.GetFieldsAsync<CommonViewInfo>(storedProcedure, new { key_1, key_2 });
        }
        public async Task<BaseValidate> SetGroupInfo(CommonViewInfo para)
        {
            const string storedProcedure = "sp_config_group_set";
            return await base.SetInfoAsync<BaseValidate>(storedProcedure, para, new { para.id });
        }

        public async Task<List<viewGridFlex>> GetGridAsync(string gridKey)
        {
            const string storedProcedure = "sp_config_grid_get";
            return await GetListAsync<viewGridFlex>(storedProcedure, new { gridKey });
        }
        #endregion config_formview
    }
}

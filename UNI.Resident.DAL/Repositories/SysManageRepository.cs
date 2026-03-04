using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories
{
    public class SysManageRepository : UniBaseRepository, ISysManageRepository
    {
        public SysManageRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        #region sys
        public async Task<CommonViewInfo> GetManagerFilter(string userId, string table_key)
        {
            const string storedProcedure = "sp_sys_manager_filter_get";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { table_key });
        }
        public async Task<List<CommonValue>> GetObjectsAsync(string userId, string objKey, bool? isAll)
        {
            const string storedProcedure = "sp_sys_object_group_get";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId, objKey, isAll });
        }        
        public async Task<List<CommonValue>> GetCommonListAsync(string userId, bool isFilter, string tableName, string columnName, string columnId)
        {
            const string storedProcedure = "sp_sys_common_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId, isFilter, tableName, columnName, columnId, columnParent = (string)null, valueParent = (string)null, All = string.Empty });
        }
        #endregion sys
        #region project_list
        public async Task<List<CommonValue>> GetServiceProviderListAsync(string userId, int? ContractTypeId)
        {
            const string storedProcedure = "sp_res_service_providers_get";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId, ContractTypeId });
        }
        public async Task<List<CommonValue>> GetFamilyMemberListAsync(string userId, int? ApartmentId)
        {
            const string storedProcedure = "sp_res_family_member_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId, ApartmentId });
        }
        public async Task<List<ProjectListModel>> GetProjectListAsync(string userId, bool? isAll)
        {
            const string storedProcedure = "sp_res_project_list";
            return await GetListAsync<ProjectListModel>(storedProcedure, new { userId, isAll });
        }
        public async Task<List<ProjectListModel>> GetProjectList1Async(string userId, bool? isAll)
        {
            const string storedProcedure = "sp_res_project_list1";
            return await GetListAsync<ProjectListModel>(storedProcedure, new { userId, isAll });
        }
        public async Task<List<CommonValue>> GetProjectListForOutSideAsync(bool? isAll)
        {
            const string storedProcedure = "sp_res_project_list_forOutSide";
            return await GetListAsync<CommonValue>(storedProcedure, new { isAll });
        }
        public async Task<List<CommonValue>> GetNotifyListAsync(string userId, string external_key)
        {
            const string storedProcedure = "sp_res_notify_ref_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId, external_key });
        }
        #endregion project_list
    }
}

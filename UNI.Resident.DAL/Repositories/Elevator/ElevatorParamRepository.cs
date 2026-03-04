using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Repositories.Elevator
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IElevatorRepository" />
    public class ElevatorParamRepository : UniBaseRepository, IElevatorParamRepository
    {

        public ElevatorParamRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        #region elevator-reg
        public async Task<CommonDataPage> GetCardRolePage(FilterBase flt)
        {
            const string storedProcedure = "sp_res_elevator_role_page";
            return await base.GetDataListPageAsync(storedProcedure, flt, new { });
        }
        public async Task<CommonViewInfo> GetCardRoleInfo(string id)
        {
            const string storedProcedure = "sp_res_elevator_role_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id });
        }
        public async Task<BaseValidate> SetCardRoleInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_role_set";
            return await SetInfoAsync(storedProcedure, info);
        }
        public Task<BaseValidate> DelCardRole(string id)
        {
            const string storedProcedure = "sp_res_elevator_role_del";
            return base.DeleteAsync(storedProcedure, new { id });
        }
        public async Task<List<CommonValue>> GetCardRoles(string userId)
        {
            const string storedProcedure = "sp_res_elevator_role_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId });
        }

        public async Task<CommonDataPage> GetBankShaftPage(FilterInputBuilding filter)
        {
            const string storedProcedure = "sp_res_elevator_bank_shaft_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.projectCd, filter.buildingCd });
        }
        public async Task<CommonViewInfo> GetBankShaftInfo(string buildingCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_bank_shaft_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { buildingCd, id });
        }
        public async Task<BaseValidate> SetBankShaftInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_bank_shaft_set";
            return await SetInfoAsync(storedProcedure, info);
        }
        public Task<BaseValidate> DelBankShaft(string buildingCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_bank_shaft_del";
            return base.DeleteAsync(storedProcedure, new { buildingCd, id });
        }
        public async Task<List<CommonValue>> GetBankShafts(string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_bank_shafts_get";
            return await GetListAsync<CommonValue>(storedProcedure, new { ProjectCd = projectCd });
        }
        public async Task<List<CommonValue>> GetFloorTypeList(string areaCd)
        {
            const string storedProcedure = "sp_res_elevator_floor_type_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { areaCd });
        }
        #endregion
    }
}

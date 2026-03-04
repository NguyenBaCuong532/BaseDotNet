using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Settings;

namespace UNI.Resident.DAL.Repositories.Settings
{
    public class CommonRepository : UniBaseRepository, ICommonRepository
    {
        public CommonRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        #region web-apartment
        public async Task<List<CommonValue>> GetObjectList(string objKey, string all)
        {
            const string storedProcedure = "sp_config_object_data_get";
            return await GetListAsync<CommonValue>(storedProcedure, new { objKey, all });
        }
        public async Task<List<CommonValue>> GetObjectClass(string objKey, string all)
        {
            const string storedProcedure = "sp_config_object_class_get";
            return await GetListAsync<CommonValue>(storedProcedure, new { objKey, all });
        }
        public async Task<List<CommonValue>> GetBuildingList(string projectCd, bool? isAll)
        {
            const string storedProcedure = "sp_res_apartment_building_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { isAll, projectCd });
        }
        public async Task<List<CommonValue>> GetAreaList(string buildingCd, string projectCd, bool? isAll)
        {
            const string storedProcedure = "sp_res_elevator_area_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { isAll, buildingCd, projectCd });
        }
        public async Task<List<CommonValue>> GetFloorList(string buildingCd, System.Guid? buildingOid = null)
        {
            const string storedProcedure = "sp_res_apartment_floor_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { buildingCd, buildingOid });
        }
        public async Task<List<CommonValue>> GetRoomList(string buildingCd, string floorNo, System.Guid? buildingOid = null, System.Guid? floorOid = null)
        {
            const string storedProcedure = "sp_res_apartment_room_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { BuildingCd = buildingCd, buildingOid, floorNo, floorOid });
        }

        public async Task<List<CommonValue>> GetRoomList2(string projectCd, string buildingCd, string floorNo, int? apartmentId = null, string filter = null, System.Guid? buildingOid = null, System.Guid? floorOid = null, System.Guid? apartOid = null)
        {
            const string storedProcedure = "sp_res_apartment_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { projectCd, buildingCd, floorNo, apartmentId, filter, buildingOid, floorOid, Oid = apartOid });
        }

        public async Task SetConfigData(string key, string value)
        {
            const string storedProcedure = "sp_config_data_set";
            await SetAsync(storedProcedure, new { key, value });
        }
        #endregion
        public async Task<List<CommonValue>> GetCardTypes()
        {
            const string storedProcedure = "sp_res_card_type_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { });
        }
        public async Task<List<CommonValue>> GetNotifyList(string external_key)
        {
            const string storedProcedure = "sp_res_notify_ref_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { external_key });
        }
        public async Task<CommonViewInfo> GetCommonFilterInfo(string tableKey)
        {
            const string storedProcedure = "sp_common_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { tableKey });
        }
        public async Task<CommonViewInfo> SetCommonFilterDraft(CommonViewInfo draft)
        {
            const string storedProcedure = "sp_common_filter_draft";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, param =>
            {
                param.Add("@tableKey", draft.tableKey);
                param.AddDynamicParams(draft.ToObject());
                return param;
            });
        }
        public async Task<List<CommonValue>> GetProjectList(bool? isAll)
        {
            const string storedProcedure = "sp_res_project_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { isAll });
        }

        public async Task<List<CommonValue>> GetCommonList(bool isfilter, string tableName, string columnName,
            string columnId, string columnParent, string valueParent, string colSortOrder)
        {
            const string storedProcedure = "sp_sys_common_list";
            return await GetListAsync<CommonValue>(storedProcedure,
                new
                {
                    isFilter = isfilter,
                    tableName,
                    columnName,
                    columnId,
                    columnParent,
                    valueParent,
                    All = string.Empty,
                    colSortOrder
                });
        }
        public async Task<List<CommonValue>> GetServiceProviderList(int? contractTypeId)
        {
            const string storedProcedure = "sp_res_service_providers_get";
            return await GetListAsync<CommonValue>(storedProcedure, new { ContractTypeId = contractTypeId });
        }
        public async Task<List<CommonValue>> GetFamilyMemberList(int? apartmentId)
        {
            const string storedProcedure = "sp_res_family_member_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { ApartmentId = apartmentId });
        }
        public async Task<List<CommonValue>> GetProjectList1(bool? isAll)
        {
            const string storedProcedure = "sp_res_project_list1";
            return await GetListAsync<CommonValue>(storedProcedure, new { isAll });
        }
        public async Task<List<CommonValue>> GetProjectListForOutSide(bool? isAll)
        {
            const string storedProcedure = "sp_res_project_list_forOutSide";
            return await GetListAsync<CommonValue>(storedProcedure, new { isAll });
        }

        public async Task<List<CommonValue>> GetElevatorFloorList(string projectCd, string areaCd, string buildZone)
        {
            const string storedProcedure = "sp_res_elevator_floor_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { projectCd, areaCd, buildZone });
        }

        public async Task<List<CommonValue>> GetBankCodes(string filter = null)
        {
            const string storedProcedure = "sp_res_bank_codes_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { filter });
        }
        public async Task<List<CommonValue>> GetRoomList3(string projectCd, string oids, string filter)
        {
            const string storedProcedure = "sp_res_apartment_room_list3";
            return await GetListAsync<CommonValue>(storedProcedure, new { projectCd, oids, filter });
        }
    }
}
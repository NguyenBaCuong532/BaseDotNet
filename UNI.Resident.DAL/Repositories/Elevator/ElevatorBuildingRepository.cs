using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;

namespace UNI.Resident.DAL.Repositories.Elevator
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IElevatorRepository" />
    public class ElevatorBuildingRepository : UniBaseRepository, IElevatorBuildingRepository
    {

        public ElevatorBuildingRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        #region elevator-reg
        
        public async Task<List<CommonValue>> GetBuildAreaList(string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_area_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { projectCd });
        }
        public async Task<CommonDataPage> GetBuildAreaPage(FilterInputBuilding filter)
        {
            const string storedProcedure = "sp_res_elevator_area_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.projectCd, filter.buildingCd });
        }
        public async Task<BuildAreaInfo> GetBuildAreaInfo(string projectCd, string buildingCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_area_field";
            return await GetFieldsAsync<BuildAreaInfo>(storedProcedure, new { projectCd, buildingCd, id });
        }
        public async Task<BaseValidate> SetBuildAreaInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_area_set";
            return await SetInfoAsync(storedProcedure, info);
        }
        public Task<BaseValidate> DelBuildArea(string buildingCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_area_del";
            return base.DeleteAsync(storedProcedure, new { buildingCd, id });
        }

        
        public async Task<List<CommonValue>> GetBuildZoneList(string projectCd, string areaCd)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { ProjectCd = projectCd, AreaCd = areaCd });
        }
        public async Task<CommonDataPage> GetBuildZonePage(FilterElevatorZone flt)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_page";
            return await base.GetDataListPageAsync(storedProcedure, flt, new { flt.ProjectCd, areaCd = flt.BuildingCd });
        }
        public async Task<CommonViewInfo> GetBuildZoneInfo(string areaCd, string id, string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { areaCd, id, projectCd });
        }
        public async Task<BaseValidate> SetBuildZoneInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_set";
            return await SetInfoAsync(storedProcedure, info, new { info.id });
        }
        public Task<BaseValidate> DelBuildZone(string areaCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_del";
            return base.DeleteAsync(storedProcedure, new { areaCd, id });
        }
        #endregion

        public async Task<CommonDataPage> GetBuildFloorPage(FilterElevatorFloor filter)
        {
            const string storedProcedure = "sp_res_elevator_floor_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.ProjectCd, filter.areaCd, filter.BuildZone, filter.buildingOid });
        }
        public async Task<CommonViewInfo> GetBuildFloorInfo(string buildingCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_floor_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { buildingCd, id });
        }
        public async Task<BaseValidate> SetBuildFloorInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_floor_set";
            return await SetInfoAsync(storedProcedure, info);
        }
        public Task<BaseValidate> DelBuildFloor(string buildingCd, string id)
        {
            const string storedProcedure = "sp_res_elevator_floor_del";
            return base.DeleteAsync(storedProcedure, new { buildingCd, id });
        }

        public async Task<List<CommonValue>> GetBuildFloorList(string projectCd, string buildCd, string buildZone, System.Guid? buildingOid = null)
        {
            const string storedProcedure = "sp_res_elevator_build_floor_list";
            return await GetListAsync<CommonValue>(storedProcedure,
                new { ProjectCd = projectCd, BuildCd = buildCd, BuildZone = buildZone, buildingOid });
        }

    }
}

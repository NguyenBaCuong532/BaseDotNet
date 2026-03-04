using Dapper;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Elevator
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IElevatorRepository" />
    public class ElevatorRepository : UniBaseRepository, IElevatorRepository
    {

        public ElevatorRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        #region elevator-reg
        public async Task<ResponseList<List<HomCardTypeGet>>> GetCardTypeListAsync()
        {
            const string storedProcedure = "sp_res_elevator_card_types_get";
            var param = new DynamicParameters();
            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
            var result = await GetListAsync<HomCardTypeGet>(storedProcedure, param);
            return new ResponseList<List<HomCardTypeGet>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered")); 
        }
        public async Task<List<ProjectApp>> GetProjectsAsync(string userId)
        {
            const string storedProcedure = "sp_res_elevator_project_page_get";
            return await GetListAsync<ProjectApp>(storedProcedure, new { userId });
        }
        public async Task<List<CardCustomer>> GetCardCustomersAsync(string cardCd)
        {
            const string storedProcedure = "sp_res_elevator_card_customers_get";
            return await GetListAsync<CardCustomer>(storedProcedure, new { CardCd = cardCd });
        }
        public async Task<CardInfo> GetCardInfoAsync(string cardNum, string customerPhoneNumber, string HardwareId)
        {
            const string storedProcedure = "sp_res_elevator_card_by_code_field_get";
            return await GetFirstOrDefaultAsync<CardInfo>(storedProcedure, 
                new { CardNum = cardNum, CustomerPhoneNumber = customerPhoneNumber, HardwareId });
        }
        public async Task<HomCardAccess> GetCardEvevateAsync(string userid, string cardCode, int cardtype, string hardwareId, int mode)
        {
            const string storedProcedure = "sp_res_elevator_card_evevate_get";
            return await GetMultipleAsync<HomCardAccess>(storedProcedure, 
                new { userid, Code = cardCode, cardtype, hardwareId, mode }, 
            async result =>
            {
                var access = await result.ReadFirstOrDefaultAsync<HomCardAccess>();
                if (access != null)
                {
                    access.accessible_floor_numbers = (await result.ReadAsync<HomCardFloor>()).ToList();
                }
                return access;
            });
        }
        public async Task SetElevatorBuildingAsync(ElevatorBuilding building)
        {
            const string storedProcedure = "sp_res_elevator_building_info_set";
            await SetAsync(storedProcedure, 
                new { building.Id, building.BuildCd, building.BuildName, building.ProjectCd });
        }
        public async Task SetElevatorFloorAsync(ElevatorFloor floor)
        {
            const string storedProcedure = "sp_res_elevator_floor_info_set";
            await SetAsync(storedProcedure, 
                new { FloorId = floor.Id, floor.FloorName, floor.FloorNumber, floor.FloorTypeId, floor.BuildCd, floor.BuildZoneId, floor.ProjectCd });
        }
        public async Task<List<ElevatorFloor>> GetElevatorFloorsAsync(string buildCd, string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_floors_by_buildingCd_get";
            return await GetListAsync<ElevatorFloor>(storedProcedure, 
                new { BuildCd = buildCd, ProjectCd = projectCd });
        }

        public async Task<ElevatorFloor> GetElevatorFloorAsync(int? floorId)
        {
            const string storedProcedure = "sp_res_elevator_floors_by_buildingCd_get";
            return await GetFirstOrDefaultAsync<ElevatorFloor>(storedProcedure, 
                new { FloorId = floorId, BuildCd = (string)null });
        }
        public async Task SetElevatorCardRoleAsync(ElevatorCardRole cardRole)
        {
            const string storedProcedure = "sp_res_elevator_card_role_set";
            await SetAsync(storedProcedure, new { cardRole.Id, cardRole.RoleName });
        }
        public async Task<List<CardInfo>> GetElevatorCardRolesAsync(string userId)
        {
            const string storedProcedure = "sp_res_elevator_card_role_get";
            return await GetListAsync<CardInfo>(storedProcedure, new { userId });
        }
        public async Task<List<ElevatorCardRole>> GetElevatorCardRoleAsync(int? cardRoleId)
        {
            const string storedProcedure = "sp_res_elevator_card_role_get";
            return await GetListAsync<ElevatorCardRole>(storedProcedure, new { CardRoleId = cardRoleId });
        }
        public async Task<List<CardInfo>> GetCardRoleInfosAsync(string userId)
        {
            const string storedProcedure = "sp_res_elevator_card_role_field_get";
            return await GetListAsync<CardInfo>(storedProcedure, new { userId });
        }
        public async Task SetElevatorFloorTypeAsync(ElevatorFloorType floorType)
        {
            const string storedProcedure = "sp_res_elevator_floor_type_set";
            await SetAsync(storedProcedure, new { floorType.Id, floorType.FloorTypeName, floorType.BuildCd });
        }
        public async Task SetElevatorBuildZoneAsync(ElevatorBuildZone buildZone)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_set";
            await SetAsync(storedProcedure, new { buildZone.Id, buildZone.BuildZoneName, buildZone.BuildCd });
        }
        public async Task<MAS_Elevator_Card> SetMAS_Elevator_CardAsync(MAS_Elevator_Card info)
        {
            const string storedProcedure = "sp_res_elevator_card_set";
            return await GetFirstOrDefaultAsync<MAS_Elevator_Card>(storedProcedure, param =>
            {
                param.Add("@Id", info.Id);
                param.Add("@CardId", info.CardId);
                param.Add("@CardRole", info.CardRole);
                param.Add("@CardType", info.CardType);
                param.Add("@ProjectCd", info.ProjectCd);
                param.Add("@BuildCd", info.BuildCd);
                param.Add("@FloorNumber", info.FloorNumber);
                param.Add("@Note", info.Note);
                return param;
            });
        }
        public async Task SetMAS_Elevator_DeviceAsync(MAS_Elevator_Device mas_elevator_device)
        {
            const string storedProcedure = "sp_res_elevator_device_set";
            await SetAsync<int>(storedProcedure, param =>
            {
                param.Add("@Id", mas_elevator_device.Id);
                param.Add("@HardwareId", mas_elevator_device.HardwareId);
                param.Add("@FloorNumber", mas_elevator_device.FloorNumber);
                param.Add("@FloorName", mas_elevator_device.FloorName);
                param.Add("@ElevatorBank", mas_elevator_device.ElevatorBank);
                param.Add("@ElevatorShaftName", mas_elevator_device.ElevatorShaftName);
                param.Add("@ElevatorShaftNumber", mas_elevator_device.ElevatorShaftNumber);
                param.Add("@ProjectCd", mas_elevator_device.ProjectCd);
                param.Add("@BuildCd", mas_elevator_device.BuildCd);
                param.Add("@BuildZone", mas_elevator_device.BuildZone);
                param.Add("@IsActived", mas_elevator_device.IsActived);
                return param;
            });
        }
        public async Task SetMAS_Elevator_FloorAsync(MAS_Elevator_Floor info)
        {
            const string storedProcedure = "sp_res_elevator_floor_set";
            await SetAsync(storedProcedure, 
                new { info.Id, info.FloorName, info.FloorNumber, info.FloorType, info.BuildCd, info.ProjectCd, info.BuildZone });
        }
        public async Task<List<ElevatorBuilding>> GetBuildCdByProjectCdAsync(string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_building_by_projectCd_get";
            return await GetListAsync<ElevatorBuilding>(storedProcedure, new { ProjectCd = projectCd });
        }
        public async Task<List<ElevatorBuildZone>> GetBuildZoneByBuildCdAsync(string projectCd, string buildCd)
        {
            const string storedProcedure = "sp_res_elevator_build_zone_by_buildCd_get";
            return await GetListAsync<ElevatorBuildZone>(storedProcedure, new { ProjectCd = projectCd, BuidldCd = buildCd });
        }
        public async Task<CommonDataPage> GetMasElevatorFloorPageAsync(FilterElevatorFloor filter)
        {
            const string storedProcedure = "sp_res_elevator_floor_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.ProjectCd, filter.areaCd, filter.BuildZone });            
        }
        public async Task<ResponseList<List<CardInfo>>> GetMasElevatorCardsAsync(FilterInputBuilding filter)
        {
            const string storedProcedure = "sp_res_elevator_card_page_bycd";
            var param = new DynamicParameters();
            param.Add("@UserId", filter.userId);
            param.Add("@CardCd", filter.filter);
            param.Add("@ProjectCd", filter.projectCd);
            param.Add("@BuildCd", filter.buildingCd);
            param.Add("@Offset", filter.offSet);
            param.Add("@PageSize", filter.pageSize);
            var result = await base.GetListAsync<CardInfo>(storedProcedure, param);
            return new ResponseList<List<CardInfo>>(result, 0, 0);
            //
        }
        public async Task<List<ElevatorFloor>> GetBuildFloorByProjectCdBuildCdAsync(string projectCd, string buildCd, string buildZone)
        {
            const string storedProcedure = "sp_res_elevator_build_floor_by_projectCd_get";
            return await GetListAsync<ElevatorFloor>(storedProcedure, 
                new { ProjectCd = projectCd, BuildCd = buildCd, BuildZone = buildZone });
        }
        public async Task<List<ElevatorFloorType>> GetFloorTypeByBuildCdAsync(string buildCd)
        {
            const string storedProcedure = "sp_res_elevator_floor_type_by_build_get";
            return await GetListAsync<ElevatorFloorType>(storedProcedure, new { BuildCd = buildCd });
        }
        public async Task DeleteMasElevatorCardAsync(string ids)
        {
            const string storedProcedure = "sp_res_elevator_Card_Del"; 
            await DeleteAsync(storedProcedure, new { ids });
        }
        public async Task<CommonDataPage> GetMasElevatorDevicePageAsync(FilterElevatorDevice filter)
        {
            const string storedProcedure = "sp_res_elevator_device_page";
            return await GetDataListPageAsync(storedProcedure, filter,
                new { filter.ProjectCd, filter.BuildingCd, filter.BuildZone, filter.FloorNumber });
        }
        public async Task<List<FloorInfoGo>> GetFoorInfoGoAsync(FilterElevatorFloor filter)
        {
            const string storedProcedure = "sp_res_elevator_floor_field_get";
            return await GetListAsync<FloorInfoGo>(storedProcedure, filter);
        }
        public async Task<List<ElevatorBankShaft>> GetElevatorBankShaftsAsync(string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_bank_shafts_get";
            return await GetListAsync<ElevatorBankShaft>(storedProcedure, new { ProjectCd = projectCd });
        }
        public async Task SetAccessFloorAsync(HomAccessFloor floor)
        {
            const string storedProcedure = "sp_res_elevator_access_floor_set";
            await SetAsync(storedProcedure, new { userId = floor.id, floor.id, floor.FloorName });
        }
        public async Task<HomAccessGet> GetAccessFloorsAsync(string id, int mode)
        {
            const string storedProcedure = "sp_res_elevator_access_floors_get";
            return await GetFirstOrDefaultAsync<HomAccessGet>(storedProcedure, new { mode });
        }
        public async Task<CommonDataPage> GetMasElevatorCards(FilterInputBuilding flt)
        {
            const string storedProcedure = "sp_res_elevator_card_page";
            return await GetDataListPageAsync(storedProcedure, flt, new { CardCd = flt.filter, flt.projectCd, flt.buildingCd });
        }

        public async Task<CommonDataPage> GetElevatorUsageHistoryPage(FilterBase query, string projectCd)
        {
            const string storedProcedure = "sp_res_elevator_usage_history_page";
            return await GetDataListPageAsync(storedProcedure, query, new { projectCd });
        }
        #endregion
    }
}

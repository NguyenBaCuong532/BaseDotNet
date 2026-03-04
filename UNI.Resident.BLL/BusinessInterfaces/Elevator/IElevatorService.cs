using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IElevatorService
    {

        #region elevator-reg
        Task<HomCardAccess> GetCardEvevateAsync(string userid, string cardCode, int cardtype, string hardwareId, int mode);
        Task SetElevatorFloorAsync(ElevatorFloor floor);

        Task<List<ElevatorFloor>> GetElevatorFloorsAsync(string buildCd, string projectCd);
        Task<ElevatorFloor> GetElevatorFloorAsync(int? floorId);
        Task SetElevatorCardRoleAsync(ElevatorCardRole cardRole);
        Task<List<CardInfo>> GetElevatorCardRolesAsync(string userId);
        Task<List<ElevatorCardRole>> GetElevatorCardRoleAsync(int? cardRoleId);
        Task SetElevatorFloorTypeAsync(ElevatorFloorType floorType);
        Task SetElevatorBuildZoneAsync(ElevatorBuildZone buildZone);
        Task SetElevatorBuildingAsync(ElevatorBuilding building);
        Task<MAS_Elevator_Card> SetMAS_Elevator_CardAsync(MAS_Elevator_Card mas_elevator_card);
        Task SetMAS_Elevator_DeviceAsync(MAS_Elevator_Device mas_elevator_device);
        Task SetMAS_Elevator_FloorAsync(MAS_Elevator_Floor mas_elevator_floor);
        Task<List<CardInfo>> GetCardRoleInfosAsync(string userId);
        Task<ResponseList<List<HomCardTypeGet>>> GetCardTypeListAsync();
        Task<List<ProjectApp>> GetProjectsAsync(string userId);
        Task<List<ElevatorBuilding>> GetBuildCdByProjectCdAsync(string projectCd);
        Task<List<ElevatorBuildZone>> GetBuildZoneByBuildCdAsync(string projectCd, string buildCd);
        Task<CommonDataPage> GetMasElevatorFloorPageAsync(FilterElevatorFloor filter);
        Task<ResponseList<List<CardInfo>>> GetMasElevatorCardsAsync(FilterInputBuilding filter);
        Task<List<ElevatorFloor>> GetBuildFloorByProjectCdBuildCdAsync(string projectCd, string buildCd, string buildZone);
        Task<List<ElevatorFloorType>> GetFloorTypeByBuildCdAsync(string buildCd);
        Task<CardInfo> GetCardInfoAsync(string cardNum, string customerPhoneNumber, string HardwareId);
        Task<List<CardCustomer>> GetCardCustomersAsync(string cardCd);
        Task DeleteMasElevatorCardAsync(string ids);
        Task<CommonDataPage> GetMasElevatorDevicePageAsync(FilterElevatorDevice filter);
        Task<List<FloorInfoGo>> GetFoorInfoGoAsync(FilterElevatorFloor filter);
        Task<List<ElevatorBankShaft>> GetElevatorBankShaftsAsync(string projectCd);
        Task SetAccessFloorAsync(HomAccessFloor floor);
        Task<HomAccessGet> GetAccessFloorsAsync(string id, int mode);
        Task<CommonDataPage> GetMasElevatorCards(FilterInputBuilding flt);
        Task<CommonDataPage> GetElevatorUsageHistoryPage(FilterBase query, string projectCd);
        #endregion elevator-reg

    }
}

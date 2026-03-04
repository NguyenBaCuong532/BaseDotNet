using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Elevator
{
    public interface IElevatorRepository
    {
        #region elevator-reg
        Task<ResponseList<List<HomCardTypeGet>>> GetCardTypeListAsync();
        Task<HomCardAccess> GetCardEvevateAsync(string userid, string cardCode, int cardtype, string hardwareId, int mode);
        Task<List<CardCustomer>> GetCardCustomersAsync(string cardCd);
        Task<CommonDataPage> GetMasElevatorDevicePageAsync(FilterElevatorDevice filter);
        Task<List<ElevatorBankShaft>> GetElevatorBankShaftsAsync(string projectCd);
        Task SetElevatorBuildingAsync(ElevatorBuilding building);
        Task SetElevatorFloorAsync(ElevatorFloor floor);
        Task<List<ElevatorFloor>> GetElevatorFloorsAsync(string buildCd, string projectCd);
        Task<ElevatorFloor> GetElevatorFloorAsync(int? floorId);
        Task SetElevatorCardRoleAsync(ElevatorCardRole cardRole);
        Task<List<CardInfo>> GetElevatorCardRolesAsync(string userId);
        Task<List<ElevatorCardRole>> GetElevatorCardRoleAsync(int? cardRoleId);
        Task SetElevatorFloorTypeAsync(ElevatorFloorType floorType);
        Task SetElevatorBuildZoneAsync(ElevatorBuildZone buildZone);
        Task<MAS_Elevator_Card> SetMAS_Elevator_CardAsync(MAS_Elevator_Card mas_elevator_card);
        Task SetMAS_Elevator_DeviceAsync(MAS_Elevator_Device mas_elevator_device);
        Task SetMAS_Elevator_FloorAsync(MAS_Elevator_Floor mas_elevator_floor);
        Task<CardInfo> GetCardInfoAsync(string cardNum, string customerPhoneNumber, string HardwareId);
        Task<List<ProjectApp>> GetProjectsAsync(string userId);
        Task<List<CardInfo>> GetCardRoleInfosAsync(string userId);
        Task<List<ElevatorBuilding>> GetBuildCdByProjectCdAsync(string projectCd);
        Task<List<ElevatorBuildZone>> GetBuildZoneByBuildCdAsync(string projectCd, string buildCd);
        Task<CommonDataPage> GetMasElevatorFloorPageAsync(FilterElevatorFloor filter);
        Task<ResponseList<List<CardInfo>>> GetMasElevatorCardsAsync(FilterInputBuilding filter);
        Task<List<ElevatorFloor>> GetBuildFloorByProjectCdBuildCdAsync(string projectCd, string buildCd, string buildZone);
        Task<List<ElevatorFloorType>> GetFloorTypeByBuildCdAsync(string buildCd);
        Task DeleteMasElevatorCardAsync(string ids);
        Task<List<FloorInfoGo>> GetFoorInfoGoAsync(FilterElevatorFloor filter);
        Task SetAccessFloorAsync(HomAccessFloor floor);
        Task<HomAccessGet> GetAccessFloorsAsync(string id, int mode);
        Task<CommonDataPage> GetMasElevatorCards(FilterInputBuilding flt);
        Task<CommonDataPage> GetElevatorUsageHistoryPage(FilterBase query, string projectCd);
        #endregion elevator-reg
    }
}

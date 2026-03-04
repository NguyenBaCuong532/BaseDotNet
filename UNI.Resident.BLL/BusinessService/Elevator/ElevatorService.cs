using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class ElevatorService : IElevatorService
    {
        private readonly IElevatorRepository _homeRepository;
        private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;
        public ElevatorService(
            IElevatorRepository homeRepository,
            IStorageService storageService,
            IFirebaseRepository fbnotiRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            
            _storageService = storageService;
            _fbnotiRepository = fbnotiRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        
        #region elevator-reg
        public async Task<HomCardAccess> GetCardEvevateAsync(string userid, string cardCode, int cardtype, string hardwareId, int mode)
        {
            return await _homeRepository.GetCardEvevateAsync(userid, cardCode, cardtype, hardwareId, mode);
        }
        public async Task<ResponseList<List<HomCardTypeGet>>> GetCardTypeListAsync()
        {
            return await _homeRepository.GetCardTypeListAsync();
        }

        public async Task SetElevatorFloorAsync(ElevatorFloor floor)
        {
            await _homeRepository.SetElevatorFloorAsync(floor);
        }

        public async Task<List<ElevatorFloor>> GetElevatorFloorsAsync(string buildCd, string projectCd)
        {
            return await _homeRepository.GetElevatorFloorsAsync(buildCd,projectCd);
        }

        public async Task<ElevatorFloor> GetElevatorFloorAsync(int? floorId)
        {
            return await _homeRepository.GetElevatorFloorAsync(floorId);
        }

        public async Task SetElevatorCardRoleAsync(ElevatorCardRole cardRole)
        {
            await _homeRepository.SetElevatorCardRoleAsync(cardRole);
        }

        public async Task<List<CardInfo>> GetElevatorCardRolesAsync(string userId)
        {
            return await _homeRepository.GetElevatorCardRolesAsync(userId);
        }

        public async Task<List<ElevatorCardRole>> GetElevatorCardRoleAsync(int? cardRoleId)
        {
            return await _homeRepository.GetElevatorCardRoleAsync(cardRoleId);
        }

        public async Task SetElevatorFloorTypeAsync(ElevatorFloorType floorType)
        {
            await _homeRepository.SetElevatorFloorTypeAsync(floorType);
        }
        public async Task SetElevatorBuildZoneAsync(ElevatorBuildZone buildZone)
        {
            await _homeRepository.SetElevatorBuildZoneAsync(buildZone);
        }
        public async Task SetElevatorBuildingAsync(ElevatorBuilding building)
        {
            await _homeRepository.SetElevatorBuildingAsync(building);
        }

        public async Task<MAS_Elevator_Card> SetMAS_Elevator_CardAsync(MAS_Elevator_Card mas_elevator_card)
        {
            return await _homeRepository.SetMAS_Elevator_CardAsync(mas_elevator_card);
        }

        public async Task SetMAS_Elevator_DeviceAsync(MAS_Elevator_Device mas_elevator_device)
        {
            await _homeRepository.SetMAS_Elevator_DeviceAsync(mas_elevator_device);
        }

        public async Task SetMAS_Elevator_FloorAsync(MAS_Elevator_Floor mas_elevator_floor)
        {
            await _homeRepository.SetMAS_Elevator_FloorAsync(mas_elevator_floor);
        }

        public async Task<CardInfo> GetCardInfoAsync(string cardNum, string customerPhoneNumber, string hardwareId)
        {
            return await _homeRepository.GetCardInfoAsync(cardNum, customerPhoneNumber, hardwareId);
        }
        public async Task<List<ProjectApp>> GetProjectsAsync(string userId)
        {
            return await _homeRepository.GetProjectsAsync(userId);
        }
        public async Task<List<CardInfo>> GetCardRoleInfosAsync(string userId)
        {
            return await _homeRepository.GetCardRoleInfosAsync(userId);
        }
        public async Task<List<ElevatorBuilding>> GetBuildCdByProjectCdAsync(string projectCd)
        {
            return await _homeRepository.GetBuildCdByProjectCdAsync(projectCd);
        }
        public async Task<List<ElevatorBuildZone>> GetBuildZoneByBuildCdAsync(string projectCd, string buildCd)
        {
            return await _homeRepository.GetBuildZoneByBuildCdAsync(projectCd, buildCd);
        }
        public async Task<CommonDataPage> GetMasElevatorFloorPageAsync(FilterElevatorFloor filter)
        {
            return await _homeRepository.GetMasElevatorFloorPageAsync(filter);
        }
        public async Task<ResponseList<List<CardInfo>>> GetMasElevatorCardsAsync(FilterInputBuilding filter)
        {
            return await _homeRepository.GetMasElevatorCardsAsync(filter);
        }
        public async Task<List<ElevatorFloor>> GetBuildFloorByProjectCdBuildCdAsync(string projectCd, string buildCd, string buildZone)
        {
            return await _homeRepository.GetBuildFloorByProjectCdBuildCdAsync(projectCd, buildCd, buildZone);
        }
        public async Task<List<ElevatorFloorType>> GetFloorTypeByBuildCdAsync(string buildCd)
        {
            return await _homeRepository.GetFloorTypeByBuildCdAsync(buildCd);
        }
        
        public async Task DeleteMasElevatorCardAsync(string ids)
        {
            await _homeRepository.DeleteMasElevatorCardAsync(ids);
        }
        public async Task<CommonDataPage> GetMasElevatorDevicePageAsync(FilterElevatorDevice filter)
        {
            return await _homeRepository.GetMasElevatorDevicePageAsync(filter);
        }
        
        public async Task<List<FloorInfoGo>> GetFoorInfoGoAsync(FilterElevatorFloor filter)
        {
            return await _homeRepository.GetFoorInfoGoAsync(filter);
        }
        public async Task<List<ElevatorBankShaft>> GetElevatorBankShaftsAsync(string projectCd)
        {
            return await _homeRepository.GetElevatorBankShaftsAsync(projectCd);
        }
        public async Task<List<CardCustomer>> GetCardCustomersAsync(string cardCd)
        {
            return await _homeRepository.GetCardCustomersAsync(cardCd);
        }
        public async Task SetAccessFloorAsync(HomAccessFloor floor)
        {
            await _homeRepository.SetAccessFloorAsync(floor);
        }
        public async Task<HomAccessGet> GetAccessFloorsAsync(string id, int mode)
        {
            return await _homeRepository.GetAccessFloorsAsync(id, mode);
        }
        public async Task<CommonDataPage> GetMasElevatorCards(FilterInputBuilding flt)
        {
            return await _homeRepository.GetMasElevatorCards(flt);
        }

        public async Task<CommonDataPage> GetElevatorUsageHistoryPage(FilterBase query, string projectCd)
        {
            return await _homeRepository.GetElevatorUsageHistoryPage(query, projectCd);
        }
        #endregion elevator-reg

    }
}

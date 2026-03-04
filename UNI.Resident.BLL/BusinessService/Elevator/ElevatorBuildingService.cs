using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.DAL.Repositories.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class ElevatorBuildingService : IElevatorBuildingService
    {
        private readonly IElevatorBuildingRepository _homeRepository;
        protected readonly ILogger _logger;
        public ElevatorBuildingService(
            IElevatorBuildingRepository homeRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }

        #region elevator-reg
        
        public async Task<List<CommonValue>> GetBuildAreaList(string buildingCd)
        {
            return await _homeRepository.GetBuildAreaList(buildingCd);
        }
        public async Task<CommonDataPage> GetBuildAreaPage(FilterInputBuilding filter)
        {
            return await _homeRepository.GetBuildAreaPage(filter);
        }
        public async Task<BuildAreaInfo> GetBuildAreaInfo(string projectCd, string buildingCd, string id)
        {
            return await _homeRepository.GetBuildAreaInfo(projectCd, buildingCd, id);
        }
        public async Task<BaseValidate> SetBuildAreaInfo(CommonViewInfo info)
        {
            return await _homeRepository.SetBuildAreaInfo(info);
        }
        public Task<BaseValidate> DelBuildArea(string buildingCd, string id)
        {
            return _homeRepository.DelBuildArea(buildingCd, id);
        }

        public async Task<List<CommonValue>> GetBuildZoneList(string projectCd, string areaCd)
        {
            return await _homeRepository.GetBuildZoneList(projectCd, areaCd);
        }
        public async Task<CommonDataPage> GetBuildZonePage(FilterElevatorZone flt)
        {
            return await _homeRepository.GetBuildZonePage(flt);
        }
        public async Task<BaseValidate> SetBuildZoneInfo(CommonViewInfo info)
        {
            return await _homeRepository.SetBuildZoneInfo(info);
        }
        public async Task<CommonViewInfo> GetBuildZoneInfo(string areaCd, string id, string projectCd)
        {
            return await _homeRepository.GetBuildZoneInfo(areaCd, id, projectCd);
        }
        public Task<BaseValidate> DelBuildZone(string areaCd, string id)
        {
            return _homeRepository.DelBuildZone(areaCd, id);
        }

        public async Task<CommonDataPage> GetBuildFloorPage(FilterElevatorFloor filter)
        {
            return await _homeRepository.GetBuildFloorPage(filter);
        }
        public async Task<BaseValidate> SetBuildFloorInfo(CommonViewInfo info)
        {
            return await _homeRepository.SetBuildFloorInfo(info);
        }
        public async Task<CommonViewInfo> GetBuildFloorInfo(string buildZone, string id)
        {
            return await _homeRepository.GetBuildFloorInfo(buildZone, id);
        }
        public Task<BaseValidate> DelBuildFloor(string buildZone, string id)
        {
            return _homeRepository.DelBuildFloor(buildZone, id);
        }
        public async Task<List<CommonValue>> GetBuildFloorList(string projectCd, string buildCd, string buildZone, System.Guid? buildingOid = null)
        {
            return await _homeRepository.GetBuildFloorList(projectCd, buildCd, buildZone, buildingOid);
        }
        
        
        #endregion elevator-reg

    }
}

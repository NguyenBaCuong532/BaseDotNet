using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model.Common;

namespace UNI.Resident.BLL.BusinessService.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class ElevatorParamService : IElevatorParamService
    {
        private readonly IElevatorParamRepository _homeRepository;
        protected readonly ILogger _logger;
        public ElevatorParamService(
            IElevatorParamRepository homeRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }

        #region elevator-reg
        public async Task<CommonDataPage> GetCardRolePage(FilterBase flt)
        {
            return await _homeRepository.GetCardRolePage(flt);
        }
        public async Task<CommonViewInfo> GetCardRoleInfo(string id)
        {
            return await _homeRepository.GetCardRoleInfo(id);
        }
        public async Task<BaseValidate> SetCardRoleInfo(CommonViewInfo info)
        {
            return await _homeRepository.SetCardRoleInfo(info);
        }
        public Task<BaseValidate> DelCardRole(string id)
        {
            return _homeRepository.DelCardRole(id);
        }
        public async Task<List<CommonValue>> GetCardRoles(string userId)
        {
            return await _homeRepository.GetCardRoles(userId);
        }

        public async Task<CommonDataPage> GetBankShaftPage(FilterInputBuilding filter)
        {
            return await _homeRepository.GetBankShaftPage(filter);
        }
        public async Task<CommonViewInfo> GetBankShaftInfo(string projectCd, string id)
        {
            return await _homeRepository.GetBankShaftInfo(projectCd, id);
        }
        public async Task<BaseValidate> SetBankShaftInfo(CommonViewInfo info)
        {
            return await _homeRepository.SetBankShaftInfo(info);
        }
        public Task<BaseValidate> DelBankShaft(string projectCd, string id)
        {
            return _homeRepository.DelBankShaft(projectCd, id);
        }
        public async Task<List<CommonValue>> GetBankShafts(string projectCd)
        {
            return await _homeRepository.GetBankShafts(projectCd);
        }
        public Task<List<CommonValue>> GetFloorTypeList(string areaCd)
        {
            return _homeRepository.GetFloorTypeList(areaCd);
        }
        #endregion elevator-reg

    }
}

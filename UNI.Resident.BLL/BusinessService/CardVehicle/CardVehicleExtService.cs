using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model;

namespace UNI.Resident.BLL.BusinessService.CardVehicle
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class CardVehicleExtService : ICardVehicleExtService
    {
        private readonly ICardVehicleExtRepository _homeRepository;
        private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;
        public CardVehicleExtService(
            ICardVehicleExtRepository homeRepository,
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
        
        #region web-card-reg

        public Task SetCardLocked(string userId, HomCardLock card)
        {
            return _homeRepository.SetCardLocked(userId, card);
        }
        public Task<BaseValidate> DeleteCard(string userId, string cardCd)
        {
            return _homeRepository.DeleteCard(userId, cardCd);
        }
        #endregion web-card-reg

        #region card vehicle

        #region web
        public Task<BaseValidateForHrm> SetCardVehicle(string userId, CommonViewInfo info)
        {
            return _homeRepository.SetCardVehicle(userId, info);
        }
        public Task<BaseValidateForHrm> SetEmployeeVehicleRes(string userId, HomCardVehicleForSet info)
        {
            return _homeRepository.SetEmployeeVehicleRes(userId, info);
        }
        public Task<List<CommonValue>> GetCardVehicle(string userId, string CustId)
        {
            return _homeRepository.GetCardVehicle(userId, CustId);
        }
        public Task<BaseValidate> SetVehicleRegCancel(string userId, HomVehicleRegCancel regSet)
        {
            return _homeRepository.SetVehicleRegCancel(userId, regSet);
        }
        public Task SetVehicleApprove(HomVehicleApprove vehicle)
        {
            return _homeRepository.SetVehicleApprove(vehicle);
        }
        public Task<BaseValidate> SetVehicleLockRes(string userId, HomVehicleLock vehicle)
        {
            return _homeRepository.SetVehicleLockRes(userId, vehicle);
        }
        public Task<ImportListPage> SetCardsAcceptRes(string userId, homeCardsImportSet cards)
        {
            return _homeRepository.SetCardsAcceptRes(userId, cards);
        }
        public Task<ImportListPage> SetCardVehicleAcceptRes(string userId, homCardVehicleImportSet cards)
        {
            return _homeRepository.SetCardVehicleAcceptRes(userId, cards);
        }
        public Task SetCustomerResident(string userId, homCustomerInfo cust)
        {
            return _homeRepository.SetCustomerResident(userId, cust);
        }
        #endregion

        #region app
        public Task<BaseValidateForHrm> SetVehicleRegisterRes(string userId, homVehicleRegSetApp vehicle)
        {
            return _homeRepository.SetVehicleRegisterRes(userId, vehicle);
        }
        public Task<BaseValidate> LockVehicleRes(string userId, HomAppVehicleLock vehicle)
        {
            return _homeRepository.LockVehicleRes(userId, vehicle);
        }
        
        #endregion

        #endregion
    }
}

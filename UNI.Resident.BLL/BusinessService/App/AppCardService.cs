using Google.Apis.Drive.v3;
using Microsoft.Extensions.Logging;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Utils;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces.App;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class AppCardService : IAppCardService
    {
        private readonly IAppCardRepository _homeRepository;
        //private readonly IActionRepository _actionRepository;
        //private readonly IElectricRepository _electricRepository;
        private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;
        public AppCardService(
            IAppCardRepository homeRepository,
            //IActionRepository actionRepository,
            IStorageService storageService,
            //IElectricRepository electricRepository,
            IFirebaseRepository fbnotiRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            //if (electricRepository != null)
            //    _electricRepository = electricRepository;
            //_actionRepository = actionRepository;
            _storageService = storageService;
            _fbnotiRepository = fbnotiRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        #region app-card-reg

        public async Task<PageFamilyCard> GetPageFamilyCardAsync(int? ApartmentId)
        {
            return await _homeRepository.GetPageFamilyCardAsync(ApartmentId);
        }
        
        public async Task<HomCardService> GetCardDetailAsync(string cardCd)
        {
            return await _homeRepository.GetCardDetailAsync(cardCd);
        }
        
        public async Task<BaseValidate> SetCardServiceVehicleAsync(HomServiceVehicleSet vehicle)
        {
            return await _homeRepository.SetCardServiceVehicleAsync(vehicle);
        }
        public async Task<BaseValidate> DeleteCardAsync(string cardCd)
        {
            return await _homeRepository.DeleteCardAsync(cardCd);
        }
        

        public async Task<long> SetCardRegisterAsync(HomCardRegSet cardSet)
        {
            return await _homeRepository.SetCardRegisterAsync(cardSet);
        }
        public async Task<BaseValidate> SetCardLostAsync(HomCardBase card)
        {
            return await _homeRepository.SetCardLostAsync(card);
        }
        public async Task SetCardLockedAsync(HomCardLock card)
        {
            await _homeRepository.SetCardLockedAsync(card);
        }
        
        #endregion web-card-reg

        #region web-vehicle-reg
        
        public async Task<List<HomVehicleType>> GetVehicleTypesAsync()
        {
            return await _homeRepository.GetVehicleTypesAsync();
        }
        public async Task<List<HomCardType>> GetCardTypesAsync()
        {
            return await _homeRepository.GetCardTypesAsync();
        }

        #endregion web-vehicle-reg



    }
}

using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class AppPointService : IAppPointService
    {
        private readonly IAppPointRepository _homeRepository;
        //private readonly IActionRepository _actionRepository;
        //private readonly IElectricRepository _electricRepository;
        private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;
        public AppPointService(
            IAppPointRepository homeRepository,
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
        #region app-apartment-reg
        
        public async Task<PagePayment> GetPagePaymentAsync(FilterBasePayment filter)
        {
            return await _homeRepository.GetPagePaymentAsync(filter);
        }
        public async Task<HomPaymentGet> GetPaymentDetailAsync(long receiveId)
        {
            return await _homeRepository.GetPaymentDetailAsync(receiveId);
        }
        public async Task<HomTransferInfo> GetTransferInfoAsync(long receiveId)
        {
            return await _homeRepository.GetTransferInfoAsync(receiveId);
        }
        #endregion app-apartment-reg

    }
}

using Google.Apis.Drive.v3;
using Microsoft.Extensions.Logging;
using UNI.Resident.BLL.BusinessInterfaces.App;
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
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces.App;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class AppServiceService : IAppServiceService
    {
        private readonly IAppServiceRepository _homeRepository;
        private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;
        public AppServiceService(
            IAppServiceRepository homeRepository,
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

        #region web-service-reg
        public async Task<List<HomRequestCategoryGet>> GetRequestCategoryListAsync(int categoryType, string language)
        {
            return await _homeRepository.GetRequestCategoryListAsync(categoryType, language);
        }
        public async Task<PageRequestFix> GetPageRequestAsync(FilterBaseApartment filter)
        {
            return await _homeRepository.GetPageRequestAsync(filter);
        }
        public async Task SetRequestAsync(HomRequestSet request)
        {
            await _homeRepository.SetRequestAsync(request);
        }
        public async Task SetRequestVotedAsync(HomRequestVote request)
        {
            await _homeRepository.SetRequestVotedAsync(request);
        }
        public async Task SetRequestConfirmAsync(HomRequestBase confirm)
        {
            await _homeRepository.SetRequestConfirmAsync(confirm);
        }
        public async Task<HomRequest> GetRequestAsync(long requestId)
        {
            return await _homeRepository.GetRequestAsync(requestId);
        }
        public async Task<HomRequestProcessGet> SetRequestProcessAsync(HomRequestProcess process)
        {
            return await _homeRepository.SetRequestProcessAsync(process);
        }
        public async Task<List<CommonValue>> GetBaseStatusAsync(string baseKey)
        {
            return await _homeRepository.GetBaseStatusAsync(baseKey);
        }
        #endregion web-service-reg
    }
}

using Google.Cloud.PubSub.V1;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Elevator;
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
    public class ElevatorCardService : IElevatorCardService
    {
        private readonly IElevatorCardRepository _homeRepository;
        protected readonly ILogger _logger;
        public ElevatorCardService(
            IElevatorCardRepository homeRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }

        #region elevator-reg
        public Task<ElevatorCardInfo> GetElevatorCardsDraft(ElevatorCardInfo cardCode)
        {
            return _homeRepository.GetElevatorCardsDraft(cardCode);
        }
        public async Task<CommonViewInfo> GetElevatorCardFilter()
        {
            return await _homeRepository.GetElevatorCardFilter();
        }
        public async Task<CommonDataPage> GetElevatorCardPage(FilterElevatorDevice filter)
        {
            return await _homeRepository.GetElevatorCardPage(filter);
        }
        public Task<BaseValidate> SetElevatorCardInfo(CommonViewIdInfo info)
        {
            return _homeRepository.SetElevatorCardInfo(info);
        }
        public Task<BaseValidate> DelElevatorCardInfo(IEnumerable<Guid> oids)
        {
            return _homeRepository.DelElevatorCardInfo(oids);
        }
        public async Task<CommonViewIdInfo> GetElevatorCardInfo(string id, string cardId)
        {
            return await _homeRepository.GetElevatorCardInfo(id, cardId);
        }
        public Task<CommonViewIdInfo> SetElevatorCardDraft(CommonViewIdInfo info)
        {
            return _homeRepository.SetElevatorCardDraft(info);
        }
        public Task<List<CommonValue>> GetElevatorCards(string cardId, string filter)
        {
            return _homeRepository.GetElevatorCards(cardId, filter);
        }
        public Task<ElevatorCardInfo> GetElevatorCardsInfo(string cardId)
        {
            return _homeRepository.GetElevatorCardsInfo(cardId);
        }
        #endregion elevator-reg

    }
}

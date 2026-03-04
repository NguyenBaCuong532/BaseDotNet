using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;
using System.Collections.Generic;
using System;
using System.IO;
using System.Threading.Tasks;
using System.Data;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model;
//using SSG.DAL.Interfaces;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardInternalService : ICardInternalService
    {
        private readonly ICardInternalRepository _repository;
        public CardInternalService(
            ICardInternalRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }

        public Task<CommonViewInfo> GetCardFilter()
        {
            return _repository.GetCardFilter();
        }
        public async Task<CommonDataPage> GetCardPage(FilterBaseProject query)
        {
            return await _repository.GetCardPage(query);
        }
        public async Task<CommonViewInfo> GetCardInfo(string cardId, Guid? cardOid = null)
        {
            return await _repository.GetCardInfo(cardId, cardOid);
        }

        public async Task<BaseValidate> SetCardInfo(CommonViewInfo info)
        {
            return await _repository.SetCardInfo(info);
        }
        public async Task<BaseValidate> DeleteCard(string cardId, Guid? cardOid = null)
        {
            return await _repository.DeleteCard(cardId, cardOid);
        }
        public async Task<BaseValidate> SetCardLocked(string cardId, int Status, Guid? cardOid = null)
        {
            return await _repository.SetCardLocked(cardId, Status, cardOid);
        }
        
    }
}

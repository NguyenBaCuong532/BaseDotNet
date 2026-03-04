using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardGuestService : ICardGuestService
    {
        private readonly ICardGuestRepository _repository;
        public CardGuestService(
            ICardGuestRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }
        
        public async Task<BaseValidate> DeleteCardAsync(string cardId, Guid? cardOid = null)
        {
            return await _repository.DeleteCardAsync(cardId, cardOid);
        }
        public async Task<BaseValidate> SetCardLockedAsync(string cardId, int Status, Guid? cardOid = null)
        {
            return await _repository.SetCardLockedAsync(cardId, Status, cardOid);
        }
        
        public Task<CommonViewInfo> GetCardFilter()
        {
            return _repository.GetCardFilter();
        }

        public Task<CommonDataPage> GetCardGuestPage(CardGuestFilter query)
        {
            return _repository.GetGuestCardPageAsync(query);
        }

        public Task<CommonViewInfo> GetCardGuestInfo(string cardId, string partner_id, Guid? cardOid = null)
        {
            return _repository.GetInfoAsync(cardId, partner_id, cardOid);
        }
        public Task<CommonViewInfo> SetGuestCardDraft(CommonViewInfo info)
        {
            return _repository.SetGuestCardDraft(info);
        }
        public Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info)
        {
            return _repository.SetGuestCardInfoAsync(info);
        }


    }
}

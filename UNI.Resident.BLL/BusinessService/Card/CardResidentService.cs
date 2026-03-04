using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardResidentService : ICardResidentService
    {

        private readonly ICardResidentRepository _repository;
        public CardResidentService(
            ICardResidentRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }
        // thẻ xe thuộc căn hộ
        public Task<CommonViewInfo> GetResidentCardFilter()
        {
            return _repository.GetResidentCardFilter();
        }

        public async Task<CommonDataPage> GetResidentCardPage(FilterCardResident query)
        {
            return await _repository.GetResidentCardPage(query);
        }
        public async Task<CommonViewInfo> GetCardInfoAsync(string cardId, string apartmentId, Guid? apartOid = null, Guid? cardOid = null)
        {
            return await _repository.GetCardInfoAsync(cardId, apartmentId, apartOid, cardOid);
        }

        public async Task<BaseValidate> SetCardInfoAsync(CommonViewInfo info)
        {
            return await _repository.SetCardInfoAsync(info);
        }
        public async Task<BaseValidate> DeleteCardAsync(string cardId)
        {
            return await _repository.DeleteCardAsync(cardId);
        }
        public async Task<BaseValidate> SetCardLockedAsync(string cardId, int Status)
        {
            return await _repository.SetCardLockedAsync(cardId, Status);
        }
        // thẻ xe
        

    }
}

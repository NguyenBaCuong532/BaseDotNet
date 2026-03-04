using UNI.Model;
using UNI.Resident.Model.Common;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardPartnerService : ICardPartnerService
    {
        private readonly ICardPartnerRepository _cardPartnerRepository;

        public CardPartnerService(ICardPartnerRepository cardPartnerRepository)
        {
            _cardPartnerRepository = cardPartnerRepository;
        }

        public Task<BaseValidate> DeleteAsync(long? id)
        {
            return _cardPartnerRepository.DeleteAsync(id);
        }

        public Task<CommonViewInfo> GetInfoAsync(long? id)
        {
            return _cardPartnerRepository.GetInfoAsync(id);
        }

        public Task<IEnumerable<CommonValue>> GetListAsync(string projectCd)
        {
            return _cardPartnerRepository.GetListAsync(projectCd);
        }

        public Task<CommonDataPage> GetPageAsync(GridProjectFilter query)
        {
            return _cardPartnerRepository.GetPageAsync(query);
        }

        public Task<BaseValidate> SetInfoAsync(CommonViewInfo info)
        {
            return _cardPartnerRepository.SetInfoAsync(info);
        }
    }
}

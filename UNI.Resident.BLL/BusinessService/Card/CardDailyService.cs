using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardDailyService : ICardDailyService
    {
        private readonly ICardDailyRepository _repository;
        public CardDailyService(
            ICardDailyRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }
        
        public CommonViewInfo GetVehicleCardDailyFilter()
        {
            return _repository.GetVehicleCardDailyFilter();
        }
        public async Task<CommonDataPage> GetVehicleCardDailyPage(VehicleCardDailyRequestModel query)
        {
            return await _repository.GetVehicleCardDailyPage(query);
        }
        public async Task<CommonDataPage> GetVehicleHistoryChange(VehicleHistoryChange query)
        {
            return await _repository.GetVehicleHistoryChange(query);
        }

    }
}

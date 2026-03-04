using System;
using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class VehicleCardService : IVehicleCardService
    {
        private readonly IVehicleCardRepository _vehicleCardRepository;

        public VehicleCardService(IVehicleCardRepository vehicleCardRepository)
        {
            _vehicleCardRepository = vehicleCardRepository;
        }

        public Task<CommonViewInfo> GetInfoAsync(string type, long id, Guid? cardVehicleOid = null)
        {
            return _vehicleCardRepository.GetInfoAsync(type, id, cardVehicleOid);
        }

        public Task<CommonDataPage> GetPageAsync(VehicleCardFilter query)
        {
            return _vehicleCardRepository.GetPageAsync(query);
        }

        public Task<CommonViewInfo> GetTicketInfoAsync(string cardCd, long id, Guid? cardVehicleOid = null)
        {
            return _vehicleCardRepository.GetTicketInfoAsync(cardCd, id, cardVehicleOid);
        }

        public Task<BaseValidate> SetCardVehicleServiceAuthAsync(VehicleCardAuth card)
        {
            return _vehicleCardRepository.SetCardVehicleServiceAuthAsync(card);
        }

        public Task<BaseValidate> SetGuestVehicleCardInfoAsync(CommonViewInfo info)
        {
            return _vehicleCardRepository.SetGuestVehicleCardInfoAsync(info);
        }

        public Task<CommonDataPage> GetSwipeHistoryPageAsync(VehicleCardSwipeHistoryFilter filter)
        {
            return _vehicleCardRepository.GetSwipeHistoryPageAsync(filter);
        }

        public Task<CommonDataPage> GetHistoryPageAsync(VehicleCardHistoryFilter filter)
        {
            return _vehicleCardRepository.GetHistoryPageAsync(filter);
        }

        public Task<CommonDataPage> GetPaymentHistoryPageAsync(VehicleCardPaymentHistoryFilter filter)
        {
            return _vehicleCardRepository.GetPaymentHistoryPageAsync(filter);
        }
    }
}

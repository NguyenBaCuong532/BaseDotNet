using System;
using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using System.Threading.Tasks;

namespace UNI.Resident.DAL.Interfaces.Card
{
    public interface IVehicleCardRepository
    {
        Task<CommonViewInfo> GetInfoAsync(string type, long id, Guid? cardVehicleOid = null);
        Task<CommonDataPage> GetPageAsync(VehicleCardFilter query);
        Task<CommonViewInfo> GetTicketInfoAsync(string cardCd, long id, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetCardVehicleServiceAuthAsync(VehicleCardAuth card);
        Task<BaseValidate> SetGuestVehicleCardInfoAsync(CommonViewInfo info);
        Task<CommonDataPage> GetSwipeHistoryPageAsync(VehicleCardSwipeHistoryFilter filter);
        Task<CommonDataPage> GetHistoryPageAsync(VehicleCardHistoryFilter filter);
        Task<CommonDataPage> GetPaymentHistoryPageAsync(VehicleCardPaymentHistoryFilter filter);
    }
}

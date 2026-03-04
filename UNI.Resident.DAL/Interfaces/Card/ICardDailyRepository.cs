using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces.Card
{
    public interface ICardDailyRepository
    {
        #region web-apartment        
        
        CommonViewInfo GetVehicleCardDailyFilter();
        Task<CommonDataPage> GetVehicleCardDailyPage(VehicleCardDailyRequestModel query);
        Task<CommonDataPage> GetVehicleHistoryChange(VehicleHistoryChange query);
        #endregion
    }
}

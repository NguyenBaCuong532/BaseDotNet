using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Card
{
    public interface ICardDailyService
    {
        #region web-apartment        
        CommonViewInfo GetVehicleCardDailyFilter();
        Task<CommonDataPage> GetVehicleCardDailyPage(VehicleCardDailyRequestModel query);
        Task<CommonDataPage> GetVehicleHistoryChange(VehicleHistoryChange query);
        #endregion
    }
}

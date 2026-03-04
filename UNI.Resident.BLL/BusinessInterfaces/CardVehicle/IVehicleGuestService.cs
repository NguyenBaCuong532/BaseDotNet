using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.CardVehicle
{
    public interface IVehicleGuestService
    {
        // QL thẻ xe
        Task<CommonViewInfo> GetVehicleFilter();
        Task<CommonDataPage> GetVehiclePage(VehicleGuestFilter query);
        Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info);
        Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null);
        Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd);// tính gia hạn thẻ
        Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info);// cập nhật gia hạn thẻ
        Task<BaseValidate> DelVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null); // Xóa thẻ
        // xe cư dân        
        Task<BaseValidate<Stream>> GetVehicleImportTemp();
        // thẻ lượt
        Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards);
    }
}

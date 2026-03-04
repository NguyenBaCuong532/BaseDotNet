using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.CardVehicle
{
    public interface IVehicleGuestRepository
    {
        // QL thẻ xe
        Task<CommonDataPage> GetVehiclePage(VehicleGuestFilter query);
        Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info);
        Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null);//Mở/Khóa thẻ
        Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd);// tính gia hạn thẻ
        Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info);// cập nhật gia hạn thẻ
        Task<BaseValidate> DelVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null);
        // xe cư dân
        Task<CommonViewInfo> GetVehicleFilter();        
        Task<DataSet> GetVehicleCardBaseImportTemp();
        // thẻ lượt
        Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards);
    }
}

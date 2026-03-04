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
    public interface IVehicleResidentRepository
    {
        Task<CommonViewInfo> GetVehicleFilter();
        // QL thẻ xe
        Task<CommonDataPage> GetVehiclePage(ResidentVehicleRequestModel query);
        Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, VehicleCardInfo info = null, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info, string projectCd);
        Task<BaseValidate> SetVehicleLockedAsync(int CardVehicleId, int Status, Guid? cardVehicleOid = null);//Mở/Khóa thẻ
        Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd);// tính gia hạn thẻ
        Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info);// cập nhật gia hạn thẻ
        Task<BaseValidate> DeleteVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null);
        // xe cư dân        
        Task<DataSet> GetVehicleCardBaseImportTemp();
        // thẻ lượt
        Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards);
        Task<VehicleCardInfo> GetVehicleLockInfo(int? cardVehicleId, Guid? cardVehicleOid = null);

        Task<CommonViewInfo> GetCancelVehicleCardFields(int cardVehicleId, Guid? cardVehicleOid = null);

        Task<BaseValidate> SetCancelVehicleCardFields(CommonViewInfo info);
    }
}

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
    public interface IVehicleResidentService
    {
        // QL thẻ xe
        Task<CommonViewInfo> GetVehicleFilter();
        Task<CommonDataPage> GetVehiclePage(ResidentVehicleRequestModel query);
        Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, VehicleCardInfo info = null, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info, string projectCd);
        Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null);
        Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd);// tính gia hạn thẻ
        Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info);// cập nhật gia hạn thẻ
        Task<BaseValidate> DeleteVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null); // Xóa thẻ
        // xe cư dân
        Task<BaseValidate<Stream>> GetVehicleCardBaseImportTemp();
        // thẻ lượt
        Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards);
        Task<VehicleCardInfo> GetVehicleLockInfo(int? cardVehicleId, Guid? cardVehicleOid = null);

        Task<CommonViewInfo> GetCancelVehicleCardFields(int cardVehicleId, Guid? cardVehicleOid = null);

        Task<BaseValidate> SetCancelVehicleCardFields(CommonViewInfo info);
    }
}

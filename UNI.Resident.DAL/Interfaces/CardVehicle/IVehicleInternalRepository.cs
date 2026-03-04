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
    public interface IVehicleInternalRepository
    {
        // QL thẻ xe
        Task<CommonDataPage> GetVehiclePage(VehicleCardRequestModel query);
        Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info);
        Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null);//Mở/Khóa thẻ
        Task<BaseValidate> DelVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null);
        // xe cư dân
        Task<CommonViewInfo> GetVehicleFilter();
        Task<DataSet> GetVehicleImportTemp();
        // thẻ lượt
        Task<ImportListPage> SetImportVehicleAsync(CardVehicleImportSet cards);
    }
}

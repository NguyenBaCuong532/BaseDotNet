using UNI.Resident.Model.Resident;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using System;

namespace UNI.Resident.BLL.BusinessInterfaces.CardVehicle
{
    public interface IVehicleService
    {
        #region web-vehicle
        // Phương tiện thuộc căn hộ
        Task<CommonDataPage> GetApartmentVehiclePageAsync(VehicleRequestModel query);
        Task<ApartmentVehicleInfo> GetApartmentVehicleInfo(string userId, int CardVehicleId, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetApartmentVehicleInfo(viewBaseInfo info);
        Task<BaseValidate<Stream>> GetVehicleNumImportTemp();
        Task<ImportListPage> SetVehicleNumImport(string userId, VehicleNumImportSet vehicleNumImport, bool? check);
        #endregion
    }
}

using System;
using UNI.Resident.Model.Resident;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces.CardVehicle
{
    public interface IVehicleRepository
    {
        #region web-apartment

        // Phương tiện thuộc căn hộ
        Task<CommonDataPage> GetApartmentVehiclePageAsync(VehicleRequestModel query);
        Task<ApartmentVehicleInfo> GetApartmentVehicleInfo(string userId, int CardVehicleId, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetApartmentVehicleInfo(viewBaseInfo info);
        Task<ImportListPage> SetVehicleNumImport(string userId, VehicleNumImportSet vehicleNumImport, bool? check);
        #endregion
    }
}

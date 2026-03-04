using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model.Resident;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.CardVehicle
{
    public class VehicleService : IVehicleService
    {
        private readonly IVehicleRepository _repository;
        public VehicleService(
            IVehicleRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }

        // Phương tiện thuộc căn hộ
        public async Task<CommonDataPage> GetApartmentVehiclePageAsync(VehicleRequestModel query)
        {
            return await _repository.GetApartmentVehiclePageAsync(query);
        }

        public async Task<ApartmentVehicleInfo> GetApartmentVehicleInfo(string userId, int CardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.GetApartmentVehicleInfo(userId, CardVehicleId, cardVehicleOid);
        }

        public async Task<BaseValidate> SetApartmentVehicleInfo(viewBaseInfo info)
        {
            return await _repository.SetApartmentVehicleInfo(info);
        }

        public async Task<BaseValidate<Stream>> GetVehicleNumImportTemp()
        {
            try
            {
                var r = new FlexcellUtils();
                var template = await System.IO.File.ReadAllBytesAsync($"templates/vehicle/import_vehicle_num.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, new DataSet(), p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> SetVehicleNumImport(string userId, VehicleNumImportSet vehicleNumImport, bool? check)
        {
            return  _repository.SetVehicleNumImport(userId, vehicleNumImport, check);
        }
    }
}

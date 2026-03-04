using Aspose.Pdf.LogicalStructure;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.CardVehicle
{
    public class VehicleInternalService : IVehicleInternalService
    {
        private readonly IVehicleInternalRepository _repository;

        public VehicleInternalService(IVehicleInternalRepository vehicleTypeRepository)
        {
            _repository = vehicleTypeRepository;
        }

        public Task<CommonViewInfo> GetVehicleFilter()
        {
            return _repository.GetVehicleFilter();
        }
        // thẻ xe
        public async Task<CommonDataPage> GetVehiclePage(VehicleCardRequestModel query)
        {
            return await _repository.GetVehiclePage(query);
        }
        public async Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.GetVehicleInfo(CardVehicleId, cardVehicleOid);
        }

        public async Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info)
        {
            return await _repository.SetVehicleInfo(info);
        }
        public async Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null)
        {
            return await _repository.SetVehicleLocked(CardVehicleId, Status, cardVehicleOid);
        }

        public async Task<BaseValidate> DelVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.DelVehicleInfo(cardVehicleId, cardVehicleOid);
        }

        public async Task<BaseValidate<Stream>> GetVehicleImportTemp()
        {
            try
            {
                var ds = await _repository.GetVehicleImportTemp();
                var r = new FlexcellUtils();
                var template = await File.ReadAllBytesAsync($"templates/cards/import_vehicle_card.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, ds, p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }
        public Task<ImportListPage> SetImportVehicleAsync(CardVehicleImportSet cards)
        {
            return _repository.SetImportVehicleAsync(cards);
        }
    }
}

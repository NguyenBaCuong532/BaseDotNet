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
    public class VehicleResidentService : IVehicleResidentService
    {
        private readonly IVehicleResidentRepository _repository;

        public VehicleResidentService(IVehicleResidentRepository vehicleTypeRepository)
        {
            _repository = vehicleTypeRepository;
        }

        public Task<CommonViewInfo> GetVehicleFilter()
        {
            return _repository.GetVehicleFilter();
        }
        // thẻ xe
        public async Task<CommonDataPage> GetVehiclePage(ResidentVehicleRequestModel query)
        {
            return await _repository.GetVehiclePage(query);
        }
        public async Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, VehicleCardInfo info = null, Guid? cardVehicleOid = null)
        {
            return await _repository.GetVehicleInfo(CardVehicleId, info, cardVehicleOid);
        }

        public async Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info, string projectCd)
        {
            return await _repository.SetVehicleInfo(info, projectCd);
        }
        public async Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null)
        {
            return await _repository.SetVehicleLockedAsync(CardVehicleId, Status, cardVehicleOid);
        }

        public async Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd)
        {
            return await _repository.GetVehiclePaymentByDayInfoAsync(CardVehicleId, StartDate, EndDate, ProjectCd);
        }

        public async Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info)
        {
            return await _repository.SetVehiclePaymentByDayInfoAsync(info);
        }

        public async Task<BaseValidate> DeleteVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.DeleteVehicleInfo(cardVehicleId, cardVehicleOid);
        }

        public async Task<BaseValidate<Stream>> GetVehicleCardBaseImportTemp()
        {
            try
            {
                var ds = await _repository.GetVehicleCardBaseImportTemp();
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
        public Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards)
        {
            return _repository.ImportVehicleAsync(cards);
        }

        public async Task<VehicleCardInfo> GetVehicleLockInfo(int? cardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.GetVehicleLockInfo(cardVehicleId, cardVehicleOid);
        }

        /// <summary>
        /// Thông tin hủy thẻ xe
        /// </summary>
        /// <param name="cardVehicleId"></param>
        /// <returns></returns>
        public async Task<CommonViewInfo> GetCancelVehicleCardFields(int cardVehicleId, Guid? cardVehicleOid = null)
            => await _repository.GetCancelVehicleCardFields(cardVehicleId, cardVehicleOid);

        /// <summary>
        /// Lưu thông tin hủy thẻ xe
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetCancelVehicleCardFields(CommonViewInfo info)
            => await _repository.SetCancelVehicleCardFields(info);
    }
}

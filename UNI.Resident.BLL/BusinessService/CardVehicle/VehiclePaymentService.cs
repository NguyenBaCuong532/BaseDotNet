using UNI.Model;
using UNI.Resident.Model.VehiclePayment;
using UNI.Resident.Model.Common;
using System;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.DAL.Interfaces.CardVehicle;

namespace UNI.Resident.BLL.BusinessService.CardVehicle
{
    public class VehiclePaymentService : IVehiclePaymentService
    {
        private readonly IVehiclePaymentRepository _repository;

        public VehiclePaymentService(IVehiclePaymentRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }

        #region Vehicle Payment Management

        public async Task<CommonDataPage> GetPageAsync(VehiclePaymentRequestModel query)
        {
            return await _repository.GetPageAsync(query);
        }

        public async Task<VehiclePaymentInfo> GetInfoAsync(Guid? paymentId, int? cardVehicleId = null, Guid? cardVehicleOid = null)
        {
            return await _repository.GetInfoAsync(paymentId, cardVehicleId, cardVehicleOid);
        }

        public async Task<VehiclePaymentInfo> SetDraftAsync(VehiclePaymentInfo draft)
        {
            return await _repository.SetDraftAsync(draft);
        }

        public async Task<BaseValidate> SetInfoAsync(VehiclePaymentInfo info)
        {
            return await _repository.SetInfoAsync(info);
        }

        public async Task<BaseValidate> DeleteAsync(Guid paymentId)
        {
            return await _repository.DeleteAsync(paymentId);
        }

        public async Task<BaseValidate> SetApproveAsync(VehiclePaymentApproveModel approve)
        {
            return await _repository.SetApproveAsync(approve);
        }

        #endregion
    }
}



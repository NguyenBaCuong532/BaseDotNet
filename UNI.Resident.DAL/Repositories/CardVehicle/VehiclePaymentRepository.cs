using DapperParameters;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model.VehiclePayment;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Repositories.CardVehicle
{
    public class VehiclePaymentRepository : UniBaseRepository, IVehiclePaymentRepository
    {
        public VehiclePaymentRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        #region Vehicle Payment Management

        public async Task<CommonDataPage> GetPageAsync(VehiclePaymentRequestModel query)
        {
            const string storedProcedure = "sp_res_vehicle_payment_page";
            return await GetDataListPageAsync(storedProcedure, query, new { 
                query.CardVehicleId,
                query.PaymentStatus,
                query.ProjectCd,
                query.ApartmentId,
                query.FromDate,
                query.ToDate
            });
        }

        public async Task<VehiclePaymentInfo> GetInfoAsync(Guid? paymentId, int? cardVehicleId = null, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_payment_fields";
            return await GetFieldsAsync<VehiclePaymentInfo>(storedProcedure, new { paymentId, cardVehicleId, cardVehicleOid });
        }

        public async Task<VehiclePaymentInfo> SetDraftAsync(VehiclePaymentInfo draft)
        {
            const string storedProcedure = "sp_res_vehicle_payment_draft";
            return await base.SetInfoAsync<VehiclePaymentInfo>(storedProcedure, draft, 
                param => { 
                param.Add("@cardVehicleId", draft.CardVehicleId);
                param.Add("@paymentId", draft.PaymentId);
                return param;
            });
        }

        public async Task<BaseValidate> SetInfoAsync(VehiclePaymentInfo info)
        {
            const string storedProcedure = "sp_res_vehicle_payment_set";
            return await SetInfoAsync(storedProcedure, info, new { 
                paymentId = info.PaymentId,
                cardVehicleId = info.CardVehicleId
            });
        }

        public async Task<BaseValidate> DeleteAsync(Guid paymentId)
        {
            const string storedProcedure = "sp_res_vehicle_payment_del";
            return await DeleteAsync(storedProcedure, new { paymentId });
        }

        public async Task<BaseValidate> SetApproveAsync(VehiclePaymentApproveModel approve)
        {
            const string storedProcedure = "sp_res_vehicle_payment_approve";
            return await SetAsync(storedProcedure, new { 
                approve.PaymentId,
                approve.PaymentStatus,
                approve.ApprovedNote
            });
        }

        #endregion
    }
}



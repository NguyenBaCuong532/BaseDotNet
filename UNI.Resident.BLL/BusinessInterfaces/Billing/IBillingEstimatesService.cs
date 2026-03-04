using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IBillingEstimatesService : IUniBaseService
    {
        Task<CommonViewInfo> GetBillingEstimatesFilter();

        Task<CommonDataPage> GetBillingEstimatesPage(ServiceExpectedRequestModel query);

        Task<viewBaseInfo> GetBillingEstimatesFields(int? receiveId);

        Task<BaseValidate> SetBillingEstimates(CommonViewInfo inputData);

        Task<BaseValidate> SetBillingEstimatesDelete(List<Guid> arrOid);

        Task<ServiceExpectedCalculatorInfo> GetBillingEstimatesCalculatorFields(Guid periodsOid, int? ApartmentId);

        Task<BaseValidate> SetBillingEstimatesCalculatorFields(ServiceExpectedCalculatorInfo info);

        Task<CommonDataPage> GetBillingEstimatesExpectedFeePage(ServiceExpectedFeeRequestModel query);

        Task<ServiceExpectedLivingPage> GetBillingEstimatesExpectedLivingPage(ServiceExpectedLivingRequestModel query);

        Task<CommonDataPage> GetBillingEstimatesExpectedVehiclePage(ServiceExpectedVehicleRequestModel query);

        Task<CommonDataPage> GetBillingEstimatesExpectedExtendPage(ServiceExpectedExtendRequestModel query);

        Task<viewBaseInfo> GetBillingEstimatesExpectedExtendFields(int receiveId);

        Task<BaseValidate> SetBillingEstimatesExpectedExtendFields(CommonViewInfo inputData);

        Task<CommonDataPage> GetBillingEstimatesExpectedDebtPage(ServiceExpectedExtendRequestModel query);
    }
}
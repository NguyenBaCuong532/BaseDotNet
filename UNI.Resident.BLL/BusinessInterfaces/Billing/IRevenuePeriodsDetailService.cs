using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IRevenuePeriodsDetailService : IUniBaseService
    {
        Task<CommonViewInfo> GetServiceReceivableFilter();

        Task<CommonDataPage> GetServiceReceivablePage(ServiceExpectedRequestModel filter);

        Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId);

        Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? apartmentId, Guid? revenuePeriodId = null, ServiceExpectedCalculatorInfo info = null);

        Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info);
    }
}
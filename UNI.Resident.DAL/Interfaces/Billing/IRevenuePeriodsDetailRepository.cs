using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IRevenuePeriodsDetailRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServiceReceiveEntryFilter();

        Task<CommonDataPage> GetServiceReceivablePage(ServiceExpectedRequestModel filter);

        Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId);

        Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? apartmentId, Guid? revenuePeriodId = null, ServiceExpectedCalculatorInfo info = null);

        Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info);
    }
}
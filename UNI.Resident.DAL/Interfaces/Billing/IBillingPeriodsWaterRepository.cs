using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IBillingPeriodsWaterRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetBillingPeriodsWaterFilter();

        Task<CommonDataPage> GetBillingPeriodsWaterPage(ServiceLivingMeterRequestModel query);

        Task<ServiceLivingMeterInfo> GetBillingPeriodsWaterFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null);

        Task<BaseValidate> SetBillingPeriodsWater(ServiceLivingMeterInfo info);

        Task<BaseValidate> SetBillingPeriodsWaterDelete(DeleteMultiServiceLivingMeter inputParam);

        Task<ImportListPage> SetBillingPeriodsWaterImport(LivingImportSet importSet, bool? check);

        Task<BaseValidate> SetBillingPeriodsWaterCalculate(int trackingId, string projectCd, int livingType, int periodMonth, int periodYear);

        Task<BaseValidate> SetBillingPeriodsWaterCalculateAll(ServiceLivingMeterCalculatorInfo info);
    }
}
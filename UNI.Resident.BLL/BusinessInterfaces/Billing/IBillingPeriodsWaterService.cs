using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IBillingPeriodsWaterService : IUniBaseService
    {
        Task<CommonViewInfo> GetBillingPeriodsWaterFilter();

        Task<CommonDataPage> GetBillingPeriodsWaterPage(ServiceLivingMeterRequestModel filter);

        Task<ServiceLivingMeterInfo> GetBillingPeriodsWaterFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null);

        Task<BaseValidate> SetBillingPeriodsWater(ServiceLivingMeterInfo inputData);

        Task<BaseValidate> SetBillingPeriodsWaterDelete(DeleteMultiServiceLivingMeter inputParam);

        Task<BaseValidate<Stream>> GetBillingPeriodsWaterImportTemp(int livingTypeId);

        Task<ImportListPage> SetBillingPeriodsWaterImport(LivingImportSet organizes, bool? check);

        Task<BaseValidate> SetBillingPeriodsWaterCalculate(int trackingId, string projectCd, int livingType, int periodMonth, int periodYear);

        Task<BaseValidate> SetBillingPeriodsWaterCalculateAll(ServiceLivingMeterCalculatorInfo info);
    }
}
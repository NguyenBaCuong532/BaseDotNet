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
    public interface IBillingPeriodsElectricService : IUniBaseService
    {
        Task<CommonViewInfo> GetBillingPeriodsElectricFilter();

        Task<CommonDataPage> GetBillingPeriodsElectricPage(ServiceLivingMeterRequestModel filter);

        Task<viewBaseInfo> GetBillingPeriodsElectricFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null);

        Task<BaseValidate> SetBillingPeriodsElectric(ServiceLivingMeterInfo info);

        Task<BaseValidate> SetBillingPeriodsElectricDelete(DeleteMultiServiceLivingMeter inputParam);

        Task<BaseValidate<Stream>> GetBillingPeriodsElectricImportTemp(int livingTypeId);

        Task<ImportListPage> SetBillingPeriodsElectricImport(LivingImportSet organizes, bool? check);

        Task<ServiceLivingMeterCalculatorInfo> GetBillingPeriodsElectricCalculatorFields(Guid periodsOid, int trackingId);

        Task<BaseValidate> SetBillingPeriodsElectricCalculate(int trackingId, string projectCd, int livingType, int periodMonth, int periodYear);

        Task<BaseValidate> SetBillingPeriodsElectricCalculateAll(ServiceLivingMeterCalculatorInfo info);
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IBillingPeriodsElectricRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetBillingPeriodsElectricFilter();

        Task<CommonDataPage> GetBillingPeriodsElectricPage(ServiceLivingMeterRequestModel query);

        Task<viewBaseInfo> GetBillingPeriodsElectricFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null);

        Task<BaseValidate> SetBillingPeriodsElectric(ServiceLivingMeterInfo info);

        Task<BaseValidate> SetBillingPeriodsElectricDelete(DeleteMultiServiceLivingMeter inputParam);

        Task<ImportListPage> SetBillingPeriodsElectricImport(LivingImportSet importSet, bool? check);

        Task<ServiceLivingMeterCalculatorInfo> GetBillingPeriodsElectricCalculatorFields(Guid periodsOid, int trackingId);

        Task<BaseValidate> SetBillingPeriodsElectricCalculate(int trackingId, string projectCd, int livingType, int periodMonth, int periodYear);

        Task<BaseValidate> SetBillingPeriodsElectricCalculateAll(ServiceLivingMeterCalculatorInfo info);
    }
}
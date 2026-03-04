using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IBillingPeriodsService : IUniBaseService
    {
        Task<CommonViewInfo> GetBillingPeriodsFilter();

        Task<CommonDataPage> GetBillingPeriodsPage(BillingPeriodsFilter filter);

        Task<viewBaseInfo> GetBillingPeriodsFields(Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetBillingPeriods(CommonViewInfo inputData);

        Task<BaseValidate> SetBillingPeriodsDelete(List<Guid> arrOid);

        Task<List<CommonValue>> GetBillingPeriodsStatusList();

        /// <summary>
        /// Khóa/mở khóa kỳ thanh toán
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        Task<BaseValidate> SetBillingPeriodsLock(BillingPeriods_SetLocked inputParam);
    }
}
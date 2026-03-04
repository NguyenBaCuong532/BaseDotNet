using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IRevenuePeriodsService : IUniBaseService
    {
        Task<CommonViewInfo> GetRevenuePeriodsFilter();

        Task<CommonDataPage> GetRevenuePeriodsPage(RevenuePeriodsFilter filter);

        Task<viewBaseInfo> GetRevenuePeriodsFields(Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetRevenuePeriods(CommonViewInfo inputData);

        Task<BaseValidate> SetRevenuePeriodsLocked(RevenuePeriodsSetLocked inputParam);

        Task<BaseValidate> SetRevenuePeriodsDelete(List<Guid> arrOid);
    }
}
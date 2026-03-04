using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IRevenuePeriodsRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetRevenuePeriodsFilter();

        Task<CommonDataPage> GetRevenuePeriodsPage(RevenuePeriodsFilter filter);

        Task<viewBaseInfo> GetRevenuePeriodsFields(Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetRevenuePeriods(CommonViewInfo inputData);

        Task<BaseValidate> SetRevenuePeriodsLocked(RevenuePeriodsSetLocked inputParam);

        Task<BaseValidate> SetRevenuePeriodsDelete(List<Guid> arrOid);
    }
}
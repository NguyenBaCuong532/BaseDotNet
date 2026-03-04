using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IPaymentPriorityConfigsRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetPaymentPriorityConfigsFilter();

        Task<CommonDataPage> GetPaymentPriorityConfigsPage(FilterBase filter);

        Task<viewBaseInfo> GetPaymentPriorityConfigsFields(Guid? oid);

        Task<BaseValidate> SetPaymentPriorityConfigs(CommonViewInfo inputData);

        Task<BaseValidate> SetPaymentPriorityConfigsDelete(List<Guid> arrOid);
    }
}
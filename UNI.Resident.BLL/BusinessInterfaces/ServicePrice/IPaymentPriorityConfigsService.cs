using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IPaymentPriorityConfigsService : IUniBaseService
    {
        Task<CommonViewInfo> GetPaymentPriorityConfigsFilter();

        Task<CommonDataPage> GetPaymentPriorityConfigsPage(FilterBase filter);

        Task<viewBaseInfo> GetPaymentPriorityConfigsFields(Guid? oid);

        Task<BaseValidate> SetPaymentPriorityConfigs(CommonViewInfo inputData);

        Task<BaseValidate> SetPaymentPriorityConfigsDelete(List<Guid> arrOid);
    }
}
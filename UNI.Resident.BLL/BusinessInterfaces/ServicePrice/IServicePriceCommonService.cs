using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceCommonService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceCommonFilter();

        Task<CommonDataPage> GetServicePriceCommonPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceCommonFields(Guid? oid);

        Task<BaseValidate> SetServicePriceCommon(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceCommonDelete(List<Guid> arrOid);
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceWaterService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceWaterFilter();

        Task<CommonDataPage> GetServicePriceWaterPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceWaterFields(Guid? oid, bool? isCopy = null);

        Task<BaseValidate> SetServicePriceWater(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceWaterDelete(List<Guid> arrOid);
    }
}
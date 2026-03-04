using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceWaterDetailService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceWaterDetailFilter();

        Task<CommonDataPage> GetServicePriceWaterDetailPage(ServicePriceWaterDetailFilter filter);

        Task<viewBaseInfo> GetServicePriceWaterDetailFields(Guid waterOid, Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetServicePriceWaterDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceWaterDetailDelete(List<Guid> arrOid);
    }
}
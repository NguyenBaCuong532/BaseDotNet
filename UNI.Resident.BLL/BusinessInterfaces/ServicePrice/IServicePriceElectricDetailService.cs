using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceElectricDetailService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceElectricDetailFilter();

        Task<CommonDataPage> GetServicePriceElectricDetailPage(ServicePriceElectricDetailFilter filter);

        Task<viewBaseInfo> GetServicePriceElectricDetailFields(Guid electricOid, Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetServicePriceElectricDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceElectricDetailDelete(List<Guid> arrOid);
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceElectricService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceElectricFilter();

        Task<CommonDataPage> GetServicePriceElectricPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceElectricFields(Guid? oid, bool? isCopy = null);

        Task<BaseValidate> SetServicePriceElectric(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceElectricDelete(List<Guid> arrOid);
    }
}
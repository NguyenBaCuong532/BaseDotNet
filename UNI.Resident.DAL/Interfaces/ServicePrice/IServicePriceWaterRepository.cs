using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceWaterRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceWaterFilter();

        Task<CommonDataPage> GetServicePriceWaterPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceWaterFields(Guid? oid, bool? isCopy = null);

        Task<BaseValidate> SetServicePriceWater(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceWaterDelete(List<Guid> arrOid);
    }
}
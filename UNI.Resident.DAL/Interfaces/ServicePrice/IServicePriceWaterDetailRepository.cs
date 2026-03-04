using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceWaterDetailRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceWaterDetailFilter();

        Task<CommonDataPage> GetServicePriceWaterDetailPage(ServicePriceWaterDetailFilter filter);

        Task<viewBaseInfo> GetServicePriceWaterDetailFields(Guid waterOid, Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetServicePriceWaterDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceWaterDetailDelete(List<Guid> arrOid);
    }
}
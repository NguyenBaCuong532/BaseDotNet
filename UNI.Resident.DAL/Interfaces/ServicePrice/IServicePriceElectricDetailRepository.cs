using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceElectricDetailRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceElectricDetailFilter();

        Task<CommonDataPage> GetServicePriceElectricDetailPage(ServicePriceElectricDetailFilter filter);

        Task<viewBaseInfo> GetServicePriceElectricDetailFields(Guid electricOid, Guid? oid, CommonViewInfo inputData = null);

        Task<BaseValidate> SetServicePriceElectricDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceElectricDetailDelete(List<Guid> arrOid);
    }
}
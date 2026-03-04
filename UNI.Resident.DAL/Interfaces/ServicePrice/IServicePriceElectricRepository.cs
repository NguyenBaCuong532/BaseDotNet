using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceElectricRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceElectricFilter();

        Task<CommonDataPage> GetServicePriceElectricPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceElectricFields(Guid? oid, bool? isCopy = null);

        Task<BaseValidate> SetServicePriceElectric(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceElectricDelete(List<Guid> arrOid);
    }
}
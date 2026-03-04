using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceMaintenanceService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceMaintenanceFilter();

        Task<CommonDataPage> GetServicePriceMaintenancePage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceMaintenanceFields(Guid? oid);

        Task<BaseValidate> SetServicePriceMaintenance(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceMaintenanceDelete(List<Guid> arrOid);
    }
}
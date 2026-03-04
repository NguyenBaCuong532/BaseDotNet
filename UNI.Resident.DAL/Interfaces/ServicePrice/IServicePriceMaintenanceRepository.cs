using System;
using System.Threading.Tasks;
using UNI.Model;
using System.Collections.Generic;
using UNI.Common.CommonBase;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceMaintenanceRepository : IUniBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceMaintenanceFilter();

        Task<CommonDataPage> GetServicePriceMaintenancePage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceMaintenanceFields(Guid? oid);

        Task<BaseValidate> SetServicePriceMaintenance(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceMaintenanceDelete(List<Guid> arrOid);
    }
}
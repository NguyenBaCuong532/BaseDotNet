using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceVehicleDailyDetailService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceVehicleDailyDetailFilter();

        Task<CommonDataPage> GetServicePriceVehicleDailyDetailPage(ServicePriceVehicleDailyDetailTypeFilter filter);

        Task<viewBaseInfo> GetServicePriceVehicleDailyDetailFields(Guid vehicleDailyOid, Guid? oid);

        Task<BaseValidate> SetServicePriceVehicleDailyDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceVehicleDailyDetailDelete(List<Guid> arrOid);
    }
}
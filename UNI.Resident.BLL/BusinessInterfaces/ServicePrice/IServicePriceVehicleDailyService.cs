using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceVehicleDailyService : IUniBaseService
    {
        Task<CommonViewInfo> GetServicePriceVehicleDailyFilter();

        Task<CommonDataPage> GetServicePriceVehicleDailyPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceVehicleDailyFields(Guid? oid);

        Task<BaseValidate> SetServicePriceVehicleDaily(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceVehicleDailyDelete(List<Guid> arrOid);
    }
}
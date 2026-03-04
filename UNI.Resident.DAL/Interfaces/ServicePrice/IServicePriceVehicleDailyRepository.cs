using System;
using System.Threading.Tasks;
using UNI.Model;
using System.Collections.Generic;
using UNI.Common.CommonBase;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceVehicleDailyRepository : IUniBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceVehicleDailyFilter();

        Task<CommonDataPage> GetServicePriceVehicleDailyPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceVehicleDailyFields(Guid? oid);

        Task<BaseValidate> SetServicePriceVehicleDaily(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceVehicleDailyDelete(List<Guid> arrOid);
    }
}
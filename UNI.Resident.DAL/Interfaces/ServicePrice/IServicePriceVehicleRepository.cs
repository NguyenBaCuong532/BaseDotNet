using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceVehicleRepository : IUniBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceVehicleFilter();

        Task<CommonDataPage> GetServicePriceVehiclePage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceVehicleFields(Guid? oid);

        Task<BaseValidate> SetServicePriceVehicle(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceVehicleDelete(List<Guid> arrOid);

        Task<List<CommonValue>> GetServicePriceVehicleTypeForDropdownList([FromQuery] string filter);

        Task<List<CommonValue>> GetServicePriceVehicleDailyTypeForDropdownList([FromQuery] string filter);
    }
}
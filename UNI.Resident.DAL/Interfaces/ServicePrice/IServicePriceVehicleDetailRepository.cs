using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceVehicleDetailRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceVehicleDetailFilter();

        Task<CommonDataPage> GetServicePriceVehicleDetailPage(ServicePriceVehicleDetailFilter filter);

        Task<viewBaseInfo> GetServicePriceVehicleDetailFields(Guid vehicleOid, Guid? oid);

        Task<BaseValidate> SetServicePriceVehicleDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceVehicleDetailDelete(List<Guid> arrOid);
    }
}
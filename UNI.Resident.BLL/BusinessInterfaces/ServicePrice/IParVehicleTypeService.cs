using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IParVehicleTypeService : IUniBaseService
    {
        Task<CommonViewInfo> GetParVehicleTypeFilter();

        Task<CommonDataPage> GetParVehicleTypePage(FilterBase filter);

        Task<viewBaseInfo> GetParVehicleTypeFields(Guid? oid);

        Task<BaseValidate> SetParVehicleType(CommonViewInfo inputData);

        Task<BaseValidate> SetParVehicleTypeDelete(List<Guid> arrOid);

        Task<List<CommonValue>> GetParVehicleTypeIdForDropdownList(Guid? oid);
    }
}
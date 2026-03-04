using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IParVehicleTypeRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetParVehicleTypeFilter();

        Task<CommonDataPage> GetParVehicleTypePage(FilterBase filter);

        Task<viewBaseInfo> GetParVehicleTypeFields(Guid? oid);

        Task<BaseValidate> SetParVehicleType(CommonViewInfo inputData);

        Task<BaseValidate> SetParVehicleTypeDelete(List<Guid> arrOid);

        Task<List<CommonValue>> GetParVehicleTypeIdForDropdownList(Guid? oid);
    }
}
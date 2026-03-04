using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.Parking
{
    public interface IParkingSpaceRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetParkingSpaceFilter();

        Task<CommonDataPage> GetParkingSpacePage(FilterBase filter);

        Task<viewBaseInfo> GetParkingSpaceFields(Guid? oid);

        Task<BaseValidate> SetParkingSpace(CommonViewInfo inputData);

        Task<BaseValidate> SetParkingSpaceDelete(List<Guid> arrOid);
    }
}
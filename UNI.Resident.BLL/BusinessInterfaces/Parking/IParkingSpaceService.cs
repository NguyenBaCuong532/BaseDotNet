using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.Parking
{
    public interface IParkingSpaceService : IUniBaseService
    {
        Task<CommonViewInfo> GetParkingSpaceFilter();

        Task<CommonDataPage> GetParkingSpacePage(FilterBase filter);

        Task<viewBaseInfo> GetParkingSpaceFields(Guid? oid);

        Task<BaseValidate> SetParkingSpace(CommonViewInfo inputData);

        Task<BaseValidate> SetParkingSpaceDelete(List<Guid> arrOid);
    }
}
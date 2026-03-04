using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.Request
{
    public interface IServiceTypeRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetServiceTypeFilter();

        Task<CommonDataPage> GetServiceTypePage(FilterBase filter);

        Task<viewBaseInfo> GetServiceTypeFields(Guid? oid);

        Task<BaseValidate> SetServiceType(CommonViewInfo inputData);

        Task<BaseValidate> SetServiceTypeDelete(List<Guid> arrOid);
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.Request
{
    public interface IServiceTypeService : IUniBaseService
    {
        Task<CommonViewInfo> GetServiceTypeFilter();

        Task<CommonDataPage> GetServiceTypePage(FilterBase filter);

        Task<viewBaseInfo> GetServiceTypeFields(Guid? oid);

        Task<BaseValidate> SetServiceType(CommonViewInfo inputData);

        Task<BaseValidate> SetServiceTypeDelete(List<Guid> arrOid);
    }
}
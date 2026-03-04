using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Request;

namespace UNI.Resident.BLL.BusinessInterfaces.Request
{
    public interface ISupportServiceUsersService : IUniBaseService
    {
        Task<CommonViewInfo> GetsupportServiceUsersFilter();

        Task<CommonDataPage> GetsupportServiceUsersPage(SupportServiceUsersFilter filter);

        Task<viewBaseInfo> GetsupportServiceUsersFields(Guid? oid = null, viewBaseInfo inputData = null);

        Task<BaseValidate> SetsupportServiceUsers(CommonViewInfo inputData);

        Task<BaseValidate> SetsupportServiceUsersDelete(List<Guid> arrOid);
    }
}

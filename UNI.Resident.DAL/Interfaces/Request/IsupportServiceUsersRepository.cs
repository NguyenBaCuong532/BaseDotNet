using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Request;

namespace UNI.Resident.DAL.Interfaces.Request
{
    public interface ISupportServiceUsersRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetsupportServiceUsersFilter();

        Task<CommonDataPage> GetsupportServiceUsersPage(SupportServiceUsersFilter filter);

        Task<viewBaseInfo> GetsupportServiceUsersFields(Guid? oid = null, viewBaseInfo inputData = null);

        Task<BaseValidate> SetsupportServiceUsers(CommonViewInfo inputData);

        Task<BaseValidate> SetsupportServiceUsersDelete(List<Guid> arrOid);
    }
}

using UNI.Model;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using UNI.Resident.Model.Resident;
using UNI.Model.Audit;

namespace UNI.Resident.DAL.Interfaces
{
    public interface IUserConfigRepository
    {
        Task<BaseValidate> SetUserConfig(string userid, string categoryIds);

        Task<List<CommonValue>> GetOrganizeses(bool? isAll);
        Task<BaseValidate> setUserProdAsync(UserProdCms profile);
        Task<List<CommonValue>> GetWorkplaces(Guid? orgId);
        Task<List<TreeNodeSingle>> GetCategosies(Guid? orgId);
        Task<CommonDataPage> GetAllUsersAsync(UserFilter flt);
        Task<List<CommonValue>> GetUserList(string userIds, string filter);
    }
}

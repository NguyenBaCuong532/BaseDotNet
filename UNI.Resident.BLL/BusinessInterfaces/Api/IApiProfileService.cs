using Keycloak.Net.Models.Users;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.KecloakTemplate.Api;

namespace UNI.Resident.BLL.BusinessInterfaces.Api
{
    public interface IApiProfileService
    {
        Task<tplApi<tplUserProfile>> GetUserProfile(string accessToken);
        Task<BaseResponse<List<UserOrgShort>>> GetListEmp(string accessToken, string orgId, string emp_code);
        Task<IEnumerable<User>> GetUsers(string userId, string search, int offset, int size);
        Task<bool> AddUser(string userId, User user);
        Task<bool> UpdateUser(string userId, User user);
        Task<User> GetUserById(string id);
        Task<User> GetUserByUserName(string userName);
        Task<bool> ResetUserPassword(string userId, string password, bool temporary);
        Task<bool> DelUser(string userId);
        Task<bool> SetUserStatus(string userId, bool status);
        Task<bool> AssignRolesToUserAsync(string userId, string roleNamesCsv);
    }
}

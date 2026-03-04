using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Account;
using UNI.Model.APPM;

namespace UNI.Resident.BLL.BusinessInterfaces
{
    /// <summary>
    /// Interface IUserService
    /// <author>Tai NT</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public interface IUserService
    {
        Task<UsersInfo> GetUserInfoAsync(string userId);
        Task<BaseValidate> SetUserInfoAsync(UsersInfo info);
        Task<BaseValidate> DeleteUserAsync(string userId);
        Task<bool> AuthenticateAdminAsync(string userId);        
        //Task<ObjectResult> SetUser(UserSync user);        
        //Task<IdentityUser> FindUserByName(string userName);        
        //Task<ObjectResult> SetCreateAuthenRole(string userName, string roler);
        //Task<ObjectResult> SetCreateAuthenUser(RegisterUserModel user);
        //Task<List<FeedbackType>> GetFeedbackType(BaseCtrlClient client);        
        //Task<ResponseList<List<FeedbackGet>>> GetFeedbackList(FilterInputProject filter);        
        Task<string> GetUserProject(string userId);
        //Task<List<ProjectBase>> GetProjectList(string userId);
        
    }
}

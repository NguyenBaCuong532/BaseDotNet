using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;

namespace UNI.Resident.DAL.Interfaces
{

    public interface IUserRepository
    {
        Task<UsersInfo> GetUserInfoAsync(string userId);
        Task<BaseValidate> SetUserInfoAsync(UsersInfo info);
        Task<BaseValidate> DeleteUserAsync(string userId);
        Task<bool> AuthenticateAdminAsync(string userId);        
        //Task SetUser(UserMdSet user);
        
        //Task<List<FeedbackType>> GetFeedbackType(BaseCtrlClient client);        
        //Task<ResponseList<List<FeedbackGet>>> GetFeedbackList(FilterInputProject filter);
        
        Task<List<string>> GetUserCategories(bool isProject);
        //Task<List<ProjectBase>> GetProjectList(string userId);
        

    }
}

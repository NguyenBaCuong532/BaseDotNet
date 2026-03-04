using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories
{
    /// <summary>
    /// User Repository
    /// </summary>
    /// Author: taint
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="IUserRepository" />
    public class UserRepository : UniBaseRepository, IUserRepository
    {
        public UserRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        #region User
        public async Task<bool> AuthenticateAdminAsync(string userId)
        {
            const string storedProcedure = "sp_res_auth_admin";
            return await GetFirstOrDefaultAsync<bool>(storedProcedure, new { userId });
        }
        public async Task<UsersInfo> GetUserInfoAsync(string userId)
        {
            const string storedProcedure = "sp_res_user_profile_fields";
            return await GetFieldsAsync<UsersInfo>(storedProcedure, new { userId });
        }
        public async Task<BaseValidate> SetUserInfoAsync(UsersInfo info)
        {
            const string storedProcedure = "sp_res_user_profile_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { ApartmentId = info.userId });
        }
        public async Task<BaseValidate> DeleteUserAsync(string userId)
        {
            const string storedProcedure = "sp_res_user_profile_del";
            return await DeleteAsync(storedProcedure, new { UserId = userId });
        }
        //public async Task SetUser(UserMdSet user)
        //{
        //    const string storedProcedure = "sp_res_insert_user";
        //    await SetAsync(storedProcedure, user);
        //}
        //public async Task<List<FeedbackType>> GetFeedbackType(BaseCtrlClient client)
        //{
        //    const string storedProcedure = "sp_res_user_feedback_types";
        //    return await GetListAsync<FeedbackType>(storedProcedure, new { client.ClientId });
        //}
        //public async Task<ResponseList<List<FeedbackGet>>> GetFeedbackList(FilterInputProject filter)
        //{
        //    const string storedProcedure = "sp_res_user_feedback_by_manager";
        //    var param = new Dapper.DynamicParameters();
        //    param.Add("@UserId", filter.userId);
        //    param.Add("@ClientId", filter.clientId);
        //    param.Add("@projectCd", filter.projectCd);
        //    param.Add("@filter", filter.filter);
        //    param.Add("@Offset", filter.offSet);
        //    param.Add("@PageSize", filter.pageSize);
        //    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
        //    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
        //    var fdlist = await GetListAsync<FeedbackGet>(storedProcedure, param); 
        //    return new ResponseList<List<FeedbackGet>>(fdlist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
        //}
        public async Task<List<string>> GetUserCategories(bool isProject)
        {
            const string storedProcedure = "sp_res_user_categories_fields";
            return await GetListAsync<string>(storedProcedure, new { isProject });
        }
        //public async Task<List<ProjectBase>> GetProjectList(string userId)
        //{
        //    const string storedProcedure = "sp_res_user_project_page";
        //    return await GetListAsync<ProjectBase>(storedProcedure, new { userId });
        //}
        #endregion User
    }
}

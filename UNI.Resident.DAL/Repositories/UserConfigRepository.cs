using DapperParameters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories
{
    public class UserConfigRepository : UniBaseRepository, IUserConfigRepository
    {
        public UserConfigRepository(IUniCommonBaseRepository commonBaseInfo) : base(commonBaseInfo)
        {
        }
        public async Task<BaseValidate> SetUserConfig(string userid, string categoryIds)
        {
            const string storedProcedure = "sp_res_user_config_set";
            return await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { userid, categoryIds });
        }
        public async Task<BaseValidate> setUserProdAsync(UserProdCms profile)
        {
            const string storedProcedure = "sp_user_prod_async";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("@usersync", base.CommonInfo.UserId);
                param.Add("userId", profile.userId);
                param.Add("userName", profile.userName);
                param.Add("fullName", profile.fullName);
                param.Add("email", profile.email);
                param.Add("phone", profile.phone);
                param.Add("active", profile.active);
                param.Add("admin_st", profile.admin_st);
                param.Add("emp_code", profile.emp_code);
                param.Add("orgId", profile.orgId);
                param.Add("workplaces", profile.workplaces);
                param.Add("categoryIds", profile.categoryIds);
                param.Add("role_sync", profile.role_sync);
                param.Add("webId", profile.webId);
                //param.AddTable("@tbOrgs", "UserCategoryType", profile.categories);
                return param;
            });
        }
        public async Task<List<CommonValue>> GetWorkplaces(Guid? orgId)
        {
            const string storedProcedure = "sp_user_project_list";
            return await base.GetListAsync<CommonValue>(storedProcedure, new { orgId });
        }
        public async Task<List<TreeNodeSingle>> GetCategosies(Guid? orgId)
        {
            const string storedProcedure = "sp_user_project_trees";
            return await base.GetMultipleAsync(storedProcedure, param =>
            {
                param.Add("@parentId", orgId);
                //param.Add("@webId", webId);
                param.Add("@rootId", null, DbType.Guid, ParameterDirection.InputOutput);
                return param;
            }, result =>
            {
                var items = result.Read<TreeNodeSingle>().ToList();
                items.ForEach(i => i.Children = items.Where(ch => ch.ParentId == i.Id).ToList());
                var data = items.Where(i => i.ParentId == null).ToList();
                return Task.FromResult(data);
            });
        }
        public async Task<List<CommonValue>> GetOrganizeses(bool? isAll)
        {
            const string storedProcedure = "sp_user_organize_list";
            return await base.GetListAsync<CommonValue>(storedProcedure, new { });
        }

        public async Task<CommonDataPage> GetAllUsersAsync(UserFilter filter)
        {
            const string storedProcedure = "sp_user_page";
            return await base.GetDataListPageAsync(storedProcedure, filter, new { });
        }
        public async Task<List<CommonValue>> GetUserList(string userIds, string filter)
        {
            const string storedProcedure = "sp_user_list";
            return await base.GetListAsync<CommonValue>(storedProcedure, new { userIds, filter });
        }

    }
}

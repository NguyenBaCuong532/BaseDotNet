using DocumentFormat.OpenXml.EMMA;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Repositories;
using UNI.Model;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Office2013.Drawing.ChartStyle;
using UNI.Resident.Model.Resident;
using UNI.Model.Audit;

namespace UNI.Resident.BLL.BusinessService
{
    public class UserConfigService: IUserConfigService
    {
        private readonly IUserConfigRepository _repository;
        public UserConfigService(
            IUserConfigRepository userConfigRepository)
        {
            if (userConfigRepository != null)
                _repository = userConfigRepository;
        }

        public Task<BaseValidate> SetUserConfig(string userid, string categoryIds)
        {
            return _repository.SetUserConfig(userid, categoryIds);
        }

        public Task<BaseValidate> setUserProdAsync(UserProdCms profile)
        {
            return _repository.setUserProdAsync(profile);
        }
        public Task<List<CommonValue>> GetWorkplaces(Guid? orgId)
        {
            return _repository.GetWorkplaces(orgId);
        }
        public Task<List<TreeNodeSingle>> GetCategosies(Guid? orgId)
        {
            return _repository.GetCategosies(orgId);
        }
        public async Task<List<CommonValue>> GetOrganizeses(bool? isAll)
        {
            return await _repository.GetOrganizeses(isAll);
        }
        public Task<CommonDataPage> GetAllUsersAsync(UserFilter flt)
        {
            return _repository.GetAllUsersAsync(flt);
        }
        public Task<List<CommonValue>> GetUserList(string userIds, string filter)
        {
            return _repository.GetUserList(userIds, filter);
        }
    }
}

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.Settings
{
    public interface IProjectConfigRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetProjectConfigFilter();

        Task<CommonDataPage> GetProjectConfigPage(FilterBase filter);

        Task<viewBaseInfo> GetProjectConfigFields(Guid? oid);

        Task<BaseValidate> SetProjectConfig(CommonViewInfo inputData);

        Task<BaseValidate> SetProjectConfigDelete(List<Guid> arrOid);

        Task<BaseValidate> SetProjectConfigDefaultValue(string configCode, string configValue);

        Task<BaseValidate<string>> GetProjectConfigValue(string configCode, long? receiveId);
    }
}
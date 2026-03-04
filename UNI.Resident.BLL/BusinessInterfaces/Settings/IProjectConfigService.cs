using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Project;

namespace UNI.Resident.BLL.BusinessInterfaces.Settings
{
    public interface IProjectConfigService : IUniBaseService
    {
        Task<CommonViewInfo> GetProjectConfigFilter();

        Task<CommonDataPage> GetProjectConfigPage(FilterBase filter);

        Task<viewBaseInfo> GetProjectConfigFields(Guid? oid);

        Task<BaseValidate> SetProjectConfig(CommonViewInfo inputData);

        Task<BaseValidate> SetProjectConfigDelete(List<Guid> arrOid);

        Task<BaseValidate> SetProjectConfigDefaultValue(ProjectConfigSetDefaultValueInput input);

        Task<BaseValidate<string>> GetProjectConfigValue(string configCode);
    }
}
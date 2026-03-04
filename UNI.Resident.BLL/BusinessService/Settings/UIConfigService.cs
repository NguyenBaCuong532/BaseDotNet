using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.DAL.Interfaces.Settings;

namespace UNI.Resident.BLL.BusinessService.Settings
{
    /// <summary>
    /// Class Config Service.
    /// <author>Duongpx</author>
    /// <date>2020/05/11</date>
    /// </summary>
    public class UIConfigService : IUIConfigService
    {
        private readonly IUIConfigRepository _configRepository;
       
        public UIConfigService(IUIConfigRepository coreserviceRepository)
        {
            if (coreserviceRepository != null)
                _configRepository = coreserviceRepository;
        }
        public Task<CommonDataPage> GetFormViewPage(FilterInpTableKey filter)
        {
            return _configRepository.GetFormViewPage(filter);
        }

        public Task<BaseValidate> SetFormViewInfo(ConfigField para)
        {
            return _configRepository.SetFormViewInfo(para);
        }
        public Task<BaseValidate> DelFormViewInfo(long fieldId)
        {
            return _configRepository.DelFormViewInfo(fieldId);
        }
        public Task<CommonDataPage> GetGridViewPage(FilterInpGridKey filter)
        {
            return _configRepository.GetGridViewPage(filter);
        }

        public Task<BaseValidate> SetGridViewInfo(ConfigColumn para)
        {
            return _configRepository.SetGridViewInfo(para);
        }
        public Task<BaseValidate> DelGridViewInfo(long gridId)
        {
            return _configRepository.DelGridViewInfo(gridId);
        }
        public Task<CommonViewInfo> GetGroupInfo(string key_1, string key_2)
        {
            return _configRepository.GetGroupInfo(key_1, key_2);
        }
        public Task<BaseValidate> SetGroupInfo(CommonViewInfo para)
        {
            return _configRepository.SetGroupInfo(para);
        }

        public Task<List<viewGridFlex>> GetGridAsync(string gridKey)
        {
            return _configRepository.GetGridAsync(gridKey);
        }
    }
}

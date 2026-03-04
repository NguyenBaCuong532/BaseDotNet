using UNI.Model;
using UNI.Model.Core;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace UNI.Resident.DAL.Interfaces.Settings
{

    public interface IUIConfigRepository
    {

        Task<CommonDataPage> GetFormViewPage(FilterInpTableKey filter);
        Task<BaseValidate> SetFormViewInfo(ConfigField para);
        Task<BaseValidate> DelFormViewInfo(long fieldId);

        Task<CommonDataPage> GetGridViewPage(FilterInpGridKey filter);
        Task<BaseValidate> SetGridViewInfo(ConfigColumn para);
        Task<BaseValidate> DelGridViewInfo(long gridId);

        Task<CommonViewInfo> GetGroupInfo(string key_1, string key_2);
        Task<BaseValidate> SetGroupInfo(CommonViewInfo para);
        Task<List<viewGridFlex>> GetGridAsync(string gridKey);
    }
}

using UNI.Model;
//using UNI.Model.SResort;
using UNI.Resident.Model.Common;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.BusinessInterfaces.Card
{
    public interface ICardPartnerService
    {
        Task<BaseValidate> DeleteAsync(long? id);
        Task<CommonViewInfo> GetInfoAsync(long? id);
        Task<IEnumerable<CommonValue>> GetListAsync(string projectCd);
        Task<CommonDataPage> GetPageAsync(GridProjectFilter query);
        Task<BaseValidate> SetInfoAsync(CommonViewInfo info);
    }
}

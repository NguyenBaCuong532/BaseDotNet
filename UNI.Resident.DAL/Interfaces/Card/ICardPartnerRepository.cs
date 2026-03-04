using UNI.Model;
using UNI.Resident.Model.Common;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace UNI.Resident.DAL.Interfaces.Card
{
    public interface ICardPartnerRepository
    {
        Task<BaseValidate> DeleteAsync(long? id);
        Task<CommonViewInfo> GetInfoAsync(long? id);
        Task<IEnumerable<CommonValue>> GetListAsync(string projectCd);
        Task<CommonDataPage> GetPageAsync(GridProjectFilter query);
        Task<BaseValidate> SetInfoAsync(CommonViewInfo info);
    }
}

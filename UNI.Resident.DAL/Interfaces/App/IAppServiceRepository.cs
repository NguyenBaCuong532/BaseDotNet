using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces.App
{
    public interface IAppServiceRepository
    {
        #region web-service-reg
        Task<List<HomRequestCategoryGet>> GetRequestCategoryListAsync(int categoryType, string language);
        Task<List<CommonValue>> GetBaseStatusAsync(string baseKey);
        Task<PageRequestFix> GetPageRequestAsync(FilterBaseApartment filter);
        Task SetRequestAsync(HomRequestSet request);
        Task SetRequestVotedAsync(HomRequestVote request);
        Task SetRequestConfirmAsync(HomRequestBase confirm);
        Task<HomRequest> GetRequestAsync(long requestId);
        Task<HomRequestProcessGet> SetRequestProcessAsync(HomRequestProcess process);
        #endregion web-service-reg
    }
}

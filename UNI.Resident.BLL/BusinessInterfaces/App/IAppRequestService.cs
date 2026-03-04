using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IAppRequestService
    {
        
        #region web-request-reg
        Task<List<HomRequestCategoryGet>> GetRequestCategoryListAsync(int categoryType, string language);
        Task<List<CommonValue>> GetBaseStatusAsync(string baseKey);
        Task<PageRequestFix> GetPageRequestAsync(FilterBaseApartment filter);
        Task SetRequestAsync(HomRequestSet request);
        Task SetRequestVotedAsync(HomRequestVote request);
        Task SetRequestConfirmAsync(HomRequestBase confirm);
        Task<HomRequest> GetRequestAsync(long requestId);
        Task<HomRequestProcessGet> SetRequestProcessAsync(HomRequestProcess process);
        #endregion web-request-reg
    }
}

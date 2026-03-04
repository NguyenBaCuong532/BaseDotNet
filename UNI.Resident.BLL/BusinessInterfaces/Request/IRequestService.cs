using UNI.Model;
using UNI.Resident.Model.Resident;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Feedback;

namespace UNI.Resident.BLL.BusinessInterfaces.Request
{
    public interface IRequestService
    {
        #region web-Request
        // QL căn hộ/ Tab Yêu cầu
        Task<CommonDataPage> GetApartmentRequestPageAsync(ApartmentRequestModel query);
        // Thông tin chung
        Task<RequestInfo> GetRequestInfo(int? RequestId, string? Oid);
        // Xử lý yêu cầu/ Yêu cầu
        CommonViewInfo GetRequestFilter(string userId);
        Task<CommonDataPage> GetRequestPageAsync(RequestModel query);
        #endregion
        Task<int> SetRequestAssignAsync(RequestAssign assign);
        Task<RequestProcessGet> SetRequestProcessAsync(RequestProcess process);
        Task<ResponseList<List<RequestProcessGet>>> GetRequestProcessPageAsync(ProcessFilter query);
        Task<CommonDataPage> GetFeedbackPageAsync(GridProjectFilter query);
        Task<FeedbackProcessGet> SetFeedbackProcessAsync(FeedbackProcess feedback);
        Task<FeedbackFull> GetFeedbackAsync(long feedbackId);
        Task<RequestAssignmentTabInfo> GetRequestAssignmentInfoAsync(int requestId, string userId);
    }
}

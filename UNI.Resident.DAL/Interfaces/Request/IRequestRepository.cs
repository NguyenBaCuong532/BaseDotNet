using UNI.Resident.Model.Common;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using FeedbackFull = UNI.Resident.Model.Feedback.FeedbackFull;
using FeedbackProcess = UNI.Resident.Model.Feedback.FeedbackProcess;
using FeedbackProcessGet = UNI.Resident.Model.Feedback.FeedbackProcessGet;

namespace UNI.Resident.DAL.Interfaces.Request
{
    public interface IRequestRepository
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
        Task<int> SetRequestAttachAsync(ICollection<RequestAttachment> attachments);
        Task<ResponseList<List<RequestProcessGet>>> GetRequestProcessPageAsync(ProcessFilter query);
        Task<CommonDataPage> GetFeedbackPageAsync(GridProjectFilter query);
        Task<FeedbackProcessGet> SetFeedbackProcessAsync(FeedbackProcess feedback);
        Task<FeedbackFull> GetFeedbackAsync(long feedbackId);
      
        Task<RequestAssignmentTabInfo> GetRequestAssignmentInfoAsync(int requestId, string userId);
    }
}

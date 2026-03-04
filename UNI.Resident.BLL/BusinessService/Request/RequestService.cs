using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Feedback;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

//using SSG.DAL.Interfaces;

namespace UNI.Resident.BLL.BusinessService.Request
{
    public class RequestService : IRequestService
    {
        private readonly IRequestRepository _repository;
        public RequestService(
            IRequestRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }

        // Yêu cầu từ căn hộ
        public async Task<CommonDataPage> GetApartmentRequestPageAsync(ApartmentRequestModel query)
        {
            return await _repository.GetApartmentRequestPageAsync(query);
        }
        //Thông tin chung
        public async Task<RequestInfo> GetRequestInfo(int? RequestId, string? Oid)
        {
            return await _repository.GetRequestInfo(RequestId, Oid);
        }
        // Yêu cầu/ Xử lý yêu cầu
        public CommonViewInfo GetRequestFilter(string userId)
        {
            return _repository.GetRequestFilter(userId);
        }
        public async Task<CommonDataPage> GetRequestPageAsync(RequestModel query)
        {
            return await _repository.GetRequestPageAsync(query);
        }

        public Task<int> SetRequestAssignAsync(RequestAssign assign)
        {
            return _repository.SetRequestAssignAsync(assign);
        }

        public async Task<RequestProcessGet> SetRequestProcessAsync(RequestProcess process)
        {
            var res = await _repository.SetRequestProcessAsync(process);

            if (res?.ProcessId > 1 && process.Attachments.Any())
            {
                process.Attachments.ForEach(x =>
                {
                    x.ProcessId = res.RequestId;
                    x.ProcessId = res.ProcessId;
                });
                _ = await _repository.SetRequestAttachAsync(process.Attachments);
                return res;
            }

            return res;
        }
        
        public Task<ResponseList<List<RequestProcessGet>>> GetRequestProcessPageAsync(ProcessFilter query)
        {
            return _repository.GetRequestProcessPageAsync(query);
        }

        public Task<CommonDataPage> GetFeedbackPageAsync(GridProjectFilter query)
        {
            return _repository.GetFeedbackPageAsync(query);
        }
        public Task<RequestAssignmentTabInfo> GetRequestAssignmentInfoAsync(int requestId, string userId)
            => _repository.GetRequestAssignmentInfoAsync(requestId, userId);
        public Task<FeedbackProcessGet> SetFeedbackProcessAsync(FeedbackProcess feedback)
        {
            return _repository.SetFeedbackProcessAsync(feedback);
        }

        public Task<FeedbackFull> GetFeedbackAsync(long feedbackId)
        {
            return _repository.GetFeedbackAsync(feedbackId);
        }
    }
}

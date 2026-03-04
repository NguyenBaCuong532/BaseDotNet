using DapperParameters;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Feedback;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Request
{
    public class RequestRepository : UniBaseRepository, IRequestRepository
    {
        private readonly ILogger<RequestRepository> _logger;

        public RequestRepository(IUniCommonBaseRepository common,
            ILogger<RequestRepository> logger,
            IHostingEnvironment environment) : base(common)
        {
            _logger = logger;
        }
        #region web-Request

        public async Task<CommonDataPage> GetApartmentRequestPageAsync(ApartmentRequestModel query)
        {
            const string storedProcedure = "sp_res_request_page_byapartid";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }

        public async Task<RequestInfo> GetRequestInfo(int? RequestId, string? Oid)
        {
            const string storedProcedure = "sp_res_request_field";
            // Truyền cả 2 tham số xuống store
            return await GetFieldsAsync<RequestInfo>(storedProcedure, new { Oid, RequestId });
        }

        public CommonViewInfo GetRequestFilter(string userId)
        {
            const string storedProcedure = "sp_res_request_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId }).Result;
        }


        public async Task<CommonDataPage> GetRequestPageAsync(RequestModel query)
        {
            const string storedProcedure = "sp_res_request_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.Status, query.IsNow, query.fromDate, query.toDate });
        }

        public async Task<int> SetRequestAssignAsync(RequestAssign assign)
        {
            const string storedProcedure = "sp_res_Request_Assign_Multiple";
            return await SetAsync<int>(storedProcedure, param =>
            {
                //param.Add("userId", userId);
                param.Add("requestId", assign.RequestId);
                param.AddTable("assigns", nameof(UserAssignType), assign.Assigns);
                return param;
            });
        }

        public async Task<RequestProcessGet> SetRequestProcessAsync(RequestProcess process)
        {
            const string storedProcedure = "sp_res_Request_Process";
            return await GetFirstOrDefaultAsync<RequestProcessGet>(storedProcedure, new
            {
                //UserID = userId,
                process.RequestId,
                process.Comment,
                process.Status
            });
        }

        public async Task<int> SetRequestAttachAsync(ICollection<RequestAttachment> attachments)
        {
            const string storedProcedure = "sp_res_Request_Attach_Multiple_Set";
            return await SetAsync<int>(storedProcedure, param =>
            {
                //param.Add("UserId", userId);
                param.AddTable("attachments", nameof(RequestAttachmentType), attachments);
                return param;
            });
        }

        public async Task<ResponseList<List<RequestProcessGet>>> GetRequestProcessPageAsync(ProcessFilter query)
        {
            const string storedProcedure = "sp_res_Request_Process_Page";
            return await GetMultipleAsync<ResponseList<List<RequestProcessGet>>>(storedProcedure, param =>
            {
                param.Add("@Offset", query.offSet);
                param.Add("@PageSize", query.pageSize);
                param.Add("@RequestId", query.RequestId);
                param.Add("@Filter", query.filter);
                param.Add("@Total", 0, System.Data.DbType.Int64, System.Data.ParameterDirection.InputOutput);
                param.Add("@TotalFiltered", 0, System.Data.DbType.Int64, System.Data.ParameterDirection.InputOutput);
                return param;
            }, async result =>
            {
                var processes = (await result.ReadAsync<RequestProcessGet>()).ToList();
                var attachments = (await result.ReadAsync<RequestAttachment>()).ToList();
                processes.ForEach(x => x.Attachments = attachments.Where(a => a.ProcessId == x.ProcessId).ToList());
                return new ResponseList<List<RequestProcessGet>>(processes, 0, 0); // Sửa lại nếu cần lấy Total, TotalFiltered
            });
        }

        public async Task<CommonDataPage> GetFeedbackPageAsync(GridProjectFilter query)
        {
            const string storedProcedure = "sp_res_Feedback_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd });
        }

        public async Task<FeedbackProcessGet> SetFeedbackProcessAsync(FeedbackProcess feedback)
        {
            const string storedProcedure = "sp_res_Feedback_Process_Set";
            return await GetFirstOrDefaultAsync<FeedbackProcessGet>(storedProcedure, new
            {
                //UserID = userId,
                feedback.FeedbackId,
                feedback.Comment,
                feedback.Status
            });
        }

        public async Task<FeedbackFull> GetFeedbackAsync(long feedbackId)
        {
            const string storedProcedure = "sp_res_Feedback_Get";
            return await GetMultipleAsync<FeedbackFull>(storedProcedure, param =>
            {
                //param.Add("@userId", userId);
                param.Add("@FeedbackId", feedbackId);
                return param;
            }, async result =>
            {
                var req = (await result.ReadAsync<FeedbackFull>()).FirstOrDefault();
                if (req != null)
                {
                    req.Processes = (await result.ReadAsync<FeedbackProcessGet>()).ToList();
                    req.Attachments = (await result.ReadAsync<RequestAttachment>()).ToList();
                }
                return req;
            });

        }
        public async Task<RequestAssignmentTabInfo> GetRequestAssignmentInfoAsync(int requestId, string userId)
        {
            const string storedProcedure = "sp_res_request_assignment_tab";

            return await GetMultipleAsync<RequestAssignmentTabInfo>(storedProcedure, param =>
            {
                param.Add("@UserId", userId);
                param.Add("@RequestId", requestId);
                return param;
            },
            async result =>
            {
                var header = (await result.ReadAsync<RequestAssignmentHeader>()).FirstOrDefault()
                             ?? new RequestAssignmentHeader { requestId = requestId };

                var assigneesFlat = (await result.ReadAsync<RequestAssignmentAssignee>()).ToList();

          
                var assigneesGrouped = assigneesFlat
                    .GroupBy(x => new { x.assignRole, x.assignRoleName })
                    .Select(g => new RequestAssignmentAssigneeGroup
                    {
                        assignRole = g.Key.assignRole,
                        assignRoleName = g.Key.assignRoleName ?? "",
                        users = g.ToList()
                    })
                    .ToList();

                var processes = (await result.ReadAsync<RequestAssignmentProcessLog>()).ToList();
                var statuses = (await result.ReadAsync<RequestAssignmentStatusItem>()).ToList();

                return new RequestAssignmentTabInfo
                {
                    Header = header,
                    Assignees = assigneesGrouped,
                    Processes = processes,
                    Statuses = statuses
                };
                
            });
        }

        
        #endregion
    }
}

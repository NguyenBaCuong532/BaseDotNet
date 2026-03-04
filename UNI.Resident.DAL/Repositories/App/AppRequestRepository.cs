using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IAppRequestRepository" />
    public class AppRequestRepository : UniBaseRepository, IAppRequestRepository
    {

        public AppRequestRepository(IUniCommonBaseRepository common)
            : base(common)
        {
        }
        #region request-reg
        public async Task<PageRequestFix> GetPageRequestAsync(FilterBaseApartment filter)
        {
            const string storedProcedure = "sp_Hom_App_Request_ByUserId";
            return await GetMultipleAsync<PageRequestFix>(storedProcedure, new {
                userId = filter.userId,
                ApartmentId = filter.ApartmentId,
                Offset = filter.offSet,
                PageSize = filter.pageSize
            }, async reader =>
            {
                var reqPage = new PageRequestFix();
                var requestList = (await reader.ReadAsync<HomRequestFix>()).ToList();
                reqPage.Requests = new ResponseList<List<HomRequestFix>>(requestList, 0, 0); // Sửa lại nếu cần lấy Total, TotalFiltered
                return reqPage;
            });
        }
        public async Task<List<HomRequestCategoryGet>> GetRequestCategoryListAsync(int categoryType, string language)
        {
            const string storedProcedure = "sp_Hom_Request_Category_List";
            return await GetMultipleAsync<List<HomRequestCategoryGet>>(storedProcedure, new { categoryType, language }, async reader =>
            {
                var data = (await reader.ReadAsync<HomRequestCategoryGet>()).ToList();
                if (data != null && data.Count > 0)
                {
                    var rqtypes = (await reader.ReadAsync<HomRequestType>()).ToList();
                    foreach (var d in data)
                    {
                        d.RequestTypes = rqtypes.Where(r => r.RequestCategoryId == d.RequestCategoryId).ToList();
                    }
                }
                return data;
            });
        }
        public async Task SetRequestAsync(HomRequestSet request)
        {
            const string storedProcedure = "sp_Hom_Request_Set";
            await SetAsync<HomRequestInfo>(storedProcedure, new {
                //UserID = userId,
                ApartmentId = request.ApartmentId,
                RequestId = request.requestId,
                RequestTypeId = request.RequestTypeId,
                Comment = request.Comment,
                IsNow = request.IsNow,
                thread_id = request.thread_id,
                AtTime = request.AtTime != null ? UNI.Utils.StringHelper.StringToDate(request.AtTime) : (DateTime?)null
            });
            // Xử lý attach nếu cần (có thể refactor tiếp)
        }
        public async Task SetRequestVotedAsync(HomRequestVote request)
        {
            const string storedProcedure = "sp_Hom_Request_Voted";
            await SetAsync<HomRequestInfo>(storedProcedure, new {
                //UserID = userId,
                RequestId = request.requestId,
                Comment = request.Comment,
                rating = request.rating
            });
            // Xử lý attach nếu cần (có thể refactor tiếp)
        }
        public async Task SetRequestConfirmAsync(HomRequestBase confirm)
        {
            const string storedProcedure = "sp_Hom_Request_Closed";
            await SetAsync<HomRequestInfo>(storedProcedure, new {
                //UserID = userId,
                RequestId = confirm.requestId
            });
        }
        public async Task SetRequestAttachAsync(HomRequestAttach attach)
        {
            const string storedProcedure = "sp_Hom_Request_Attach_Set";
            await SetAsync<HomRequestAttach>(storedProcedure, new {
                //UserId = userId,
                id = attach.id,
                requestId = attach.requestId,
                processId = attach.processId,
                attachUrl = attach.attachUrl,
                attachType = attach.attachType,
                attachFileName = attach.attachFileName,
                used = attach.used
            });
        }
        public async Task<HomRequest> GetRequestAsync(long requestId)
        {
            const string storedProcedure = "sp_Hom_App_Request_Get";
            return await GetMultipleAsync<HomRequest>(storedProcedure, new { RequestId = requestId }, async reader =>
            {
                var req = await reader.ReadFirstOrDefaultAsync<HomRequest>();
                if (req != null)
                {
                    req.attachs = (await reader.ReadAsync<HomRequestAttach>()).ToList();
                    req.Processes = (await reader.ReadAsync<HomRequestProcessGet>()).ToList();
                    if (req.IsFinished)
                    {
                        req.vote = await reader.ReadFirstOrDefaultAsync<HomRequestVote>();
                        if (req.vote != null)
                        {
                            req.vote.attachs = (await reader.ReadAsync<HomRequestAttach>()).ToList();
                        }
                    }
                }
                return req;
            });
        }
        public async Task<HomRequestProcessGet> SetRequestProcessAsync(HomRequestProcess process)
        {
            const string storedProcedure = "sp_Hom_Request_Process";
            return await GetMultipleAsync<HomRequestProcessGet>(storedProcedure, new {
                //UserID = userId,
                RequestId = process.RequestId,
                Comment = process.Comment,
                Status = process.Status
            }, async reader =>
            {
                var result = await reader.ReadFirstOrDefaultAsync<HomRequestProcessGet>();
                return result;
            });
        }
        public async Task<int> SetRequestClosedAsync(HomRequestBase request)
        {
            const string storedProcedure = "sp_Hom_Request_Closed";
            var result = await SetAsync<HomRequestBase>(storedProcedure, new {
                //UserID = userId,
                RequestId = request.requestId
            });
            return result != null ? 1 : 0;
        }
        public async Task<List<CommonValue>> GetBaseStatusAsync(string baseKey)
        {
            const string storedProcedure = "sp_Home_Status_List";
            return await GetListAsync<CommonValue>(storedProcedure, new { statusKey = baseKey });
        }
        #endregion request-reg
    }
}

using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Feedback;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Request
{

    /// <summary>
    /// RequestController 
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/request/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class RequestController : UniController
    {

        #region instance-reg
        /// <summary>
        /// ctor
        /// </summary>
        /// Author: 
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IRequestService _requestService;
        //private readonly IMapper _mapper;
        //private readonly ISysManageService _sysManageService;

        /// <summary>
        /// Initializes a new instance of the <see cref="RequestController"/> class.
        /// </summary>
        /// <param name="requestService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>        
        public RequestController(
            IRequestService requestService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _requestService = requestService;
            //_mapper = mapper;
            //_sysManageService = sysManageService;
        }
        #endregion
        /// <summary>
        /// GetApartmentRequestPageAsync - Danh sách yêu cầu từ căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetApartmentRequestPageAsync([FromQuery] ApartmentRequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _requestService.GetApartmentRequestPageAsync(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetRequestInfo - chi tiết yêu cầu
        /// </summary>
        /// <param name="RequestId">Mã yêu cầu (int) - backward compatible</param>
        /// <param name="Oid">Mã định danh yêu cầu (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<RequestInfo>> GetRequestInfo([FromQuery] int? RequestId, [FromQuery] string Oid)
        {
            try
            {
                var rs = await _requestService.GetRequestInfo(RequestId, Oid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<RequestInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetApartmentFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetRequestFilter()
        {
            var result = _requestService.GetRequestFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetRequestPageAsync - Danh sách xử lý yêu cầu 
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetRequestPageAsync([FromQuery] RequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _requestService.GetRequestPageAsync(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// Xử lý yêu cầu
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        // [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        //[Authorize(Roles = UNIPolicy.SHOME_MAN)]
        public async Task<ResponseList<List<RequestProcessGet>>> GetRequestProcessPage([FromQuery] ProcessFilter query)
        {
            query.userId = UserId;
            query.clientId = ClientId;
            var result = await _requestService.GetRequestProcessPageAsync(query);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        ///// <summary>
        ///// Get Request Categories
        ///// </summary>
        ///// <returns></returns>
        //[ServiceFilter(typeof(AuditFilterAttribute))]
        //[HttpGet]
        //public async Task<BaseResponse<List<CommonValue>>> GetRequestStatusList()
        //{
        //    var result = await _sysManageService.GetObjectsAsync("request_st", false);
        //    return GetResponse(ApiResult.Success, result);
        //}

        /// <summary>
        /// Set Request Assign
        /// </summary>
        /// <param name="assign"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetRequestAssign([FromBody] RequestAssign assign)
        {
            var result = await _requestService.SetRequestAssignAsync(assign);
            var process = new RequestProcess { RequestId = assign.RequestId, Status = 1, Comment = "Đã giao việc" };
            await _requestService.SetRequestProcessAsync(process);
            return GetResponse<string>(ApiResult.Success, null);
        }

        /// <summary>
        /// Set Request Process by Manager 
        /// </summary>
        /// <param name="process"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        public async Task<BaseResponse<RequestProcessGet>> SetRequestProcess([FromBody] RequestProcess process)
        {
            if (process.Status < 2)
                process.Status = 2;
            var result = await _requestService.SetRequestProcessAsync(process);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Ý kiến khách hàng
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        //[Authorize(Roles = UNIPolicy.SHOME_MAN)]
        public async Task<BaseResponse<CommonDataPage>> GetFeedbackPage([FromQuery] GridProjectFilter query)
        {
            //if (projectCd == null)
            //{
            //    projectCd = _userService.GetUserProject(this.UserId);
            //}
            query.userId = UserId;
            query.clientId = ClientId;
            var result = await _requestService.GetFeedbackPageAsync(query);
            var rp = GetResponse(ApiResult.Success, result);
            return rp;
        }
        /// <summary>
        /// Get Feedback
        /// </summary>
        /// <param name="feedbackId"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        public async Task<BaseResponse<FeedbackFull>> GetFeedback([FromQuery] long feedbackId)
        {
            var result = await _requestService.GetFeedbackAsync(feedbackId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="feedback"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<FeedbackProcessGet>> SetFeedbackProcess([FromBody] FeedbackProcess feedback)
        {
            var rs = await _requestService.SetFeedbackProcessAsync(feedback);
            return GetResponse(ApiResult.Success, rs);
        }

        [HttpGet]
   
        public async Task<BaseResponse<RequestAssignmentTabInfo>> GetRequestAssignmentInfo([FromQuery] int RequestId)
        {
            try
            {
                var rs = await _requestService.GetRequestAssignmentInfoAsync(RequestId, UserId);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                return new BaseResponse<RequestAssignmentTabInfo>(ApiResult.Error, e.Message);
            }
        }




    }
}

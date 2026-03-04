using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.ServiceFee
{
    [Route("api/v2/Service/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    [ApiController]
    public class ServiceController : UniController
    {
        private readonly IServiceService _serviceService;

        public ServiceController(IServiceService serviceService, IOptions<AppSettings> appSettings, ILoggerFactory logger)
            : base(appSettings, logger)
        {
            _serviceService = serviceService;
        }
        /// <summary>
        /// Thông báo cắt dịch vụ
        /// </summary>
        /// <param name="apartments"></param>
        /// <param name="projectcode"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<IActionResult> SetServiceStopPush([FromBody] ApartmentsDto apartments, [FromHeader] string projectcode)
        {
            BaseValidate rs = await _serviceService.SetServiceStopPushAsync(apartments, projectcode);
            var rp = GetResponse(UNI.Model.Api.ApiResult.Success, "", rs.messages);
            return Ok(rp);
        }

        /// <summary>
        /// GetCleaningServiceInfo - Lấy thông tin chi tiết yêu cầu dịch vụ vệ sinh
        /// </summary>
        /// <param name="request">Request chứa requestId (string)</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<RequestInfo>> GetCleaningServiceInfo([FromQuery] CleaningServiceInfoRequest request)
        {
            try
            {
                var rs = await _serviceService.GetCleaningServiceInfo(request?.requestId);
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
        /// GetCleaningServiceFilter - Bộ lọc danh sách yêu cầu dịch vụ vệ sinh
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetCleaningServiceFilter()
        {
            var result = _serviceService.GetCleaningServiceFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetCleaningServicePage - Danh sách xử lý yêu cầu dịch vụ vệ sinh
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetCleaningServicePage([FromQuery] RequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _serviceService.GetCleaningServicePage(query);
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
        /// GetCleaningServiceProcessPage - Danh sách quá trình xử lý yêu cầu dịch vụ vệ sinh
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ResponseList<List<RequestProcessGet>>> GetCleaningServiceProcessPage([FromQuery] ProcessFilter query)
        {
            query.userId = UserId;
            query.clientId = ClientId;
            var result = await _serviceService.GetCleaningServiceProcessPageAsync(query);
            result.SetStatus(ApiResult.Success);
            return result;
        }
    }
}

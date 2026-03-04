using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Aparment
{
    /// <summary>
    /// Violation History Controller
    /// </summary>
    /// Author: System
    /// CreatedDate: 2025-01-29
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/violation-history/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ViolationHistoryController : UniController
    {
        /// <summary>
        /// The apartment service
        /// </summary>
        private readonly IApartmentService _apartmentService;

        /// <summary>
        /// Initializes a new instance of the <see cref="ViolationHistoryController"/> class.
        /// </summary>
        /// <param name="apartmentService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public ViolationHistoryController(IApartmentService apartmentService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _apartmentService = apartmentService;
        }

        #region ViolationHistory
        /// <summary>
        /// DeleteViolationHistory - Xóa lịch sử vi phạm
        /// </summary>
        /// <param name="id">ID lịch sử vi phạm (GUID)</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteViolationHistory([FromQuery] Guid id)
        {
            try
            {
                var rs = await _apartmentService.DeleteViolationHistory(id);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// SetViolationHistoryInfo - Lưu thông tin lịch sử vi phạm
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetViolationHistoryInfo([FromBody] ApartmentViolationHistoryInfo info)
        {
            try
            {
                if (!this.ModelState.IsValid)
                {
                    return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                var rs = await _apartmentService.SetViolationHistoryInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// GetViolationHistoryInfo - Lấy thông tin lịch sử vi phạm
        /// </summary>
        /// <param name="id">ID lịch sử vi phạm (GUID)</param>
        /// <param name="Oid">Mã định danh căn hộ (UUID) - backward compatible</param>
        /// <param name="ApartmentId">ID căn hộ (int) - backward compatible</param>
        /// <param name="apartOid">Oid căn hộ (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ApartmentViolationHistoryInfo>> GetViolationHistoryInfo([FromQuery] Guid? id, [FromQuery] Guid? Oid, [FromQuery] int? ApartmentId, [FromQuery] Guid? apartOid = null)
        {
            try
            {
                var rs = await _apartmentService.GetViolationHistoryInfo(id, apartOid ?? Oid, ApartmentId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<ApartmentViolationHistoryInfo>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// GetViolationHistoryPage - Lấy danh sách lịch sử vi phạm
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetViolationHistoryPage([FromQuery] ApartmentViolationHistoryRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetViolationHistoryPage(query);
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
        #endregion
    }
}

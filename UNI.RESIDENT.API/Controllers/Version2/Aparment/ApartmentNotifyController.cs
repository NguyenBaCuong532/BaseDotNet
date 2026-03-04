using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM.Notifications;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Aparment
{
    /// <summary>
    /// Apartment Notify Controller
    /// </summary>
    /// Author: System
    /// CreatedDate: 2025-01-29
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/apartment-notify/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ApartmentNotifyController : UniController
    {
        /// <summary>
        /// The apartment service
        /// </summary>
        private readonly IApartmentService _apartmentService;

        /// <summary>
        /// Initializes a new instance of the <see cref="ApartmentNotifyController"/> class.
        /// </summary>
        /// <param name="apartmentService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public ApartmentNotifyController(IApartmentService apartmentService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _apartmentService = apartmentService;
        }

        #region NotifyHistory
        /// <summary>
        /// GetHistoryNotifyByApartmentPage - Lịch sử gửi thông báo app theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetHistoryNotifyByApartmentPage([FromQuery] SentNotifyHistoryRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetHistoryNotifyByApartmentPage(query);
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
        /// GetHistoryEmailByApartmentPage - Lịch sử gửi email theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetHistoryEmailByApartmentPage([FromQuery] SentEmailHistoryRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetHistoryEmailByApartmentPage(query);
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
        /// GetHistorySmsByApartmentPage - Lịch sử gửi SMS theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetHistorySmsByApartmentPage([FromQuery] SentSmsHistoryRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetHistorySmsByApartmentPage(query);
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

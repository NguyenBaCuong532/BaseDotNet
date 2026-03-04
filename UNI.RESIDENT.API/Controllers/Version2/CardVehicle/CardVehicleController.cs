using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Utils;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.API.Controllers.Version2.Card;

namespace UNI.Resident.API.Controllers.Version2.CardVehicle
{
    /// <summary>
    /// CardVechile Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 2020-04-20 9:31 AM
    /// <seealso cref="UniController" />
    [Route("api/v2/cardvehicle/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardVehicleController : UniController
    {
        private readonly ICardVehicleExtService _homeService;
        private readonly IMapper _mapper;
        private readonly IVehicleCardService _vehicleCardService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CardVehicleController"/> class.
        /// </summary>
        /// <param name="homeService">Card vehicle extended service (ICardVehicleExtService)</param>
        /// <param name="appSettings">Application settings</param>
        /// <param name="logger">Logger factory</param>
        /// <param name="mapper">AutoMapper instance</param>
        /// <param name="vehicleCardService">Vehicle card service (IVehicleCardService)</param>
        public CardVehicleController(
            ICardVehicleExtService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IVehicleCardService vehicleCardService) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
            _vehicleCardService = vehicleCardService;
        } 

        #region card vehicle

        #region web

        [HttpGet]
        public async Task<IActionResult> GetPage([FromQuery] VehicleCardFilter query)
        {
            query.userId = UserId;
            query.clientId = ClientId;
            CommonDataPage rs = await _vehicleCardService.GetPageAsync(query);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }

        /// <summary>
        /// Lịch sử quẹt thẻ xe ra/vào - Get vehicle card swipe history
        /// </summary>
        /// <param name="query">Filter parameters</param>
        /// <returns>Paginated list of vehicle card swipe history</returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetSwipeHistoryPage([FromQuery] VehicleCardSwipeHistoryFilter query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _vehicleCardService.GetSwipeHistoryPageAsync(query);
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
        /// Lịch sử thẻ xe - Get vehicle card history (Đổi mã thẻ, Đổi chủ sở hữu, Khóa xe, Khoá thẻ, Huỷ xe)
        /// </summary>
        /// <param name="query">Filter parameters</param>
        /// <returns>Paginated list of vehicle card history</returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetHistoryPage([FromQuery] VehicleCardHistoryFilter query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _vehicleCardService.GetHistoryPageAsync(query);
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
        /// Lịch sử thanh toán thẻ xe - Get vehicle card payment history
        /// </summary>
        /// <param name="query">Filter parameters</param>
        /// <returns>Paginated list of vehicle card payment history</returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetPaymentHistoryPage([FromQuery] VehicleCardPaymentHistoryFilter query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _vehicleCardService.GetPaymentHistoryPageAsync(query);
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
        /// Thông tin thẻ xe (guest/xe khách)
        /// </summary>
        /// <param name="type">guest (xe khách)</param>
        /// <param name="id">CardVehicleId</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpGet("{type}")]
        public async Task<IActionResult> GetInfo(string type, long id, [FromQuery] Guid? cardVehicleOid = null)
        {
            var rs = await _vehicleCardService.GetInfoAsync(type, id, cardVehicleOid);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// Chi tiết vé gửi xe
        /// </summary>
        /// <param name="cardCd">Mã thẻ</param>
        /// <param name="id">CardVehicleId</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetTicketInfo(string cardCd, long id, [FromQuery] Guid? cardVehicleOid = null)
        {
            CommonViewInfo rs = await _vehicleCardService.GetTicketInfoAsync(cardCd, id, cardVehicleOid);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }

        [HttpPost]
        public async Task<IActionResult> SetGuestVehicleCardInfo([FromBody] CommonViewInfo info)
        {
            var rs = await _vehicleCardService.SetGuestVehicleCardInfoAsync(info);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// Set Card
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<BaseValidateForHrm>> SetCardVehicle([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetCardVehicle(UserId, info);
            if (result.valid)
            {
                var value = GetResponse(ApiResult.Success, result);
                return value;
            }
            else
            {
                var response = GetResponse<BaseValidateForHrm>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        /// <summary>
        /// Thêm mới xe nhân viên
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<BaseValidateForHrm>> SetEmployeeVehicleRes([FromBody] HomCardVehicleForSet info)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<BaseValidateForHrm>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }

                BaseValidateForHrm rs = await _homeService.SetEmployeeVehicleRes(UserId, info);
                if (rs.valid)
                {
                    return GetResponse(ApiResult.Success, rs);
                }
                else
                {
                    return GetErrorResponse<BaseValidateForHrm>(ApiResult.Error, 2, rs.messages);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
        }

        /// <summary>
        /// GetCardVehicle - lấy thẻ được cấp của từng cá nhân
        /// </summary>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<List<CommonValue>>> GetCardVehicleAsync([FromQuery] string CustId)
        {
            var rs = await _homeService.GetCardVehicle(UserId, CustId);
            var response = GetResponse(ApiResult.Success, rs);
            return response;
        }
        /// <summary>
        /// xác nhận kiểm duyệt thẻ ở trạng thái mới tạo
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<IActionResult> SetCardVehicleServiceAuth([FromBody] VehicleCardAuth card)
        {
            var rs = await _vehicleCardService.SetCardVehicleServiceAuthAsync(card);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// xóa xe nhân viên
        /// </summary>
        /// <param name="vehicle"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> SetVehicleRemoveRes([FromBody] HomVehicleRegCancel vehicle)
        {
            var result = await _homeService.SetVehicleRegCancel(UserId, vehicle);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.code, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        /// <summary>
        /// khóa thẻ xe
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPut]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> SetCardLockRes([FromBody] HomCardLock card)
        {
            await _homeService.SetCardLocked(UserId, card);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Delete Card
        /// </summary>
        /// <param name="cardCd"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpDelete]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> DeleteCard([FromQuery] string cardCd)
        {
            var result = await _homeService.DeleteCard(UserId, cardCd);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// phê duyệt xe
        /// </summary>
        /// <param name="vehicle"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPut]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> SetVehicleApproveRes([FromBody] HomVehicleApprove vehicle)
        {
            await _homeService.SetVehicleApprove(vehicle);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// khóa và mở thẻ
        /// </summary>
        /// <param name="vehicle">Status = 1 Is Lock, 0 is Unlock</param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPut]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> SetVehicleLockRes([FromBody] HomVehicleLock vehicle)
        {
            var result = await _homeService.SetVehicleLockRes(UserId, vehicle);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }

        }

        /// <summary>
        /// import cards
        /// </summary>
        /// <param name="cards"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<ImportListPage>> SetCardsAcceptRes([FromBody] homeCardsImportSet cards)
        {
            try
            {
                var rs = await _homeService.SetCardsAcceptRes(UserId, cards);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// import card vehicle
        /// </summary>
        /// <param name="cards"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<ImportListPage>> SetCardVehicleAcceptRes([FromBody] homCardVehicleImportSet cards)
        {
            try
            {
                var rs = await _homeService.SetCardVehicleAcceptRes(UserId, cards);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// Tạo người dùng ở shome
        /// </summary>
        /// <param name="cust"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> SetCustomerResident([FromBody] homCustomerInfo cust)
        {
            await _homeService.SetCustomerResident(UserId, cust);
            return GetResponse<string>(ApiResult.Success, null);
        }

        #endregion

        #region app
        /// <summary>
        /// Đăng ký phương tiện
        /// </summary>
        /// <param name="vehicle"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<BaseValidateForHrm>> SetVehicleRegisterRes([FromBody] homVehicleRegSetApp vehicle)
        {
            var result = await _homeService.SetVehicleRegisterRes(UserId, vehicle);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<BaseValidateForHrm>(ApiResult.Error, 2, result.messages);
            }
        }

        /// <summary>
        /// mở/ khóa xe từ app
        /// </summary>
        /// <param name="vehicle"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPut]
        //[AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> LockVehicleRes([FromBody] HomAppVehicleLock vehicle)
        {
            var rs = await _homeService.LockVehicleRes(UserId, vehicle);
            return GetResponse<string>(ApiResult.Success, null);
        }
        #endregion

        #endregion
    }
}

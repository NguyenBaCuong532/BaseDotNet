using AutoMapper;
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
using UNI.Resident.API.Attributes;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.Model;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.ServiceAPI
{
    /// <summary>
    /// Investment Api for web
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 2020-04-20 9:31 AM
    /// <seealso cref="UniController" />
    [Route("api/v2/serviceapi/cardvehicle/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardVehicleController : UniController
    {
        #region instance-reg
        private readonly ICardVehicleExtService _homeService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="CardVehicleController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public CardVehicleController(
            ICardVehicleExtService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
        }
        #endregion instance-reg

        #region card vehicle

        #region web
        /// <summary>
        /// Set Card
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<BaseValidateForHrm>> SetCardVehicle([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetCardVehicle(this.UserId, info);
            if (result.valid)
            {
                var value = GetResponse<BaseValidateForHrm>(ApiResult.Success, result);
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<BaseValidateForHrm>> SetEmployeeVehicleRes([FromBody] HomCardVehicleForSet info)
        {
            try
            {
                if (!this.ModelState.IsValid)
                {
                    return GetErrorResponse<BaseValidateForHrm>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }

                BaseValidateForHrm rs = await _homeService.SetEmployeeVehicleRes(UserId, info);
                if (rs.valid)
                {
                    return GetResponse<BaseValidateForHrm>(ApiResult.Success, rs);
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<CommonValue>>> GetCardVehicleAsync([FromQuery] string CustId)
        {
            var rs = await _homeService.GetCardVehicle(this.UserId, CustId);
            var response = GetResponse<List<CommonValue>>(ApiResult.Success, rs);
            return response;
        }

        /// <summary>
        /// xóa xe nhân viên
        /// </summary>
        /// <param name="vehicle"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetVehicleRemoveRes([FromBody] HomVehicleRegCancel vehicle)
        {
            var result = await _homeService.SetVehicleRegCancel(this.UserId, vehicle);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, result.code, result.messages);
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetCardLockRes([FromBody] HomCardLock card)
        {
            await _homeService.SetCardLocked(this.UserId, card);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Delete Card
        /// </summary>
        /// <param name="cardCd"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpDelete]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> DeleteCard([FromQuery] string cardCd)
        {
            var result = await _homeService.DeleteCard(this.UserId, cardCd);
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
        [AllowAnonymous]
        [ApiKey]
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetVehicleLockRes([FromBody] HomVehicleLock vehicle)
        {
            var result = await _homeService.SetVehicleLockRes(this.UserId, vehicle);
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
        [AllowAnonymous]
        [ApiKey]
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
        [AllowAnonymous]
        [ApiKey]
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetCustomerResident([FromBody] homCustomerInfo cust)
        {
            await _homeService.SetCustomerResident(this.UserId, cust);
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<BaseValidateForHrm>> SetVehicleRegisterRes([FromBody] homVehicleRegSetApp vehicle)
        {
            var result = await _homeService.SetVehicleRegisterRes(UserId, vehicle);
            if (result.valid)
            {
                return GetResponse<BaseValidateForHrm>(ApiResult.Success,result);
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
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> LockVehicleRes([FromBody] HomAppVehicleLock vehicle)
        {
            var rs = await _homeService.LockVehicleRes(this.UserId, vehicle);
            return GetResponse<string>(ApiResult.Success, null);
        }
        #endregion

        #endregion
    }
}

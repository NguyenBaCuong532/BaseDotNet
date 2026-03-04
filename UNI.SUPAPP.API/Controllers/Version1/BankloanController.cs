using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using SSG.BLL.BusinessServiceInterfaces;
using SSG.Common;
using SSG.Model;
using SSG.Model.Api;
using SSG.Model.Bank;
using System;
using System.Threading.Tasks;

namespace SSG.SupApp.API.Controllers.Version1
{
    /// <summary>
    ///     Vay ngân hàng mua nhà - ngân hàng callback
    /// </summary>
    [Route("api/v1/bankloan/[action]")]
#if !DEBUG
    [ApiExplorerSettings(IgnoreApi = true)]
#endif
    public class BankLoanController : SSGController
    {
        private readonly ICoreUserService _userService;
        private readonly IBankloanService _bankLoanService;
        private readonly IBankCoreService _bankCoreService; // Merge BankLoan back

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userService"></param>
        /// <param name="bankLoanService"></param>
        /// <param name="bankCoreService"></param>
        /// <param name="appSetting"></param>
        /// <param name="logger"></param>
        public BankLoanController(
            ICoreUserService userService,
            IBankloanService bankLoanService,
            IBankCoreService bankCoreService,
            IOptions<AppSettings> appSetting,
            ILoggerFactory logger ): base(appSetting, logger)
        {
            _userService = userService;
            _bankLoanService = bankLoanService;
            _bankCoreService = bankCoreService;
        }

        /// <summary>
        ///      Kiểm tra đầu kết nối với HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<string>> ConnectHdBank()
        {
            try
            {
                var result = GetResponse<string>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var connectBank = await HdBankHelper.ConnectBank();
                if (connectBank.Code != 0)
                {
                    result.AddError(ApiResult.Error, connectBank.Message);
                    return result;
                }

                result.Data = connectBank.Message;

                _logger.LogInformation($"Result Connect HdBank: {connectBank.Message}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error Connect HdBank: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Kiểm tra đầu kết nối với Sunshine
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<string>> ConnectSunshine()
        {
            try
            {
                var result = GetResponse<string>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var connectSunshine = await HdBankHelper.ConnectSunshine();
                if (connectSunshine.Code != 0)
                {
                    result.AddError(ApiResult.Error, connectSunshine.Message);
                    return result;
                }

                result.Data = connectSunshine.Message;

                _logger.LogInformation($"Result Connect Sunshine: Success");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error Connect Sunshine: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Status My Server
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ApiExplorerSettings(IgnoreApi = true)]
        [AllowAnonymous]
        [BankAuthorize]
        public async Task<BaseResponse<string>> StatusMyServer()
        {
            try
            {
                var result = GetResponse<string>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                _logger.LogInformation($"Result Connect Sunshine: Success");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error Connect Sunshine: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Cập nhật thông tin khách hàng HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<hdUpdateCustomerRes>> hdUpdateCustomer([FromBody] hdUpdateCustomerReq customerReq)
        {
            try
            {
                var result = GetResponse<hdUpdateCustomerRes>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var data = await _bankCoreService.hdUpdateCustomer(customerReq);
                if (data.ErrorCode != 0)
                {
                    result.AddError(ApiResult.Error, data.ErrorMessage);
                    return result;
                }

                result.Data = data;

                _logger.LogInformation($"Result hdUpdateCustomer: {JsonConvert.SerializeObject(result)}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error hdUpdateCustomer: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Cập nhật thông tin thu nhập khách hàng HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<hdUpdateIncomeRes>> hdUpdateIncome([FromBody] hdUpdateIncomeReq incomeReq)
        {
            try
            {
                var result = GetResponse<hdUpdateIncomeRes>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var data = await _bankCoreService.hdUpdateIncome(incomeReq);
                if (data.ErrorCode != 0)
                {
                    result.AddError(ApiResult.Error, data.ErrorMessage);
                    return result;
                }

                result.Data = data;

                _logger.LogInformation($"Result hdUpdateIncome: {JsonConvert.SerializeObject(result)}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error hdUpdateIncome: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Cập nhật thông tin gói vay HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<hdUpdateLoanRes>> hdUpdateLoan([FromBody] hdUpdateLoanReq loadReq)
        {
            try
            {
                var result = GetResponse<hdUpdateLoanRes>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var data = await _bankCoreService.hdUpdateLoan(loadReq);
                if (data.ErrorCode != 0)
                {
                    result.AddError(ApiResult.Error, data.ErrorMessage);
                    return result;
                }

                result.Data = data;

                _logger.LogInformation($"Result hdUpdateLoan: {JsonConvert.SerializeObject(result)}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error hdUpdateLoan: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Cập nhật thông tin tài sản đảm bảo HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<hdUpdateCollRes>> hdUpdateColl([FromBody] hdUpdateCollReq collReq)
        {
            try
            {
                var result = GetResponse<hdUpdateCollRes>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var data = await _bankCoreService.hdUpdateColl(collReq);
                if (data.ErrorCode != 0)
                {
                    result.AddError(ApiResult.Error, data.ErrorMessage);
                    return result;
                }

                result.Data = data;

                _logger.LogInformation($"Result hdUpdateColl: {JsonConvert.SerializeObject(result)}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error hdUpdateColl: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Cập nhật thông tin gói vay hiện tại HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<hdUpdateCurrLoanRes>> hdUpdateCurrLoan([FromBody] hdUpdateCurrLoanReq loadReq)
        {
            try
            {
                var result = GetResponse<hdUpdateCurrLoanRes>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var data = await _bankCoreService.hdUpdateCurrLoan(loadReq);
                if (data.ErrorCode != 0)
                {
                    result.AddError(ApiResult.Error, data.ErrorMessage);
                    return result;
                }

                result.Data = data;

                _logger.LogInformation($"Result hdUpdateCurrLoan: {JsonConvert.SerializeObject(result)}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error hdUpdateCurrLoan: {ex}");
                throw;
            }
        }

        /// <summary>
        ///     Cập nhật thông tin tệp đính kèm khi vay HdBank
        /// </summary>
        /// <returns></returns>
        [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
        [HttpPost]
        public async Task<BaseResponse<hdUpdateFileRes>> hdUpdateFile([FromBody] hdUpdateFileReq fileReq)
        {
            try
            {
                var result = GetResponse<hdUpdateFileRes>(ApiResult.Success);

                if (!ModelState.IsValid)
                {
                    result.AddErrors(ApiResult.Error, Errors);
                    return result;
                }

                var data = await _bankCoreService.hdUpdateFile(fileReq);
                if (data.ErrorCode != 0)
                {
                    result.AddError(ApiResult.Error, data.ErrorMessage);
                    return result;
                }

                result.Data = data;

                _logger.LogInformation($"Result hdUpdateFile: {JsonConvert.SerializeObject(result)}");

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error hdUpdateFile: {ex}");
                throw;
            }
        }
    }
}
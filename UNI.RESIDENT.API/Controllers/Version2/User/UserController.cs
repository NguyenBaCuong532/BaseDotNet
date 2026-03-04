using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.Audit;
using UNI.Resident.API.Attributes;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.UserConfig;

namespace UNI.Resident.API.Controllers.Version2.User
{
    /// <summary>
    /// Apartment Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/user/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class UserController : UniController
    {
        /// <summary>
        /// The user service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM

        private readonly IUserConfigService _userConfigService;
        private readonly IUserService _userService;
        /// <summary>
        /// Core User Controller
        /// </summary>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="userConfigService"></param>
        public UserController(
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IUserConfigService userConfigService,
            IUserService userService
            ) : base(appSettings, logger)
        {
            _userConfigService = userConfigService;
            _userService = userService;
        }
        /// <summary>
        /// SetUser - Thêm/sửa thông tin người dùng và dự án
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        [ApiKey]
        [HttpPost]
        public async Task<BaseResponse<string>> SetUserConfigInfo([FromBody] userConfigModel uc)
        {
            try
            {
                var rs = await _userConfigService.SetUserConfig(uc.userId, uc.categoryIds);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message); 
            }
        }
        /// <summary>
        /// AuthenticateAdminAsync - Kiểm tra thông tin user có quyền duyệt 
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<bool>> AuthenticateAdmin()
        {
            try
            {
                var result = await _userService.AuthenticateAdminAsync(UserId);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, false, e.Message);
            }
        }
        /// <summary>
        /// GetUserInfo - Lấy thông tin user
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<UsersInfo>> GetUserInfo([FromQuery] string userId)
        {
            try
            {
                var rs = await _userService.GetUserInfoAsync(userId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<UsersInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetUserInfo - Lưu thông tin user
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetUserInfo([FromBody] UsersInfo info)
        {
            try
            {
                var rs = await _userService.SetUserInfoAsync(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// DeleteUserAsync - Xóa thông tin user
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteUserAsync(string userId)
        {
            try
            {
                var rs = await _userService.DeleteUserAsync(userId);
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
        /// GetUserPage - Danh sách user
        /// </summary>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <param name="gridWidth"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetUserPage([FromQuery] int offset, [FromQuery] int pageSize,  [FromQuery] string filter, [FromQuery] int gridWidth = 0)
        {

                var flt = new UserFilter(ClientId, UserId, offset, pageSize, filter, gridWidth);
                var users = await _userConfigService.GetAllUsersAsync(flt);
                return GetResponse(ApiResult.Success, users);
        }
        /// <summary>
        /// GetUserList
        /// </summary>
        /// <param name="userIds"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetUserList(
            [FromQuery] string userIds,
            [FromQuery] string filter
            )
        {
            var result = await _userConfigService.GetUserList(userIds, filter);
            return GetResponse(ApiResult.Success, result);
        }
    }
}

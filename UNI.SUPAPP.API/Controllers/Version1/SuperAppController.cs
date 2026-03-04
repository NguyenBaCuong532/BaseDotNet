using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM;
using UNI.Model.Core;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.Model.UserConfig;
using UNI.Utils;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// Super App
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 07/02/2020 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/superapp/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class SuperAppController : SSGController
    {
        private const string _PREFIX = "ssupapp_";

        private readonly IUserAppService1 _userService;
        private readonly IAppManagerService _appService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="SuperAppController"/> class.
        /// </summary>
        /// <param name="userService"></param>
        /// <param name="appService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public SuperAppController(
            IUserAppService1 userService,
            IAppManagerService appService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _userService = userService;
            _appService = appService;
            //_custService = custService;
            //_spayService = spayService;
        }
        #region "User Login"
        /// <summary>
        /// Set User Register
        /// </summary>
        /// <param name="register"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<userLoginRefesh>> SetUserRegister([FromBody] userRegister register)
        {
            if (register.loginType == 0 && !Utils.IsPhoneNumberVN(register.phone))
            {
                return GetResponse<userLoginRefesh>(ApiResult.Invalid, null);
            }
            register.userType = 2;
            var result = await _userService.SetUserRegister(register, _PREFIX);
            if (register.loginType == 0)
            {
                if (!result.Data.IsCreatePassword)
                {
                    var otp = await _appService.TakeOTP(this.CtrlClient, new WalUserGrant(result.Data.loginName, register.phone, ""));
                    if (otp == null)
                    {
                        return GetErrorResponse<userLoginRefesh>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
                    }
                    if (!otp.valid)
                    {
                        return GetErrorResponse<userLoginRefesh>(ApiResult.Invalid, 2, otp.messages);
                    }
                    result.Data.secret_cd = otp.secret_cd;
                }
            }
            else if (result.Data == null)
            {
                return GetResponse<userLoginRefesh>(ApiResult.Invalid, null);
            }
            else
            {
                //await _userService.SetCreateAuthenRole(_PREFIX + register.phone, UNIApiRole.ROL_CAB_USR);
            }
            return result;
        }
        /// <summary>
        /// SetUserRegisterNew
        /// </summary>
        /// <param name="register"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<coreUserLoginResponse>> SetUserRegisterNew([FromBody] coreUserLoginReg register)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            if (!register.phone.StartsWith("0"))
            {
                register.phone = "0" + register.phone;
            }
            if (!string.IsNullOrEmpty(register.email) && !Utils.isEmailValid(register.email))
            {
                return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, (int)ErrorCode.InvalidEmail,
                    ErrorCode.InvalidEmail.GetDescription());
            }
            if (register.verifyType == 0 && !Utils.IsPhoneNumberVN(register.phone))
            {
                return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, (int)ErrorCode.InvalidPhone,
                    ErrorCode.InvalidPhone.GetDescription());
            }
            register.loginName = _PREFIX + register.phone;
            if (register.loginName.Any(ch => !Char.IsLetterOrDigit(ch) && ch != '_'))
            {
                return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, (int)ErrorCode.UsernameSpec,
                    ErrorCode.UsernameSpec.GetDescription());
            }
            //var user = await _userService.FindUserByName(register.loginName);
            //if (user != null)
            //{
            //    return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, (int)ErrorCode.UsernameExists,
            //        ErrorCode.UsernameExists.GetDescription());
            //}
            
            //var app = _appService.GetClientApp(this.ClientId); app.user_type = 1;
            var result = await _userService.SetUserRegister(register, 1);
            if (result != null && result.valid)
            {
                var gToken = new WalUserGrant(result.reg_id, result.phone, result.email, result.verifyType);
                var otp = await _appService.TakeOTP(this.CtrlClient, gToken);
                if (otp == null)
                {
                    return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
                }
                if (!otp.valid)
                {
                    return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, 2, otp.messages);
                }
                result.secret_cd = otp.secret_cd;
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<coreUserLoginResponse>(ApiResult.Invalid, 2, result.messages);
            }
        }
        //
        [HttpPut]
        public async Task<BaseResponse<userLoginRefesh>> SetVerifyCode([FromBody] coreVerify code)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<userLoginRefesh>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var registed = _userService.GetUserRegisted(code.reg_id);
            if (registed == null)
            {
                return GetErrorResponse<userLoginRefesh>(ApiResult.Invalid, 2, "Dữ liệu không hợp lệ");
            }
            var code1 = new userVerification { userId = code.reg_id, verificationCode = code.code, secret_cd = code.secret_cd, tokenType = registed.verifyType };
            var result = await _appService.SetVerificationCode(this.UserId, code1);
            if (result.Status == 1)
            {
                var login = await _userService.SetVerificated(code, registed);
                if (login != null)
                {
                    return GetResponse(ApiResult.Success, login);
                }
                else
                {
                    return GetErrorResponse<userLoginRefesh>(ApiResult.Fail, (int)ErrorCode.CreateUserIdentity,
                        ErrorCode.CreateUserIdentity.GetDescription());
                }
            }
            else
            {
                if (result.Blocked)
                {
                    await _userService.SetLockUser(registed.userId.ToString(), true);
                }
                return GetErrorResponse<userLoginRefesh>(ApiResult.Fail, result.Status, result.StatusMessage);
            }
        }
        /// <summary>
        /// SetResendCode - Lấy lại mã đăng nhập
        /// </summary>
        /// <returns></returns>
        /// 
        //
        [HttpPut]
        public async Task<BaseResponse<OtpMessageResponse>> SetResendCode([FromBody] userForegetSetRespone login)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _userService.SetResendCode(login.reg_id);
            if (result != null && result.valid)
            {
                var gToken = new WalUserGrant(result.loginName, result.phone, result.email, login.verifyType);
                var otp = await _appService.TakeOTP(this.CtrlClient, gToken);
                if (otp == null)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
                }
                if (!otp.valid)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, otp.messages);
                }
                return GetResponse<OtpMessageResponse>(ApiResult.Success, otp.response());
            }
            else
            {
                return GetErrorResponse<OtpMessageResponse>(ApiResult.Fail, 2, result.messages);
            }
        }

        /// <summary>
        /// Set User Foreget Password
        /// </summary>
        /// <param name="foreget"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<OtpMessageResponse>> SetUserForegetPassword([FromBody] userBasePhone foreget)
        {
            if (!Utils.IsPhoneNumberVN(foreget.phone))
            {
                return GetResponse<OtpMessageResponse>(ApiResult.Invalid, null);
            }
            //var app = _userService.GetClientApp(this.ClientId);
            if ( true) //app.IsLoginCustomer)
            {
                await _userService.SetUserForegetPassword(foreget, _PREFIX);
                var otp = await _appService.TakeOTP(this.CtrlClient, new WalUserGrant(_PREFIX + foreget.phone, foreget.phone, "", 0));
                if (otp == null)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
                }
                if (!otp.valid)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, otp.messages);
                }
                return GetResponse<OtpMessageResponse>(ApiResult.Success, otp.response());
            }
            else
            {
                await _userService.SetUserForegetPassword(foreget, "");
                var otp = await _appService.TakeOTP(this.CtrlClient, new WalUserGrant("" + foreget.phone, foreget.phone, "", 0));
                if (otp == null)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
                }
                if (!otp.valid)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, otp.messages);
                }
                return GetResponse<OtpMessageResponse>(ApiResult.Success, otp.response());
            }
            
        }
        /// <summary>
        /// Set User Verification Code
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<userLoginRefesh>> SetVerificationCode([FromBody] userVerification code)
        {
            var result = await _appService.SetVerificationCode(code.loginName, code);
            if (result.Status == 1)
            {
                var uprofile = _userService.SetVerificated(code.loginName, code.tokenType);
                var newUser = await _userService.SetUserLoginRefesh(uprofile);
                if (newUser != null)
                {
                    if (code.tokenType == 0)
                    {
                        //await _userService.SetCreateAuthenRole(uprofile.userLogin, SSGApiRole.ROL_CAB_USR);
                        //await _spayService.SetWalActived(uprofile.phone);
                    }
                    //if (newUser.is_Agreed_Term == false)
                    //{
                    //    newUser.term_Content = _appService.GetAppTerm(_PREFIX, 0);
                    //}
                    return GetResponse<userLoginRefesh>(ApiResult.Success, newUser);
                }
                else
                {
                    return GetResponse<userLoginRefesh>(ApiResult.Fail, null);
                }
            }
            else
            {
                var response = GetResponse<userLoginRefesh>(ApiResult.Error, null);
                response.SetStatus(result.Status, result.StatusMessage);
                return response;
            }
        }
        /// <summary>
        /// Set User Agreed Term
        /// </summary>
        /// <param name="term"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetUserAgreedTerm([FromBody] userAgeedTerm term)
        {
            var result = _userService.GetUserProfile(term.loginName);
            if (result != null && result.isVerify == 1)
            {
                await _userService.SetUserAgreedTerm(term);
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetResponse<string>(ApiResult.Fail, null);
            }
        }
        /// <summary>
        /// Set User Profile and Actived
        /// </summary>
        /// <param name="upgrade"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetUserProfileUpgrade([FromBody] userUpgrate upgrade)
        {
            var result = _userService.GetUserProfile(upgrade.loginName);
            if (result != null && result.isVerify == 1)
            {
                result.fullName = upgrade.fullName;
                result.email = upgrade.email;
                if (upgrade.phone != null)
                {
                    //result.phone = upgrade.phone;
                    //var cust = _custService.GetCustomerBase(upgrade.phone);
                    //if (cust == null)
                    //{
                    //    cust = _custService.SetCustomer(this.CtrlClient, new Model.SHome.CustomerShort(result.phone, result.email, result.fullName), true);
                    //}
                    //if (result.custId != cust.CustId)
                    //{
                    //    return GetResponse<string>(ApiResult.Fail, null);
                    //}
                    //await _spayService.SetWalActived(upgrade.phone);
                }
                _userService.SetUserProfile(result);
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetResponse<string>(ApiResult.Fail, null);
            }
        }
        /// <summary>
        /// Set Verification Refresh
        /// </summary>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<OtpMessageResponse>> SetVerificationRefresh([FromBody] userBasePhone login)
        {
            string userLogin = login.phone;
            //var app = _userService.GetClientApp(this.ClientId);
            //if (app.IsLoginCustomer)
            {
                userLogin = _PREFIX + userLogin;
            }
            //if (login.loginName != null)
            //{
            //    userLogin = login.loginName;
            //}
            var result = _userService.GetUserProfile(userLogin);
            if (result != null && result.isVerify == 0)
            {
                var otp = await _appService.TakeOTP(this.CtrlClient, new WalUserGrant(userLogin, login.phone, "", login.tokenType));
                if (otp == null)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
                }
                if (!otp.valid)
                {
                    return GetErrorResponse<OtpMessageResponse>(ApiResult.Invalid, 2, otp.messages);
                }
                return GetResponse<OtpMessageResponse>(ApiResult.Success, otp.response());
            }
            else
            {
                return GetResponse<OtpMessageResponse>(ApiResult.Fail, null);
            }
        }
        
        #endregion login

        /// <summary>
        /// Reset Password - Cập nhật mật khẩu
        /// </summary>
        /// <param name="passwordSet"></param>
        /// <returns></returns>
        /// 
        [HttpPut]
        public async Task<BaseResponse<string>> SetUserPassword([FromBody] SetUserPassword passwordSet)
        {
            var result = await _userService.ResetPassword(passwordSet);
            if (result.StatusCode == 200)
                return GetResponse<string>(ApiResult.Success, result.Value.ToString());
            else
                return GetResponse<string>(ApiResult.Fail, result.Value.ToString());
        }
        /// <summary>
        /// GetUserForgetPassword - Quên mật khẩu
        /// </summary>
        /// <param name="loginName">Tên đăng nhập</param>
        /// <param name="udid">Mã thiết bị</param>
        /// <returns></returns>
        /// 
        //
        [HttpGet]
        public async Task<BaseResponse<userForegetResponse>> GetUserForgetPassword([FromQuery] string loginName, [FromQuery] string udid)
        {
            if (loginName.Any(ch => !Char.IsLetterOrDigit(ch) && ch != '_'))
            {
                return GetErrorResponse<userForegetResponse>(ApiResult.Invalid, (int)ErrorCode.UsernameSpec,
                    ErrorCode.UsernameSpec.GetDescription());
            }
            var user = await _userService.FindUserByName(loginName);
            if (user == null)
            {
                return GetErrorResponse<userForegetResponse>(ApiResult.Invalid, (int)ErrorCode.UsernameNotExists,
                    ErrorCode.UsernameNotExists.GetDescription());
            }
            if (user.LockoutEnabled && user.LockoutEnd != null && user.LockoutEnd > DateTime.Now)
            {
                //await _userService.SetUserLocked(user.Id, true);
                await _userService.SetLockUser(user.Id, false);
                return GetErrorResponse<userForegetResponse>(ApiResult.Invalid, (int)ErrorCode.UsernameLocked,
                    ErrorCode.UsernameLocked.GetDescription());
            }
            var result = _userService.GetUserForgetPassword(this.ClientId, loginName, udid);
            if (result.valid)
                return GetResponse<userForegetResponse>(ApiResult.Success, result);
            else
                return GetErrorResponse<userForegetResponse>(ApiResult.Invalid, 2, result.messages);
        }
        /// <summary>
        /// SetUserForgetPassword - Gửi yê cầu xác minh
        /// </summary>
        /// <param name="forget"></param>
        /// <returns></returns>
        /// 
        //
        [HttpPost]
        public async Task<BaseResponse<userForegetSetRespone>> SetUserForgetPassword([FromBody] userForegetSet forget)
        {
            var result = await _userService.SetUserForgetPassword(this.ClientId, forget);
            if (result == null)
            {
                return GetErrorResponse<userForegetSetRespone>(ApiResult.Fail, 2, result.messages);
            }
            if (!result.valid)
            {
                return GetErrorResponse<userForegetSetRespone>(ApiResult.Fail, 2, result.messages);
            }
            if (result.userId == null)
            {
                return GetErrorResponse<userForegetSetRespone>(ApiResult.Invalid, 2, "Thông ti");
            }

            var gToken = new WalUserGrant(result.reg_id, result.phone, result.email, result.verifyType);
            var otp = await _appService.TakeOTP(this.CtrlClient, gToken);
            if (otp == null)
            {
                return GetErrorResponse<userForegetSetRespone>(ApiResult.Invalid, 2, "Lỗi không tạo được OTP");
            }
            if (!otp.valid)
            {
                return GetErrorResponse<userForegetSetRespone>(ApiResult.Invalid, 2, otp.messages);
            }
            var fget = _userService.GetUserForgetPassword(this.ClientId, forget.loginName, forget.udid);
            return GetResponse<userForegetSetRespone>(ApiResult.Success,
                new userForegetSetRespone
                {
                    reg_id = result.reg_id,
                    secret_cd = otp.secret_cd,
                    phone = fget.phone,
                    email = fget.email,
                    verifyType = result.verifyType
                });

        }
        /// <summary>
        /// SetUserForgetVerifyCode - Xác minh để tạo lại mật khẩu
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        /// 
        //
        [HttpPut]
        public async Task<BaseResponse<userLoginRefesh>> SetUserForgetVerifyCode([FromBody] coreVerify code)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<userLoginRefesh>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var registed = _userService.GetUserRegisted(code.reg_id);
            if (registed == null)
            {
                return GetErrorResponse<userLoginRefesh>(ApiResult.Invalid, 2, "Dữ liệu không hợp lệ");
            }
            var code1 = new userVerification { userId = code.reg_id, verificationCode = code.code, secret_cd = code.secret_cd, tokenType = registed.verifyType };
            var result = await _appService.SetVerificationCode(this.UserId, code1);
            if (result.Status == 1)
            {
                //var app = _appService.GetClientApp(this.ClientId);
                var login = await _userService.SetUserForgetVerificated(code, registed, 1);
                if (login != null)
                {
                    await _userService.SetLockUser(registed.userId.ToString(), false);
                    return GetResponse(ApiResult.Success, login);
                }
                else
                {
                    return GetErrorResponse<userLoginRefesh>(ApiResult.Fail, (int)ErrorCode.CreateUserIdentity,
                        ErrorCode.CreateUserIdentity.GetDescription());
                }
            }
            else
            {
                if (result.Blocked)
                {
                    await _userService.SetLockUser(registed.userId.ToString(), true);
                }
                return GetErrorResponse<userLoginRefesh>(ApiResult.Fail, result.Status, result.StatusMessage);
            }
        }

        [HttpPost]
        [AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<string>> SetMessage([FromBody] MessageSend message)
        {
            //await _appService.TakeMessage(this.CtrlClient, message);
            //return GetResponse<string>(ApiResult.Success, null);
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                var result = await _appService.TakeMessage(CtrlClient, message);
                return GetResponse(ApiResult.Success, "Pass");
            }
            catch (Exception ex)
            {
                //await _taskService.SetMessageSent(new MessageSent { messageId = message.messageId, errorNum = 500, errorDes = 1 });
                _logger.LogError(ex.StackTrace);
                return GetResponse(ApiResult.Success, "fall");
            }
        }


        #region supper app
        /// <summary>
        /// Get Profile By Id
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<UserProfileFull> GetProfileById()
        {
            var result = _userService.GetProfileById(this.UserId, null);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Profile Fields
        /// </summary>
        /// <param name="loginName">Uu tien dung so 1</param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<viewField>> GetProfileFields([FromQuery] string loginName)
        {
            var result = _userService.GetProfileFields(this.UserId, loginName);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Profile field
        /// </summary>
        /// <param name="fields"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetProfileFields([FromBody] coreUserFields fields)
        {
            await _userService.SetProfileFields(this.UserId, fields);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Profile Idcard
        /// </summary>
        /// <param name="idcard"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetProfileIdcard([FromBody] coreUserIdcardSet idcard)
        {
            await _userService.SetProfileIdcardAdd(this.UserId, idcard);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Get Profile Metas
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<coreUserProfileMeta>> GetProfileMetas([FromQuery] string loginName)
        {
            var result = _userService.GetProfileMetas(this.UserId, loginName);
            return GetResponse<List<coreUserProfileMeta>>(ApiResult.Success, result);
        }
        /// <summary>
        /// Set User Document
        /// </summary>
        /// <param name="meta"></param>
        /// <returns></returns>
        [HttpPost]
        public BaseResponse<string> SetProfileMeta([FromBody] coreUserMetas meta)
        {
            _userService.SetProfileMeta(this.UserId, meta);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Delete Profile Meta
        /// </summary>
        /// <param name="metaId"></param>
        /// <returns></returns>
        /// 
        [HttpDelete]
        public async Task<BaseResponse<string>> DelProfileMeta([FromQuery] Guid metaId)
        {
            await _userService.DelProfileMeta(this.UserId, metaId);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set User Invite - Gán người giới thiệu
        /// </summary>
        /// <param name="invite"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetUserInvitedBy([FromBody] userInvite invite)
        {
            var result = await _userService.SetUserInvitedBy(this.UserId, invite);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Fail, 2, result.messages);
            }
        }
        /// <summary>
        /// Get User Invited - Người giới thiệu của tôi
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<userInviteGet> GetUserInvited()
        {
            var result = _userService.GetUserInvited(this.UserId);
            return GetResponse<userInviteGet>(ApiResult.Success, result);
        }

        /// <summary>
        /// Set Profile Link Facebook
        /// </summary>
        /// <param name="profile"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetProfileLinkFacebook([FromBody] fbUserProfile profile)
        {
            await _userService.SetProfileLinkFacebook(this.UserId, profile);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Get Pay History List
        /// </summary>
        /// <param name="dbcr_flag"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        /// 
        [HttpGet]
        public ResponseList<List<corePointTrans>> GetPointTransactions([FromQuery] int dbcr_flag,
            [FromQuery] int offSet, [FromQuery] int pageSize)
        {
            var flt = new FilterBase(this.ClientId, this.UserId, offSet, pageSize, dbcr_flag.ToString(), 0);
            var result = _userService.GetPointTransactions(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }

        #endregion supper app

    }
}

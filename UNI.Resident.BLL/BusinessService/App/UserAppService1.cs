using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Account;
using UNI.Model.Api;
using UNI.Model.Core;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.BLL.HelperService;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.UserConfig;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// Class User Service.
    /// <author>Thien TH</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public class UserAppService1 : IUserAppService1
    {
        private readonly IUserAppRepository1 _userRepository;

        private readonly UserManager<IdentityUser> _userManager;

        private UserTokenService _usertokenService;
        public UserAppService1(
            IUserAppRepository1 userRepository,
            UserManager<IdentityUser> userManager
            )
        {
            if (userRepository != null)
                _userRepository = userRepository;
            if (userManager != null)
                _userManager = userManager;

            _usertokenService = new UserTokenService();
        }
        
        public async Task<ObjectResult> SetLockUser(string userId, bool isLock)
        {
            if (isLock)
            {
                var applicationUser = await _userManager.FindByIdAsync(userId);
                var result = await _userManager.SetLockoutEnabledAsync(applicationUser, true);
                if (result.Succeeded)
                {
                    await _userManager.SetLockoutEndDateAsync(applicationUser, DateTimeOffset.MaxValue);
                    await _userRepository.LockUser(userId, isLock);
                    return new OkObjectResult("successed");
                }
                else
                    return new BadRequestObjectResult("Error");
            }
            else
            {
                var applicationUser = await _userManager.FindByIdAsync(userId);
                var result = await _userManager.SetLockoutEndDateAsync(applicationUser, new DateTimeOffset(DateTime.Now));
                if (result.Succeeded)
                {
                    await _userRepository.LockUser(userId, isLock);
                    return new OkObjectResult("successed");
                }
                else
                    return new BadRequestObjectResult("Error");
            }
        }
        
        public async Task<ObjectResult> ResetPassword(SetUserPassword passwordSet)
        {
            var user = await _userManager.FindByNameAsync(passwordSet.UserLogin);
            if (user != null)
            {

                var token = await _userManager.GeneratePasswordResetTokenAsync(user);
                var result = await _userManager.ResetPasswordAsync(user, token, passwordSet.UserPassword);
                if (result.Succeeded)
                {
                    Console.WriteLine("======================================================abccccc==hoanpv");
                    return new OkObjectResult(Constants.StatusSuccess);
                }
                else
                {
                    Console.WriteLine("========================================================hoanpv11111111");
                    return new BadRequestObjectResult(result);
                }
            }
            return new BadRequestObjectResult(Constants.Statusfail);
        }
       
        public async Task<IdentityUser> FindUserByName(string userName)
        {
            return await _userManager.FindByNameAsync(userName);
        }
        
        //public async Task<ObjectResult> SetCreateAuthenRole(string userName, string roler)
        //{
        //    var user = await _userManager.FindByNameAsync(userName);
        //    if (user != null)
        //    {
        //        var roles = await _userManager.GetRolesAsync(user);
        //        if (!roles.Contains(roler))
        //        {
        //            var createURole = await _userManager.AddToRoleAsync(user, roler);
        //            if (createURole.Succeeded || createURole.Errors.FirstOrDefault().Code == "UserAlreadyInRole")
        //            {
        //                return new OkObjectResult(Constants.StatusSuccess);
        //            }
        //            else
        //            {
        //                return new BadRequestObjectResult(Constants.Statusfail);
        //            }
        //        }
        //        else
        //        {
        //            return new OkObjectResult(Constants.StatusSuccess);
        //        }
        //    }
        //    else
        //    {
        //        return new BadRequestObjectResult("User don't exist!");
        //    }
        //}
        public async Task<ObjectResult> SetCreateAuthenUser(RegisterUserModel user)
        {
            try
            {
                var newUser = new IdentityUser { UserName = user.UserName, Email = user.Email, NormalizedUserName = user.FullName, PhoneNumber = user.Phone };
                var fUser = await _userManager.FindByNameAsync(user.UserName);
                if (fUser == null)
                {
                    var createUserResult = await _userManager.CreateAsync(newUser, user.Password);
                    if (createUserResult.Succeeded)
                    {
                        fUser = newUser;
                        return new OkObjectResult(newUser.Id);
                    }
                    else
                    {
                        return new BadRequestObjectResult(string.Join(", ", createUserResult.Errors.Select(e => "[" + e.Code + " : " + e.Description + "]")));
                    }
                }
                else
                {
                    return new BadRequestObjectResult("User is exist!");
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //public async Task<string> GenerateEmailConfirmationToken(IdentityUser user)
        //{
        //    return await _userManager.GenerateEmailConfirmationTokenAsync(user);
        //}
        public async Task<BaseResponse<userLoginRefesh>> SetUserRegister(userRegister reg, string preFix)
        {
            if (reg.loginType == 0)
            {
                if (reg.phone.Substring(0, 1) != "0")
                {
                    reg.phone = "0" + reg.phone;
                }
                var ureg = new userProfileSet { userLogin = preFix + reg.phone, phone = reg.phone, loginType = 0, isVerify = 0, phoneF = reg.phoneF, userType = reg.userType };
                var bUser = _userRepository.SetUserProfile(ureg);
                //_corUserRepository.SetUserRegister(client, ureg);
                return new BaseResponse<userLoginRefesh>(ApiResult.Success, bUser.LoginRefesh());
            }
            else
            {
                if (reg.loginType == 1)
                {
                    var fbPf = _usertokenService.GetFbProfile(reg.tokenLogin);
                    if (fbPf == null)
                        return new BaseResponse<userLoginRefesh>(ApiResult.Invalid, null);
                    var ureg = new userProfileSet { loginId = fbPf.id, userLogin = preFix + fbPf.id, loginType = reg.loginType, isVerify = 1, fullName = fbPf.name, email = fbPf.email };
                    var bURef = await SetUserLoginRefesh(ureg);
                    return new BaseResponse<userLoginRefesh>(ApiResult.Success, bURef);
                }
                else
                {
                    var ggPf = _usertokenService.GetGgProfile(reg.tokenLogin);
                    if (ggPf == null)
                        return new BaseResponse<userLoginRefesh>(ApiResult.Invalid, null);
                    var ureg = new userProfileSet { loginId = ggPf.id, userLogin = preFix + ggPf.id, loginType = reg.loginType, isVerify = 1, fullName = ggPf.name, email = ggPf.email, avatarUrl = ggPf.picture };
                    var bURef = await SetUserLoginRefesh(ureg);
                    return new BaseResponse<userLoginRefesh>(ApiResult.Success, bURef);
                }
            }
        }
        public Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg, int user_type)
        {
            return _userRepository.SetUserRegister(reg, user_type);
        }
        public userProfileSet SetVerificated(string loginUser, int tokenType)
        {
            //_corUserRepository.SetProfileVerificated(loginUser, tokenType);
            return _userRepository.SetVerificated(loginUser, tokenType);
        }

        public userProfileSet GetUserProfile(string loginUser)
        {
            return _userRepository.GetUserProfile(loginUser);
        }
        
        public async Task<userLoginRefesh> SetUserLoginRefesh(userProfileSet profile)
        {
            string loginSecret = Guid.NewGuid().ToString();
            var account = await _userManager.FindByNameAsync(profile.userLogin);
            if (account == null)
            {
                var result = await SetCreateAuthenUser(new RegisterUserModel
                {
                    UserName = profile.userLogin,
                    Email = profile.email,
                    Password = loginSecret,
                    FullName = profile.fullName
                });
                if (result.StatusCode == 200)
                {
                    profile.userId = Guid.Parse(result.Value.ToString());
                }
                else
                    return null;
            }
            else
            {
                var respass = await ResetPassword(new SetUserPassword { UserLogin = profile.userLogin, UserPassword = loginSecret });
                if (respass.StatusCode != 200)
                    return null;
                profile.userId = Guid.Parse(account.Id);
            }
            //var bUser = _userRepository.SetUserRegister(client, profile, loginSecret);
            var bUser = _userRepository.SetLoginUserId(profile.userLogin, profile.userId.ToString(), loginSecret);
            //_corUserRepository.SetLoginUserId(profile.userLogin, profile.userId);
            return bUser.LoginRefesh(loginSecret);

        }
        public userProfileBase SetUserProfile(userProfileSet profile)
        {
            return _userRepository.SetUserProfile(profile);
        }
        
        public List<ProjectApp> GetProjectList(string userId)
        {
            return _userRepository.GetProjectList(userId);
        }
        
        public Task SetUserForegetPassword(userBasePhone foreget, string preFix)
        {
            return _userRepository.SetUserForegetPassword(foreget, preFix);
        }
        public Task SetUserAgreedTerm(userAgeedTerm term)
        {
            return _userRepository.SetUserAgreedTerm(term);
        }

        public userForegetResponse GetUserForgetPassword(string clientId, string loginName, string udid)
        {
            return _userRepository.GetUserForgetPassword(clientId, loginName, udid);
        }
        public Task<coreUserLoginResponse> SetUserForgetPassword(string clientId, userForegetSet forget)
        {
            return _userRepository.SetUserForgetPassword(clientId, forget);
        }
        public async Task<userLoginRefesh> SetUserForgetVerificated(coreVerify code, coreUserLoginResponse registed, int user_type)
        {
            userLoginRefesh login = null;
            string loginSecret = Guid.NewGuid().ToString();
            var user = await _userManager.FindByNameAsync(registed.loginName);
            if (user != null)
            {
                var token = await _userManager.GeneratePasswordResetTokenAsync(user);
                var result = await _userManager.ResetPasswordAsync(user, token, loginSecret);
                if (result.Succeeded)
                {
                    await _userRepository.SetUserForgetVerificated(code, user_type);
                    login = new userLoginRefesh { loginName = registed.loginName, loginSecret = loginSecret, IsCreatePassword = true };
                }
            }
            return login;
        }
        public coreUserLoginResponse GetUserRegisted(string reg_id)
        {
            return _userRepository.GetUserRegisted(reg_id);
        }
        public async Task<userLoginRefesh> SetVerificated(coreVerify code, coreUserLoginResponse registed)
        {
            userLoginRefesh login = null;
            string loginSecret = Guid.NewGuid().ToString();
            var account = await _userManager.FindByNameAsync(registed.loginName);
            if (account == null)
            {
                var result = await SetCreateAuthenUser(new RegisterUserModel
                {
                    UserName = registed.loginName,
                    Phone = registed.phone,
                    Email = registed.email,
                    Password = loginSecret,
                    FullName = registed.fullName
                });
                if (result.StatusCode == 200)
                {
                    login = await _userRepository.SetVerificated(code, result.Value.ToString());
                    login.loginSecret = loginSecret;
                }
            }
            else
            {
                login = await _userRepository.SetVerificated(code, account.Id);
                login.loginSecret = loginSecret;
            }
            return login;
        }
        public Task<coreUserLoginResponse> SetResendCode(string reg_id)
        {
            return _userRepository.SetResendCode(reg_id);
        }

        #region supper app
        public UserProfileFull GetProfileById(string userId, string loginName)
        {
            return _userRepository.GetProfileById(userId, loginName);
        }
        public List<viewField> GetProfileFields(string userId, string loginName)
        {
            return _userRepository.GetProfileFields(userId, loginName);
        }
        public List<coreUserProfileMeta> GetProfileMetas(string userId, string loginName)
        {
            return _userRepository.GetProfileMetas(userId, loginName);
        }
        public Task SetProfileFields(string userId, coreUserFields fields)
        {
            return _userRepository.SetProfileFields(userId, fields);
        }
        public Task SetProfileIdcardAdd(string userId, coreUserIdcardSet profile)
        {
            return _userRepository.SetProfileIdcardAdd(userId, profile);
        }
        public Task DelProfileMeta(string userId, Guid metaId)
        {
            return _userRepository.DelProfileMeta(userId, metaId);
        }
        public int SetProfileMeta(string userId, coreUserMetas meta)
        {
            return _userRepository.SetProfileMetas(userId, meta);
        }
        public Task SetProfileLinkFacebook(string userId, fbUserProfile profile)
        {
            return _userRepository.SetProfileLinkFacebook(userId, profile);
        }
        public ResponseList<List<corePointTrans>> GetPointTransactions(FilterBase filter)
        {
            return _userRepository.GetPointTransactions(filter);
        }

        #endregion

        #region Invited
        public Task<BaseValidate> SetUserInvitedBy(string userId, userInvite invite)
        {
            return _userRepository.SetUserInvitedBy(userId, invite);
        }
        public userInviteGet GetUserInvited(string userId)
        {
            return _userRepository.GetUserInvited(userId);
        }
        #endregion
    }
}

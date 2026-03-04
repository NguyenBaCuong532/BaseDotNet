using Google.Cloud.Firestore;
using Keycloak.Net.Models.Users;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Account;
using UNI.Model.APPM;
using UNI.Model.Core;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces.App;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// Class User Service.
    /// <author>duongpx</author>
    /// <date>2024/12/02</date>
    /// </summary>
    public class AppUserService : IAppUserService
    {
        private readonly IAppUserRepository _userRepository;
        private readonly IApiProfileService _apiUserService;
        //private readonly IApiRocketChatService _rocketChatService;
        //private readonly IApiFireBaseService _firebaseService;
        public AppUserService(
            IAppUserRepository userRepository,
            IApiProfileService apiProfileService
            //IApiRocketChatService rocketChatService,
            //IApiFireBaseService firebaseService
            )
        {
            if (userRepository != null)
                _userRepository = userRepository;

            //_apiUserService = apiProfileService;
            //_rocketChatService = rocketChatService;
            //_firebaseService = firebaseService;
        }
        public Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg)
        {
            return _userRepository.SetUserRegister(reg);
        }
        public async Task<coreUserLoginResponse> GetUserRegisted(string reg_id)
        {
            return await _userRepository.GetUserRegisted(reg_id);
        }
        public async Task<userLoginRefesh> SetVerificated(coreVerify code, coreUserLoginResponse registed)
        {
            userLoginRefesh login = null;
            string loginSecret = Guid.NewGuid().ToString();
            var account = await _apiUserService.GetUserByUserName(registed.loginName);
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
                    account = await _apiUserService.GetUserByUserName(registed.loginName);
                    //thiet lap pass word tạm
                    var createPass = await _apiUserService.ResetUserPassword(account.Id, loginSecret, false);
                    if (createPass)
                    {
                        login = await _userRepository.SetVerificated(code, account.Id);
                        login.loginSecret = loginSecret;
                    }
                }
            }
            else
            {
                account = await _apiUserService.GetUserByUserName(registed.loginName);
                //thiet lap pass word tạm
                var createPass = await _apiUserService.ResetUserPassword(account.Id, loginSecret, false);
                if (createPass)
                {
                    login = await _userRepository.SetVerificated(code, account.Id);
                    login.loginSecret = loginSecret;
                }
            }
            return login;
        }

        public async Task<ObjectResult> SetLockUser(string userId, bool isLock)
        {
            if (isLock)
            {
                var result = await _apiUserService.SetUserStatus(userId, isLock);
                if (result)
                {
                    await _userRepository.LockUser(userId, isLock);
                    return new OkObjectResult("successed");
                }
                else
                    return new BadRequestObjectResult("Error");
            }
            else
            {
                var result = await _apiUserService.SetUserStatus(userId, isLock);
                //var applicationUser = await _userManager.FindByIdAsync(userId);
                //var result = await _userManager.SetLockoutEndDateAsync(applicationUser, new DateTimeOffset(DateTime.Now));
                if (result)
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
            var user = await _apiUserService.GetUserByUserName(passwordSet.UserLogin);
            if (user != null)
            {
                var result = await _apiUserService.ResetUserPassword(user.Id, passwordSet.UserPassword, false);
                if (result)
                {
                    return new OkObjectResult(Constants.StatusSuccess);
                }
                else
                {
                    return new BadRequestObjectResult(result);
                }
            }
            return new BadRequestObjectResult(Constants.Statusfail);
        }
        public async Task<User> FindUserByName(string userName)
        {
            return await _apiUserService.GetUserByUserName(userName);
        }
        public async Task<ObjectResult> SetCreateAuthenUser(RegisterUserModel user)
        {
            try
            {
                var newUser = new User { UserName = user.UserName, Email = user.Email, LastName = user.FullName, Enabled = true };
                var fUser = await _apiUserService.GetUserByUserName(user.UserName);
                if (fUser == null)
                {
                    var createUserResult = await _apiUserService.AddUser(null, newUser);
                    if (createUserResult)
                    {
                        fUser = newUser;
                        return new OkObjectResult(newUser.Id);
                    }
                    else
                    {
                        return new BadRequestObjectResult("Can't user");
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
        
        public async Task<userProfileSet> GetUserProfile(string loginUser)
        {
            return await _userRepository.GetUserProfile(loginUser);
        }
        
        public async Task<BaseValidate> SetUserProfile(string userId, UserProfileSet ureg)
        {
            var result = await  _userRepository.SetUserProfile(userId, ureg);
            if (result.valid)
            {
                try
                {
                    // Fire-and-forget: chạy nền, không await
                    //_ = Task.Run(() => _firebaseService.setFirebaseProfile(userId, ureg.avatarUrl, ureg.fullName, ureg.fullName));
                    //_ = Task.Run(() => _rocketChatService.UpdateRocketchatInfoAsync(ureg));
                }
                catch(Exception ex)
                {
                    Log.Error("SetUserProfile_" + DateTime.Now.ToString() + "_" + ex.ToString());
                }
                
            }
            return result;
        }        
        public async Task<userForegetResponse> GetUserForgetPassword(string loginName, string udid)
        {
            return await _userRepository.GetUserForgetPassword(loginName, udid);
        }
        public async Task<coreUserLoginResponse> SetUserForgetPassword(userForegetSet forget)
        {
            return await _userRepository.SetUserForgetPassword(forget);
        }
        public async Task<userLoginRefesh> SetUserForgetVerificated(coreVerify code, coreUserLoginResponse registed, int user_type)
        {
            userLoginRefesh login = null;
            string loginSecret = Guid.NewGuid().ToString();
            var user = await _apiUserService.GetUserByUserName(registed.loginName);
            if (user != null)
            {
                //var token = await _userManager.GeneratePasswordResetTokenAsync(user);
                var createPass = await _apiUserService.ResetUserPassword(user.Id, loginSecret, false);
                if (createPass)
                {
                    await _userRepository.SetUserForgetVerificated(code, user_type);
                    login = new userLoginRefesh { loginName = registed.loginName, loginSecret = loginSecret, IsCreatePassword = true };
                }
            }
            return login;
        }
        
        
        public async Task<coreUserLoginResponse> SetResendCode(string reg_id)
        {
            return await _userRepository.SetResendCode(reg_id);
        }
        public async Task<ObjectResult> SetChangePassword(UserPassWordChange passwordSet)
        {
            var user = await _apiUserService.GetUserById(passwordSet.userId);
            if (user != null)
            {
                var result = await _apiUserService.ResetUserPassword(user.Id, passwordSet.NewPassWord, false);
                if (result)
                {
                    return new OkObjectResult(Constants.StatusSuccess);
                }
                else
                {
                    return new BadRequestObjectResult(result);
                }
            }
            return new BadRequestObjectResult(Constants.Statusfail);
        }
        #region supper app
        public async Task<UserProfileFull> GetProfileFull(string loginName)
        {
            return await _userRepository.GetProfileFull(loginName);
        }
        public async Task<List<viewField>> GetProfileFields(string userId, string loginName)
        {
            return await _userRepository.GetProfileFields(userId, loginName);
        }        
        public async Task SetProfileFields(string userId, viewField fields)
        {
            await _userRepository.SetProfileFields(userId, fields);
        }

        #region device
        public async Task<BaseValidate> SetSmartDevice(userSmartDevice device)
        {
            return await _userRepository.SetSmartDevice(device);
        }
        public async Task<BaseValidate> DeleteSmartDevice(string udid)
        {
            return await _userRepository.DeleteSmartDevice(udid);
        }
        public async Task<userSmartDevicePage> GetSmartDevices(FilterBase flt)
        {
            return await _userRepository.GetSmartDevices(flt);
        }
        public async Task<userOtpResponse> SetSmartDeviceConfirm(userSmartDeviceConfirm confirm)
        {
            return await _userRepository.SetSmartDeviceConfirm(confirm);
        }
        public async Task<userOtpResponse> GetSmartDeviceVerify(userSmartDeviceVerify verify)
        {
            return await _userRepository.GetSmartDeviceVerify(verify);
        }
        public async Task<BaseValidate> SetSmartDeviceVerificated(userSmartDeviceVerify verify, int status)
        {
            return await _userRepository.SetSmartDeviceVerificated(verify, status);
        }
        #endregion device
    }
    //public class FirebaseConfig
    //{
    //    public static FirestoreDb InitializeFirestore()
    //    {
    //        // Đường dẫn đến tệp JSON key
    //        string pathToCredentials = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "noble-app-production-ad161932d060.json");

    //        // Tải tệp credentials
    //        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", pathToCredentials);

    //        // Tạo kết nối tới Firestore
    //        FirestoreDb firestoreDb = FirestoreDb.Create("noble-app-production");
    //        Console.WriteLine("Connected to Firestore!");
    //        return firestoreDb;
    //    }
    //}
}
#endregion
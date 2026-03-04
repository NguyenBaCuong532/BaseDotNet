using Keycloak.Net.Models.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Account;
using UNI.Model.APPM;
using UNI.Model.Core;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// Interface IUserService
    /// <author>Tai NT</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public interface IAppUserService
    {
        Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg);
        Task<coreUserLoginResponse> GetUserRegisted(string reg_id);
        Task<userLoginRefesh> SetVerificated(coreVerify code, coreUserLoginResponse registed);
        Task<ObjectResult> SetLockUser(string userId, bool isLock);
        Task<ObjectResult> ResetPassword(SetUserPassword passwordSet);
        Task<User> FindUserByName(string userName);
        Task<ObjectResult> SetCreateAuthenUser(RegisterUserModel user);
        Task<userProfileSet> GetUserProfile(string loginUser);
        Task<BaseValidate> SetUserProfile(string userId, UserProfileSet ureg);
        Task<userForegetResponse> GetUserForgetPassword(string loginName, string udid);
        Task<coreUserLoginResponse> SetUserForgetPassword(userForegetSet forget);
        Task<userLoginRefesh> SetUserForgetVerificated(coreVerify code, coreUserLoginResponse registed, int user_type);
        Task<coreUserLoginResponse> SetResendCode(string reg_id);
        Task<ObjectResult> SetChangePassword(UserPassWordChange passwordSet);
        Task<UserProfileFull> GetProfileFull(string loginName);
        Task<List<viewField>> GetProfileFields(string userId, string loginName);
        Task SetProfileFields(string userId, viewField fields);

        #region device
        Task<BaseValidate> SetSmartDevice(userSmartDevice device);
        Task<BaseValidate> DeleteSmartDevice(string udid);
        Task<userSmartDevicePage> GetSmartDevices(FilterBase flt);
        Task<userOtpResponse> SetSmartDeviceConfirm(userSmartDeviceConfirm confirm);
        Task<userOtpResponse> GetSmartDeviceVerify(userSmartDeviceVerify verify);
        Task<BaseValidate> SetSmartDeviceVerificated(userSmartDeviceVerify verify, int status);

        #endregion device
    }
}

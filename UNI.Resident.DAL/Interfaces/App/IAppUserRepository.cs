using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.Core;

namespace UNI.Resident.DAL.Interfaces.App
{

    public interface IAppUserRepository
    {
        Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg);
        Task<coreUserLoginResponse> GetUserRegisted(string reg_id);
        Task<userLoginRefesh> SetVerificated(coreVerify code, string userId);
        Task LockUser(string userId, bool isLock);
        Task<BaseValidate> SetUserProfile(string userId, UserProfileSet ureg);
        Task<userProfileSet> GetUserProfile(string userLogin);
        Task<userForegetResponse> GetUserForgetPassword(string loginName, string udid);
        Task<coreUserLoginResponse> SetUserForgetPassword(userForegetSet forget);
        Task<coreUserLoginResponse> SetUserForgetVerificated(coreVerify code, int user_type);
        
        
        Task<coreUserLoginResponse> SetResendCode(string reg_id);
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
        #endregion
    }
}

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.UserConfig;
using UNI.Resident.Model;
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
    public interface IUserAppService1
    {
        Task<ObjectResult> SetLockUser(string userId, bool isLock);
        Task<ObjectResult> ResetPassword(SetUserPassword passwordSet);
        Task<IdentityUser> FindUserByName(string userName);
        Task<ObjectResult> SetCreateAuthenUser(RegisterUserModel user);
        Task<BaseResponse<userLoginRefesh>> SetUserRegister(userRegister reg, string preFix);
        Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg, int user_type);
        userProfileSet SetVerificated(string loginUser, int tokenType);
        userProfileSet GetUserProfile(string loginUser);
        Task<userLoginRefesh> SetUserLoginRefesh(userProfileSet profile);
        userProfileBase SetUserProfile(userProfileSet profile);
        List<ProjectApp> GetProjectList(string userId);
        Task SetUserForegetPassword(userBasePhone foreget, string preFix);
        Task SetUserAgreedTerm(userAgeedTerm term);
        userForegetResponse GetUserForgetPassword(string clientId, string loginName, string udid);
        Task<coreUserLoginResponse> SetUserForgetPassword(string clientId, userForegetSet forget);
        Task<userLoginRefesh> SetUserForgetVerificated(coreVerify code, coreUserLoginResponse registed, int user_type);
        coreUserLoginResponse GetUserRegisted(string reg_id);
        Task<userLoginRefesh> SetVerificated(coreVerify code, coreUserLoginResponse registed);
        Task<coreUserLoginResponse> SetResendCode(string reg_id);

        #region supper app api
        UserProfileFull GetProfileById(string userId, string loginName);
        List<viewField> GetProfileFields(string userId, string loginName);
        Task SetProfileFields(string userId, coreUserFields fields);
        Task SetProfileIdcardAdd(string userId, coreUserIdcardSet profile);
        List<coreUserProfileMeta> GetProfileMetas(string userId, string loginName);
        int SetProfileMeta(string userId, coreUserMetas meta);
        Task DelProfileMeta(string userId, Guid metaId);
        Task SetProfileLinkFacebook(string userId, fbUserProfile profile);
        ResponseList<List<corePointTrans>> GetPointTransactions(FilterBase filter);

        #endregion supper app api

        #region Invited
        Task<BaseValidate> SetUserInvitedBy(string userId, userInvite invite);
        userInviteGet GetUserInvited(string userId);

        #endregion Invited
    }
}

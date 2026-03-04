using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Core;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.UserConfig;

namespace UNI.Resident.DAL.Interfaces.App
{

    public interface IUserAppRepository1
    {
        Task LockUser(string userId, bool isLock);
        userProfileBase SetUserProfile(userProfileSet ureg);
        Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg, int user_type);
        userProfileBase SetLoginUserId(string loginName, string userId, string loginSecret);
        userProfileSet SetVerificated(string loginUser, int tokenType);
        userProfileSet GetUserProfile(string loginUser);
        List<ProjectApp> GetProjectList(string userId);
        Task SetUserForegetPassword(userBasePhone foreget, string preFix);
        Task SetUserAgreedTerm(userAgeedTerm term);
        userForegetResponse GetUserForgetPassword(string clientId, string loginName, string udid);
        Task<coreUserLoginResponse> SetUserForgetPassword(string clientId, userForegetSet forget);
        Task SetUserForgetVerificated(coreVerify code, int user_type);
        coreUserLoginResponse GetUserRegisted(string reg_id);
        Task<userLoginRefesh> SetVerificated(coreVerify code, string userId);
        Task<coreUserLoginResponse> SetResendCode(string reg_id);


        #region supper app
        UserProfileFull GetProfileById(string userId, string loginName);
        List<viewField> GetProfileFields(string userId, string loginName);
        List<coreUserProfileMeta> GetProfileMetas(string userId, string loginName);
        Task SetProfileFields(string userId, coreUserFields fields);
        int SetProfileMetas(string userId, coreUserMetas meta);
        Task DelProfileMeta(string userId, Guid metaId);
        Task SetProfileIdcardAdd(string userId, coreUserIdcardSet profile);
        Task SetProfileLinkFacebook(string userId, fbUserProfile profile);
        ResponseList<List<corePointTrans>> GetPointTransactions(FilterBase filter);
        #endregion supper app

        #region invited
        Task<BaseValidate> SetUserInvitedBy(string userId, userInvite invite);
        userInviteGet GetUserInvited(string userId);

        #endregion
    }
}

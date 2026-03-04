using System.Net.Http.Headers;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.Core;
using UNI.Model.Firestore;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// Interface IAppManagerService
    /// <author></author>
    /// <date>2015/12/02</date>
    /// </summary>
    public interface IAppManagerService
    {

        #region message-reg
        Task<int> TakeMessage(BaseCtrlClient clt, MessageBase mess);
        #endregion message-reg

        #region token-reg
        string GetUserToken(BaseCtrlClient clt, int tokenType, int mode = 0);
        userTokenMode GetUserByToken(string token, int tokenType);        

        Task<OtpMessageGet> TakeOTP(BaseCtrlClient clt, WalUserGrant registed);
        Task<ResponseCode> SetVerificationCode(string userId, userVerification code);
        //Task<ResponseCode> SetVerifyCode(string userId, coreVerify code, int tokenType);
        BaseValidate SetOtpStatus(string userId, userOtpStatus status);
        #endregion token-reg                 

        //string GetAppTerm(string preFix, int appId);
        Task<int> InsetSmartDeviceProfile(AuthenticationHeaderValue auth, string userName, SmartDeviceSet deviceprofile);

        #region thread-reg
        Task<fbThread> SetThreadAdd(string userId, fbThreadSet thread);       
        Task<BaseValidate> SetThreadUser(string userId, fbThreadUserAdd user);
        Task<BaseValidate> DelThreadUser(string userId, fbThreadUserAdd user);

        #endregion thread-reg

    }
}

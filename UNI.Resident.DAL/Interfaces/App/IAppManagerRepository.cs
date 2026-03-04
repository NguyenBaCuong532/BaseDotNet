using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.Firestore;

namespace UNI.Resident.DAL.Interfaces.App
{

    public interface IAppManagerRepository
    {

        #region message-reg
        Task<int> TakeMessage(BaseCtrlClient clt, MessageBase mess);
        #endregion message-reg

        #region token-reg
        string GetUserToken(BaseCtrlClient clt, int tokenType, int mode = 0);
        userTokenMode GetUserByToken(string token, int tokenType);
        OtpMessageGet TakeOTP1(BaseCtrlClient clt, WalUserGrant registed);
        Task<ResponseCode> SetVerificationCode1(string userId, userVerification code);
        BaseValidate SetOtpStatus(string userId, userOtpStatus status);
        #endregion token-reg

        //string GetAppVersion(string appId, string flatForm);
        //string GetAppTerm(string preFix, int appId);
        Task<int> InsetSmartDeviceProfile(SmartDeviceSet deviceprofile);

        #region thread-reg
        //ResponseList<List<fbThreadList>> GetThreadListByUser(FilterBase filter);
        Task<fbThread> SetThreadFetch(string userId, fbThreadSet thread);
        //Task<fbThread> SetThreadInfo(string userId, fbThread thread);
        //fbThread GetThread(string userId, Guid id);
        //Task<BaseValidate> SetThreadInvite(string userId, Guid? id, string role, List<fbThreadUser> user);
        //Task<BaseValidate> DelThreadInvite(Guid? thread_id, string userId);
        Task<BaseValidate> SetThreadUser(string userId, fbThreadUserAdd id, fbThreadUser user);
        Task<BaseValidate> DelThreadUser(string userId, fbThreadUserAdd user);
        fbThreadUser GetUserApp(string userId);
        #endregion thread-reg
    }
}

using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;

namespace UNI.Resident.DAL.Interfaces.Api
{

    public interface IApiNotifyRepository
    {

        #region notify-push-reg
        ////Task<BaseValidate> TakeNotification(AppNotifyTake1 take);
        Task<OtpMessageGet> TakeOTP(string userId, WalUserGrant registed);
        Task<ResponseCode> SetVerifyCode(string userId, userVerification code);
        #endregion notify-push-reg

        #region token-reg
        Task<string> GetUserToken(string userId, int tokenType, int mode = 0);
        Task<BaseValidate> SetOtpStatus(string userId, userOtpStatus status);
        #endregion token-reg
    }
}

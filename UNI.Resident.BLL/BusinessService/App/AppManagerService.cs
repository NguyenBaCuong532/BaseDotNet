using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.BLL.HelperService;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Notification;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Model.Core;
using UNI.Model.Email;
using UNI.Model.Firestore;
using UNI.Model.SMS.RequestAPI;
using UNI.Resident.DAL.Interfaces.App;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// Class IAppManagerService.
    /// <author></author>
    /// <date>2015/12/02</date>
    /// </summary>
    public class AppManagerService : IAppManagerService
    {
        private readonly IAppManagerRepository _appRepository;
        private readonly IEmailSender _emailSender;
        private readonly ISmsSender _smsSender;
        //private readonly IFirebaseRepository _fbRepository;
        //private readonly NotifySetting _notifySettings;
        private readonly ILogger<AppManagerService> _logger;
        public AppManagerService(
            IAppManagerRepository appRepository,
            IEmailSender emailSender,
            ISmsSender smsSender,
            ILogger<AppManagerService> logger,
            IOptions<AppSettings> appSettings
            )
        {
            if (appRepository != null)
                _appRepository = appRepository;
            _emailSender = emailSender;
            _smsSender = smsSender;
            //_custRepository = custRepository;
            //_fbRepository = fbRepository;
            //_userRepository = userRepository;
            //_notifySettings = appSettings.Value.Notify;
            _logger = logger;
        }

        #region message-reg
        public async Task<int> TakeMessage(BaseCtrlClient clt, MessageBase mess)
        {
            var gms = new GoogleCloudService();
            if (mess.partner == null)
                mess.partner = "iris";
            var response = _smsSender.SendSmsAs(mess);
            mess.isSent = true;
            return await _appRepository.TakeMessage(clt, mess);
            //return await gms.GCMessageAsync(mess.phone + "#" + mess.message);
        }
        

        #endregion message-reg

        #region token-reg
        public string GetUserToken(BaseCtrlClient clt, int tokenType, int mode = 0)
        {
            return _appRepository.GetUserToken(clt, tokenType, mode);
        }
        public userTokenMode GetUserByToken(string token, int tokenType)
        {
            return _appRepository.GetUserByToken(token, tokenType);
        }
        
        public async Task<OtpMessageGet> TakeOTP(BaseCtrlClient clt, WalUserGrant registed)
        {
            var result = _appRepository.TakeOTP1(clt, registed);
            if (registed.tokenType == 0 || registed.tokenType == 10000)
            {
                if (registed.Phone == "01234567890" || registed.Phone == "01234567891" ||
                    registed.Phone == "01234567892" || registed.Phone == "01234567893" ||
                    registed.Phone == "01234567894" || registed.Phone == "01234567895" ||
                    registed.Phone == "01234567896" || registed.Phone == "01234567897" ||
                    registed.Phone == "01234567898" || registed.Phone == "01234567899" 
                    )
                {
                    return result;
                }
                else if (result.optmessage != null)
                {
                    await _smsSender.SendSmsAs(result.optmessage);
                    result.optmessage.isSent = true;
                    await _appRepository.TakeMessage(clt, result.optmessage);
                    return result;
                }
            }
            else if (registed.tokenType == 1 && result.otpemail != null)
            {
                await _emailSender.SendMailgunEmail(result.otpemail);
                return result;
            }
            result.valid = false;
            return result;
        }
        public Task<ResponseCode> SetVerificationCode(string userId, userVerification code)
        {
            return _appRepository.SetVerificationCode1(userId, code);
        }
        //public Task<ResponseCode> SetVerifyCode(string userId, coreVerify code, int tokenType)
        //{
        //    var param = new userVerification
        //    {
        //        userId = code.reg_id,
        //        verificationCode = code.code,
        //        tokenType = tokenType
        //    };
        //    return _appRepository.SetVerificationCode1(userId, param);
        //}

        public BaseValidate SetOtpStatus(string userId, userOtpStatus status)
        {
            return _appRepository.SetOtpStatus(userId, status);
        }
        
        #endregion token-reg

        //public string GetAppTerm(string preFix, int appId)
        //{
        //    return _appRepository.GetAppTerm(preFix, appId);
        //}
        public Task<int> InsetSmartDeviceProfile(AuthenticationHeaderValue auth, string userName, SmartDeviceSet device)
        {
            var deviceSync = new HelperService.ChatService(auth);
            if (!string.IsNullOrEmpty(userName))
                deviceSync.SetDeviceAsSync(device.DeviceSync(userName, device.AppCd));
            else
                deviceSync.DeleteDeviceAsSync(device);
            return _appRepository.InsetSmartDeviceProfile(device);
        }


        public async Task<fbThread> SetThreadAdd(string userId, fbThreadSet thread)
        {
            var result = await _appRepository.SetThreadFetch(userId, thread);
            //if (result != null)
            {
                return result;
            }
            //else
            //{
            //    var thrGen = _custRepository.GetThreadGeneral(userId, thread);
            //    var data = await this.SetThreadInfo(userId, thrGen);
            //    await this.SetThreadInviteSupporter(userId, null, thrGen);
            //    await this.SetThreadInviteLeader(userId, null, thrGen);
            //    return data;
            //}
        }
        
        public Task<BaseValidate> SetThreadUser(string userId, fbThreadUserAdd id)
        {
            var user = _appRepository.GetUserApp(id.userId);
            return _appRepository.SetThreadUser(userId, id, user);
        }
        public Task<BaseValidate> DelThreadUser(string userId, fbThreadUserAdd user)
        {
            return _appRepository.DelThreadUser(userId, user);
        }
        //#endregion thread-reg
        //public Task<PushNotifyToUser1> PushNotifyToUser(BaseCtrlClient clt, PushNotifyToUser1 push, List<PushNotifyUser> listUser)
        //{
        //    return _appRepository.PushNotifyToUser(clt, push, listUser);
        //}
    }
}

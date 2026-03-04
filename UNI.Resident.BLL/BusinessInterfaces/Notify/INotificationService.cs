using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.BusinessInterfaces.Notify
{
    public interface INotificationService
    {
        #region notify
        CommonListPage GetAppNotifyPage(FilterInpNotify filter);
        Task<NotificationInfo> GetNotificationInfo(string userId, Guid? notiId, string external_key, string external_sub, string brand_name, string send_name, string external_event = null);
        Task<NotificationInfo> SetAppNotifyDraft(string userId, NotificationInfo noti);
        Task<BaseValidate> SetAppNotifyInfo(BaseCtrlClient clt, NotificationInfo noti);
        Task<BaseValidate> DelAppNotifyInfo(string userId, Guid notiId);
        #endregion
        #region notify_push
        CommonListPage GetAppNotiToPushPage(FilterInpNotifyPush filter);
        Task<BaseValidate> DelNotiPush(string userId, string id);
        Task<BaseValidate> DelNotiPushs(string userId, PushNotifyDel ids);
        Task<BaseValidate> SetNotifyCreatePush(string userId, PushNotifyCreate noti);
        Task SetNotifyToPushRun(string userId, PushNotifyRun noti);
        Task<BaseValidate<Stream>> GetRoomNotifySendTemp(string userId, string projectCd, string buildingCd);
        Task<ImportRoomNotifyPushListPage> ImportRoomNotifySendAsync(string userId, string projectCd, string buildingCd, RoomNotifyPushImport rooms);
        CommonListPage GetNotifySentPageByRoom(FilterInpNotifySend filter);
        #endregion
        #region message-reg
        Task<MessageRespone> TakeMessage(BaseCtrlClient clt, MessageSend mess);
        CommonListPage GetMessagePage(FilterInpNotifySend filter);
        #endregion
        #region email-reg
        Task<BaseValidate> TakeMailSend(BaseCtrlClient clt, EmailModel email);
        CommonListPage GetEmailPage(FilterInpNotifySend filter);
        
        #endregion

    }
}

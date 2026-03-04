using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.DAL.Interfaces.Notify
{
    public interface INotificationRepository
    {
        // Ds thông báo
        #region notify
        CommonListPage GetAppNotifyPage(FilterInpNotify filter);
        Task<NotificationInfo> GetNotificationInfo(string userId, Guid? notiId, string external_key, string external_sub, string brand_name, string send_name, string external_event = null);
        Task<NotificationInfo> SetAppNotifyDraft(string userId, NotificationInfo noti);
        Task<BaseValidate> SetAppNotifyInfo(BaseCtrlClient clt, NotificationInfo noti);
        Task<BaseValidate> DelAppNotifyInfo(string userId, Guid notiId);
        #endregion
        // Ds gửi thông báo
        #region notify_push
        CommonListPage GetAppNotifyPushPageByNotiId(FilterInpNotifyPush filter);
        Task<BaseValidate> DelNotiPush(string userId, string id);
        Task<BaseValidate> SetNotifyCreatePush(string userId, PushNotifyCreate noti);
        Task<AppNotifyTake1> SetNotifyToPushRun(string userId, PushNotifyRun noti);
        Task<BaseValidate> TakeNotification(BaseCtrlClient clt, AppNotifyTake1 take);
        Task<BaseValidate> TakeNotification2(BaseCtrlClient clt, AppNotifyTake take);
        Task<DataSet> GetRoomNotifySendTemp(string userId, string projectCd, string buildingCd); // mẫu template import ds căn hộ gửi thông báo
        Task<ImportRoomNotifyPushListPage> ImportRoomNotifySendAsync(string userId, string projectCd, string buildingCd, RoomNotifyPushImport rooms);// import ds căn hộ gửi thông báo
        #endregion
        #region message-reg
        Task<int> TakeMessage(BaseCtrlClient clt, MessageSend mess);
        CommonListPage GetMessageSents(FilterInpNotifySend filter);
        #endregion
        #region email-reg
        CommonListPage GetEmailSents(FilterInpNotifySend filter);
        Task<int> TakeSendMail(BaseCtrlClient clt, EmailBase email);
        CommonListPage GetNotifySentPageByRoom(FilterInpNotifySend flt);
        #endregion
    }
}

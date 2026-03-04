using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using System.Data;

namespace UNI.Resident.DAL.Interfaces.Notify
{

    public interface INotifyRepository
    {
        #region notify-man-reg
        //CommonViewInfo GetNotifyFilter(string userId);
        Task<List<CommonValue>> GetNotiPushStatus(string userId);
        Task<CommonDataPage> GetAppNotifyPage(FilterInpNotify flt, string externalKey);
        Task<resNotifyInfo> GetNotifyInfo(NotifyParam param, string externalKey);
        Task<resNotifyInfo> SetNotifyDraft(resNotifyInfoSet noti);
        Task<NotifyTo> SetNotifyToDraft(NotifyTo notiTo); // Changed return type to Task<NotifyTo>
        Task<BaseValidate> SetNotifyInfo(resNotifyInfoSet noti);
        Task<BaseValidate> DelNotifyInfo(Guid n_id);
        Task<NotifyTo> GetNotifyToAsync(Guid? n_id, Guid? id, int? to_level, string to_groups, int? to_type);
        Task<BaseValidate> SetNotifyTo(NotifyTo notiTo);
        Task<BaseValidate> DelNotifyTo(Guid id);
        Task<CommonDataPage> GetNotifySentPageByUser(FilterInpNotifyUser filter);
        Task<BaseValidate> SetAppNotifyStatus(AppNotifyId noti);
        #endregion notify-man-reg

        #region notify-to-reg
        Task<NotifyToListGet> GetNotifyToList(Guid? n_id, int? to_level, string to_groups, int to_type);
        Task<BaseValidate> SetNotifyToList(NotifyToList notiTo);
        Task<CommonDataPage> SetNotifyToDraftPage(NotifyTo notiTo);
        #endregion notify-to-reg

        #region notify-push-reg
        Task<CommonViewInfo> GetNotifyToPushsFilter(Guid? n_id);
        Task<BaseValidate> SetNotifyCreatePush(PushNotifyCreate noti);
        Task<CommonDataPage> GetNotifyPushPageByNotiId(FilterInpNotifyPush filter);
        Task<AppNotifyTake1> SetNotifyToPushRun(PushNotifyRun noti);
        Task<BaseValidate> DelNotiPush(string id);
        Task<BaseValidate> TakeNotification(AppNotifyTake take);
        Task<List<PushNotifyUser>> GetFamilyPush(PushNotifyHomSet noti);
        Task SetDocumentUrl(HomDocumentUrlSet doc);
        Task<CommonDataPage> GetDocumentUrl(FilterInputProject filter);

        Task<BaseResponse<string>> SendToKafka(PushNotifyRun noti);
        #endregion notify-push-reg

        #region scheduled-notify-reg
        Task<List<PushNotifyRun>> GetScheduledNotifications(int maxRecords = 100);
        #endregion scheduled-notify-reg

        #region notify-comment-reg
        Task<AppNotifyComment> SetNotiCommentAsync(AppNotifyCommentSet comm);
        Task<CommonDataPage> GetNotiComments(FilterInpNotifyId filter);
        Task<CommonDataPage> GetNotiCommentById(FilterBase filter);
        Task<int> SetNotiCommentAuth(AppNotifyCommentAuth comm);
        #endregion notify-commet-reg

        #region notify-app-reg
        Task<SentNotifyPage> GetNotifyByUser(FilterInputProject flt);
        Task<SentNotifyGet> GetSentNotifyDetailAsync(Guid n_id);
        Task<int> SetNotificationReadAll(string external_key);
        #endregion notify-app-reg

        #region notify-ref
        Task<CommonDataPage> GetNotifyRefPage(FilterInput flt, string externalKey);
        Task<AppNotifyRef> GetNotifyRefAsync(Guid? source_ref, string externalKey);
        Task<BaseValidate> SetNotifyRef(AppNotifyRef noti);
        Task<BaseValidate> DelNotifyRef(Guid source_ref);
        //List<AppNotifyRefList> GetNotifyRefList(string userId);
        Task<List<CommonValue>> GetNotifyTypeList(string externalKey); // Changed to Task<List<CommonValue>>
        #endregion notify-ref

        #region notify-temp
        Task<CommonViewInfo> GetNotifyTempFilter(string userId);
        Task<CommonDataPage> GetNotifyTempPage(FilterInpNotifyTemp flt, string externalKey, string projectcode);
        Task<NotifyTemp> GetNotifyTempAsync(Guid? tempId, Guid? n_id, string source_key);
        Task<NotifyTemp> SetNotifyTempDraft(NotifyTemp noti);
        Task<BaseValidate> SetNotifyTemp(NotifyTemp noti);
        Task<BaseValidate> DelNotifyTemp(Guid tempId);
        Task<List<CommonValue>> GetNotifyTempList(string source_key, int? can_st, string projectcode);
        #endregion notify-tmp

        #region message-reg
        Task<CommonDataPage> GetNotifyMessagePage(FilterInpNotifySend filter, string externalKey);
        
        Task<int> TakeMessage(MessageSend mess);
        #endregion message-reg

        #region email-reg
        Task<CommonDataPage> GetNotifyEmailPage(FilterInpNotifySend filter, string externalKey);
        
        Task<int> TakeSendMail(EmailBase email);
        Task<List<CommonValue>> GetNotifyFields(string userId);
        Task<List<CommonValue>> GetNotifyTemplateFields(Guid tempId);
        Task<CommonViewInfo> GetNotifyFilterAsync(string filter_key);
        Task<CommonDataPage> GetNotifyToPage(FilterInpNotifyId flt);

        #endregion email-reg

        #region notify-sent-import-reg
        Task<DataSet> GetNotifySentImportTemp();
        Task<ImportListPage> SetNotifySentImport(NotifySentImportSet importSet, Guid n_id);
        #endregion notify-sent-import-reg

    }
}
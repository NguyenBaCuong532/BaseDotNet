using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using System.IO;

namespace UNI.Resident.BLL.BusinessInterfaces.Notify
{
    /// <summary>
    /// Interface IAppManagerService
    /// <author></author>
    /// <date>2015/12/02</date>
    /// </summary>
    public interface INotifyService
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
        Task<CommonDataPage> GetNotifyToPage(FilterInpNotifyId flt);
        Task<NotifyTo> GetNotifyTo(Guid? n_id, Guid? id, int? to_level, string to_groups, int? to_type); // Changed return type to Task<NotifyTo>
        Task<BaseValidate> SetNotifyTo(NotifyTo notiTo);
        Task<BaseValidate> DelNotifyTo(Guid id);
        Task<CommonDataPage> GetNotifySentPageByUser(FilterInpNotifyUser filter);
        Task<BaseValidate> SetAppNotifyStatus(AppNotifyId noti);
        #endregion notify-man-reg

        #region notify-to-reg
        Task<NotifyToListGet> GetNotifyToList(Guid? n_id, int? to_level, string to_groups, int to_type);
        Task<BaseValidate> SetNotifyToList(NotifyToList notiTo);
        Task<CommonDataPage> SetNotifyToDraftPage(NotifyTo notiTo);
        #endregion to-reg

        #region notify-push-reg
        Task<CommonViewInfo> GetNotifyToPushsFilter(Guid? n_id);
        Task<BaseValidate> SetNotifyCreatePush(PushNotifyCreate noti);
        Task<CommonDataPage> GetNotiToPushPage(FilterInpNotifyPush filter);
        Task SetNotifyToPushRun(PushNotifyRun noti);
        Task<BaseValidate> DelNotiPush(string id);
        Task<BaseValidate> DelNotiPushs(PushNotifyDel ids);
        //Task<BaseValidate> TakeNotification(hrmNotifyTake take);
        Task<List<PushNotifyUser>> GetFamilyPush(PushNotifyHomSet noti);
        Task SetDocumentUrl(HomDocumentUrlSet doc);
        Task<CommonDataPage> GetDocumentUrl(FilterInputProject filter);
        #endregion notify-push-reg

        #region notify-ref
        Task<CommonDataPage> GetNotifyRefPage(FilterInput flt, string externalKey); // Changed return type to Task<CommonDataPage>
        Task<AppNotifyRef> GetNotifyRef(Guid? source_ref, string externalKey); // Changed return type to Task<AppNotifyRef>
        Task<BaseValidate> SetNotifyRef(AppNotifyRef noti);
        Task<BaseValidate> DelNotifyRef(Guid source_ref);
        //List<AppNotifyRefList> GetNotifyRefList(string userId);
        Task<List<CommonValue>> GetNotifyRefList(string externalKey); // Changed return type to Task<List<CommonValue>>
        #endregion notify-ref

        #region notify-temp
        Task<CommonViewInfo> GetNotifyTempFilter(string userId); // Changed return type to Task<CommonViewInfo>
        Task<CommonDataPage> GetNotifyTempPage(FilterInpNotifyTemp flt, string externalKey, string projectcode); // Changed return type to Task<CommonDataPage>
        Task<NotifyTemp> GetNotifyTemp(Guid? tempId, Guid? n_id, string externalKey); // Changed return type to Task<NotifyTemp>
        Task<NotifyTemp> SetNotifyTempDraft(NotifyTemp noti);
        Task<BaseValidate> SetNotifyTemp(NotifyTemp noti);
        Task<BaseValidate> DelNotifyTemp(Guid tempId);
        Task<List<CommonValue>> GetNotifyTempList(string externalKey, int? can_st, string projectcode); // Changed return type to Task<List<CommonValue>>
        Task<List<CommonValue>> GetNotifyFields(string userId); // Changed return type to Task<List<CommonValue>>
        Task<List<CommonValue>> GetNotifyTemplateFields(Guid tempId); // Get fields of a specific template


        Task<CommonDataPage> GetNotifyMessagePage(FilterInpNotifySend flt, string externalKey); // Changed return type to Task<CommonDataPage>
        Task<CommonDataPage> GetNotifyEmailPage(FilterInpNotifySend flt, string externalKey); // Changed return type to Task<CommonDataPage>
        Task<CommonViewInfo> GetNotifyFilter(string tableKey); // Changed return type to Task<CommonViewInfo>
        #endregion notify-tmp

        #region notify-comment-reg
        Task<AppNotifyComment> SetNotiComment(AppNotifyCommentSet comm); // Changed return type to Task<AppNotifyComment>
        Task<CommonDataPage> GetNotiComments(FilterInpNotifyId filter);
        Task<CommonDataPage> GetNotiCommentById(FilterBase filter);
        Task<int> SetNotiCommentAuth(AppNotifyCommentAuth comm);

        Task<SentNotifyPage> GetNotifyByUser(FilterInputProject flt); // Changed return type to Task<SentNotifyPage>
        Task<SentNotifyGet> GetSentNotifyDetail(Guid n_id); // Changed return type to Task<SentNotifyGet>
        #endregion notification-reg

        #region scheduled-notify-reg
        Task<BaseResponse<int>> ProcessScheduledNotifications(int maxRecords = 100);
        
        #endregion scheduled-notify-reg

        #region notify-sent-import-reg
        Task<BaseValidate<Stream>> GetNotifySentImportTemp();
        Task<ImportListPage> SetNotifySentImport(NotifySentImportSet importSet, Guid n_id);
        #endregion notify-sent-import-reg

    }
}
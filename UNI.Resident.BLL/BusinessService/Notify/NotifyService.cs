using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM.Notifications;
using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Notify
{
    /// <summary>
    /// Class NotifyService.
    /// <author></author>
    /// <date>2022/12/02</date>
    /// </summary>
    public class NotifyService : INotifyService
    {
        private readonly INotifyRepository _appRepository;
        private readonly NotifySetting _notifySettings;
        private readonly ILogger<NotifyService> _logger;
        public NotifyService(
            INotifyRepository appRepository,
            IFirebaseRepository fbRepository,
            ILogger<NotifyService> logger,
            IOptions<AppSettings> appSettings
            )
        {
            if (appRepository != null)
                _appRepository = appRepository;

            _notifySettings = appSettings.Value.Notify;
            _logger = logger;
        }

        #region notify-man-reg
               
        public Task<List<CommonValue>> GetNotiPushStatus(string userId) // Fixed method signature
        {
            return _appRepository.GetNotiPushStatus(userId);
        }
        public Task<CommonDataPage> GetAppNotifyPage(FilterInpNotify flt, string externalKey) // Changed return type to Task<CommonDataPage>
        {
            return _appRepository.GetAppNotifyPage(flt, externalKey);
        }

        public Task<resNotifyInfo> GetNotifyInfo(NotifyParam param, string externalKey) // Changed return type to Task<Model.Notification.NotifyInfo>
        {
            return _appRepository.GetNotifyInfo(param, externalKey);
        }
        public Task<resNotifyInfo> SetNotifyDraft(resNotifyInfoSet noti)
        {   //1
            //var check = noti.GetValueByFieldName("isHighLight");
            //if (check == "1")
            //{
            //    noti.SetValueByFieldName("isHighLight", "true");
            //}
            //else noti.SetValueByFieldName("isHighLight", "false");
            //////2
            //var check2 = noti.GetValueByFieldName("isPublish");
            //if (check == "1")
            //{
            //    noti.SetValueByFieldName("isPublish", "true");
            //}
            //else noti.SetValueByFieldName("isPublish", "false");
            return _appRepository.SetNotifyDraft(noti);
        }
        public Task<NotifyTo> SetNotifyToDraft(NotifyTo notiTo)
        {
            return _appRepository.SetNotifyToDraft(notiTo);
        }
        public Task<BaseValidate> SetNotifyInfo(resNotifyInfoSet noti)
        {
            return _appRepository.SetNotifyInfo(noti);
        }
        public Task<BaseValidate> DelNotifyInfo(Guid n_id)
        {
            return _appRepository.DelNotifyInfo(n_id);
        }
        public Task<CommonDataPage> GetNotifyToPage(FilterInpNotifyId flt)
        {
            return _appRepository.GetNotifyToPage(flt);
        }
        public Task<NotifyTo> GetNotifyTo(Guid? n_id, Guid? id, int? to_level, string to_groups, int? to_type)
        {
            return _appRepository.GetNotifyToAsync(n_id, id, to_level, to_groups, to_type);
        }
        public Task<BaseValidate> SetNotifyTo(NotifyTo notiTo)
        {
            return _appRepository.SetNotifyTo(notiTo);
        }
        public Task<BaseValidate> DelNotifyTo(Guid id)
        {
            return _appRepository.DelNotifyTo(id);
        }
        public Task<CommonDataPage> GetNotifySentPageByUser(FilterInpNotifyUser filter)
        {
            return _appRepository.GetNotifySentPageByUser(filter);
        }
        public Task<BaseValidate> SetAppNotifyStatus(AppNotifyId noti)
        {
            return _appRepository.SetAppNotifyStatus(noti);
        }

        #endregion notify-man-reg
        #region notify-to-reg
        public async Task<NotifyToListGet> GetNotifyToList(Guid? n_id, int? to_level, string to_groups, int to_type)
        {
            return await _appRepository.GetNotifyToList(n_id, to_level, to_groups, to_type);
        }
        public async Task<BaseValidate> SetNotifyToList(NotifyToList notiTo)
        {
            return await _appRepository.SetNotifyToList(notiTo);
        }
        public Task<CommonDataPage> SetNotifyToDraftPage(NotifyTo notiTo)
        {
            return _appRepository.SetNotifyToDraftPage(notiTo);
        }
        #endregion notify-to-reg
        #region notify-push-reg
        public Task<CommonViewInfo> GetNotifyToPushsFilter(Guid? n_id)
        {
            return _appRepository.GetNotifyToPushsFilter(n_id);
        }
        public Task<BaseValidate> SetNotifyCreatePush(PushNotifyCreate noti)
        {
            return _appRepository.SetNotifyCreatePush(noti);
        }
        public Task<CommonDataPage> GetNotiToPushPage(FilterInpNotifyPush filter)
        {
            return _appRepository.GetNotifyPushPageByNotiId(filter);
        }
        public Task SetNotifyToPushRun(PushNotifyRun noti)
        {
            return _appRepository.SetNotifyToPushRun(noti);
        }
        public Task<BaseValidate> DelNotiPush(string id)
        {
            return _appRepository.DelNotiPush(id);
        }
        public async Task<BaseValidate> DelNotiPushs(PushNotifyDel ids)
        {
            var valid = new BaseValidate { valid = true };
            foreach (var id in ids.ids)
            {
                var result = await _appRepository.DelNotiPush(id);
                if (result.valid == false)
                {
                    valid.valid = false;
                    valid.messages = "Có một số dữ liệu đã được gửi đến khác hàng không thể xóa!";
                }
            }
            return valid;
        }

        public Task<List<PushNotifyUser>> GetFamilyPush(PushNotifyHomSet noti)
        {
            return _appRepository.GetFamilyPush(noti);
        }
        public Task SetDocumentUrl(HomDocumentUrlSet doc)
        {
            return _appRepository.SetDocumentUrl(doc);
        }
        public Task<CommonDataPage> GetDocumentUrl(FilterInputProject filter)
        {
            return _appRepository.GetDocumentUrl(filter);
        }

        #endregion notify-push-reg

        #region notify-comment-reg

        public Task<AppNotifyComment> SetNotiComment(AppNotifyCommentSet comm)
        {
            return _appRepository.SetNotiCommentAsync(comm);
        }
        public Task<CommonDataPage> GetNotiComments(FilterInpNotifyId filter)
        {
            return _appRepository.GetNotiComments(filter);
        }
        public Task<CommonDataPage> GetNotiCommentById(FilterBase filter)
        {
            return _appRepository.GetNotiCommentById(filter);
        }
        public Task<int> SetNotiCommentAuth(AppNotifyCommentAuth comm)
        {
            return _appRepository.SetNotiCommentAuth(comm);
        }
        #endregion notify-comment-reg

        #region notify-take-reg



        #endregion notify-take-reg

        #region notify-ref
        public Task<CommonDataPage> GetNotifyRefPage(FilterInput flt, string externalKey)
        {
            return _appRepository.GetNotifyRefPage(flt, externalKey);
        }
        public Task<AppNotifyRef> GetNotifyRef(Guid? source_ref, string externalKey) // Changed return type to Task<AppNotifyRef>
        {
            return _appRepository.GetNotifyRefAsync(source_ref, externalKey);
        }
        public Task<BaseValidate> SetNotifyRef(AppNotifyRef noti)
        {
            return _appRepository.SetNotifyRef(noti);
        }
        public Task<BaseValidate> DelNotifyRef(Guid source_ref)
        {
            return _appRepository.DelNotifyRef(source_ref);
        }
        //public List<AppNotifyRefList> GetNotifyRefList(string userId)
        //{
        //    return _appRepository.GetNotifyRefList(userId);
        //}        
        public Task<List<CommonValue>> GetNotifyRefList(string externalKey)
        {
            return _appRepository.GetNotifyTypeList(externalKey);
        }
        #endregion notify-ref

        #region notify-temp
        public Task<CommonViewInfo> GetNotifyTempFilter(string userId) // Changed return type to Task<CommonViewInfo>
        {
            return _appRepository.GetNotifyTempFilter(userId);
        }
        public Task<CommonDataPage> GetNotifyTempPage(FilterInpNotifyTemp flt, string externalKey, string projectcode) // Changed return type to Task<CommonDataPage>
        {
            return _appRepository.GetNotifyTempPage(flt, externalKey, projectcode);
        }
        public Task<NotifyTemp> GetNotifyTemp(Guid? tempId, Guid? n_id, string source_key) // Changed return type to Task<NotifyTemp>
        {
            return _appRepository.GetNotifyTempAsync(tempId, n_id, source_key);
        }
        public Task<NotifyTemp> SetNotifyTempDraft(NotifyTemp noti)
        {
            return _appRepository.SetNotifyTempDraft(noti);
        }
        public Task<BaseValidate> SetNotifyTemp(NotifyTemp noti)
        {
            return _appRepository.SetNotifyTemp(noti);
        }
        public Task<BaseValidate> DelNotifyTemp(Guid tempId)
        {
            return _appRepository.DelNotifyTemp(tempId);
        }
        public Task<List<CommonValue>> GetNotifyTempList(string source_key, int? can_st, string projectcode) // Changed return type to Task<List<CommonValue>>
        {
            return _appRepository.GetNotifyTempList(source_key, can_st, projectcode);
        }
        public Task<List<CommonValue>> GetNotifyFields(string userId) // Changed return type to Task<List<CommonValue>>
        {
            return _appRepository.GetNotifyFields(userId);
        }
        public Task<List<CommonValue>> GetNotifyTemplateFields(Guid tempId)
        {
            return _appRepository.GetNotifyTemplateFields(tempId);
        }
        public Task<CommonDataPage> GetNotifyMessagePage(FilterInpNotifySend flt, string externalKey)
        {
            return _appRepository.GetNotifyMessagePage(flt, externalKey);
        }
        public Task<CommonDataPage> GetNotifyEmailPage(FilterInpNotifySend flt, string externalKey) // Changed return type to Task<CommonDataPage>
        {
            return _appRepository.GetNotifyEmailPage(flt, externalKey);
        }
        public Task<CommonViewInfo> GetNotifyFilter(string tableKey) // Changed return type to Task<CommonViewInfo>
        {
            return _appRepository.GetNotifyFilterAsync(tableKey);
        }
        #endregion notify-temp

        public Task<SentNotifyPage> GetNotifyByUser(FilterInputProject flt)
        {
            return _appRepository.GetNotifyByUser(flt);
        }
        public Task<SentNotifyGet> GetSentNotifyDetail(Guid n_id) // Changed return type to Task<SentNotifyGet>
        {
            return _appRepository.GetSentNotifyDetailAsync(n_id);
        }

        #region scheduled-notify-reg
        public async Task<BaseResponse<int>> ProcessScheduledNotifications(int maxRecords = 100)
        {
            try
            {
                _logger.LogInformation("Bắt đầu xử lý thông báo đã đến lịch gửi. MaxRecords: {MaxRecords}", maxRecords);
                
                // Lấy danh sách thông báo đã đến lịch gửi
                var scheduledNotifications = await _appRepository.GetScheduledNotifications(maxRecords);
                
                if (scheduledNotifications == null || !scheduledNotifications.Any())
                {
                    _logger.LogInformation("Không có thông báo nào cần gửi.");
                    return new BaseResponse<int>(ApiResult.Success, data: 0);
                }
                
                int processedCount = 0;
                
                foreach (var scheduledInfo in scheduledNotifications)
                {
                    try
                    {
                        //var notifyInbox = scheduledInfo.NotifyInbox;
                        //var notifySentList = scheduledInfo.NotifySentList;
                        
                        //if (notifyInbox == null || notifySentList == null || !notifySentList.Any())
                        //{
                        //    _logger.LogWarning("Thông báo {NId} không có danh sách người nhận.", notifyInbox?.n_id);
                        //    continue;
                        //}
                        
                        //// Tạo PushNotifyRun để gửi qua Kafka
                        //var pushNotifyRun = new PushNotifyRun
                        //{
                        //    n_id = notifyInbox.n_id,
                        //    ids = notifySentList.Select(ns => ns.id.ToString()).ToList(),
                        //    action = notifyInbox.actionlist ?? "push,sms,email",
                        //    run_act = 2 // 2 = đang gửi
                        //};
                        
                        // Gửi qua Kafka
                        var kafkaResult = await _appRepository.SendToKafka(scheduledInfo);
                        
                        if (kafkaResult.Result == ApiResult.Success)
                        {
                            processedCount++;
                            _logger.LogInformation("Đã gửi thông báo {NId} qua Kafka thành công. Số lượng người nhận: {Count}",
                                scheduledInfo.n_id, scheduledInfo.ids.Count);
                        }
                        else
                        {
                            _logger.LogError("Lỗi khi gửi thông báo {NId} qua Kafka: {Error}",
                                scheduledInfo.n_id, kafkaResult.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Lỗi khi xử lý thông báo {NId}", scheduledInfo?.n_id);
                    }
                }
                
                _logger.LogInformation("Hoàn thành xử lý thông báo đã đến lịch gửi. Đã xử lý: {ProcessedCount}/{TotalCount}", 
                    processedCount, scheduledNotifications.Count);
                
                return new BaseResponse<int>(ApiResult.Success, data: processedCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xử lý thông báo đã đến lịch gửi");
                return new BaseResponse<int>(ApiResult.Error, error: ex.Message);
            }
        }
        #endregion scheduled-notify-reg

        #region notify-sent-import-reg
        /// <summary>
        /// GetNotifySentImportTemp - Get template Excel for import danh sách gửi thông báo
        /// QUAN TRỌNG: Sử dụng template chuẩn export_danh_muc_chung.xlsx
        /// </summary>
        public async Task<BaseValidate<Stream>> GetNotifySentImportTemp()
        {
            var ds = await _appRepository.GetNotifySentImportTemp();
            var r = new FlexcellUtils();
            var templatePath = $"templates/export_danh_muc_chung.xlsx";
            var template = await File.ReadAllBytesAsync(templatePath);
            Dictionary<string, object> p = new Dictionary<string, object>();
            var report = r.CreateReport(template, ReportType.xlsx, ds, p);
            return new BaseValidate<Stream>(report);
        }

        /// <summary>
        /// SetNotifySentImport - Validate hoặc Save dữ liệu import danh sách gửi thông báo
        /// </summary>
        public async Task<ImportListPage> SetNotifySentImport(NotifySentImportSet importSet, Guid n_id)
        {
            if (n_id == Guid.Empty)
            {
                throw new ArgumentException("n_id không được để trống", nameof(n_id));
            }

            importSet.n_id = n_id;
            return await _appRepository.SetNotifySentImport(importSet, n_id);
        }
        #endregion notify-sent-import-reg

    }
}

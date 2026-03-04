using DapperParameters;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using UNI.Resident.Const;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;

namespace UNI.Resident.DAL.Repositories.Notify
{
    public class NotificationRepository : UniBaseRepository, INotificationRepository
    {
        protected ILogger<NotificationRepository> _logger;
        private readonly IFirebaseRepository _fbRepository;

        public NotificationRepository(IUniCommonBaseRepository common,
            ILogger<NotificationRepository> logger,
            IFirebaseRepository notifyRepository,
            IHostingEnvironment environment) : base(common)
        {
            _logger = logger;
            _fbRepository = notifyRepository;
        }
        #region Notify
        public CommonListPage GetAppNotifyPage(FilterInpNotify filter)
        {
            const string storedProcedure = "sp_res_notify_info_page";
            return GetPage(storedProcedure, filter, new { source_key = filter.source_key, external_sub = filter.external_sub });
        }
        public async Task<NotificationInfo> GetNotificationInfo(string userId, Guid? n_id, string external_key, string external_sub, string brand_name, string send_name, string external_event = null)
        {
            const string storedProcedure = "sp_res_notify_info_fields";
            return await GetFieldsAsync<NotificationInfo>(storedProcedure, new { n_id, external_key, external_sub, source_key = "common", brand_name, external_event, send_name });
        }
        public async Task<NotificationInfo> SetAppNotifyDraft(string userId, NotificationInfo noti)
        {
            const string storedProcedure = "sp_res_notify_info_draft";
            return await SetInfoAsync<NotificationInfo>(storedProcedure, noti, new { noti.n_id });
        }
        public async Task<BaseValidate> SetAppNotifyInfo(BaseCtrlClient clt, NotificationInfo noti)
        {
            const string storedProcedure = "sp_res_notify_info_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, noti, new { noti.n_id });
        }
        public async Task<BaseValidate> DelAppNotifyInfo(string userId, Guid n_id)
        {
            const string storedProcedure = "sp_res_notify_info_del";
            return await DeleteAsync(storedProcedure, new { n_id });
        }
        #endregion
        #region Notify push
        public CommonListPage GetAppNotifyPushPageByNotiId(FilterInpNotifyPush filter)
        {
            const string storedProcedure = "sp_res_notify_push_page_byNotiId";
            return GetPage(storedProcedure, filter, 
                new { n_id = filter.n_id,push_st = filter.push_st,email_st= filter.email_st,sms_st= filter.sms_st });
        }

        public async Task<BaseValidate> DelNotiPush(string userId, string id)
        {
            const string storedProcedure = "sp_res_notify_push_del";
            return await DeleteAsync(storedProcedure, new { id });
        }
        public async Task<BaseValidate> SetNotifyCreatePush(string userId, PushNotifyCreate noti)
        {
            const string storedProcedure = "sp_res_notify_push_creates";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, 
            param =>
            {
                param.Add("@n_id", noti.n_id);
                param.AddTable("@notiusers", "user_notify_type", noti.appUsers);
                return param;
            });
        }
        public async Task<AppNotifyTake1> SetNotifyToPushRun(string userId, PushNotifyRun noti)
        {
            const string storedProcedure = "sp_res_notify_push_run";
            return await GetMultipleAsync<AppNotifyTake1>(storedProcedure, param =>
            {
                    param.Add("@n_id", noti.n_id);
                    param.Add("@ids", string.Join(",", noti.ids));
                    param.Add("@action", noti.action);
                    param.Add("@run_act", noti.run_act);
                return param;
            }, 
            async result =>
            {
                var data = result.ReadFirstOrDefault<AppNotifyTake1>();
                if (data != null)
                    {
                        data.appUsers = result.Read<PushNotifyUser>().ToList();
                        if ((noti.action.Contains("push") || noti.action.Contains("1")) && data.appUsers != null && data.appUsers.Count > 0)
                        {
                            await _fbRepository.SetNotifyPush(data);// gửi thông báo thông qua firebase
                            await SetNotifySent(data);// thay đổi push_st = 2(đã gửi) và push_count + 1
                        }
                    }
                    return data;
            });
        }
        public async Task SetNotifySent(AppNotifyTake1 sent)
        {
            const string storedProcedure = "sp_res_notify_push_send";
            await GetFirstOrDefaultAsync<int>(storedProcedure, 
            param =>
            {
                param.Add("@n_id", sent.n_id);
                param.AddTable("@notiusers", "user_notify_type", sent.appUsers);
                return param;
            });
        }
        public CommonListPage GetMessageSents(FilterInpNotifySend filter)
        {
            const string storedProcedure = "sp_res_message_Page";
            return GetPage(storedProcedure, filter, new { custId = filter.filter });
        }
        public async Task<int> TakeMessage(BaseCtrlClient clt, MessageSend mess)
        {
            const string storedProcedure = "sp_resident_message_set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure,  
                new { mess.messageId, mess.phone, mess.custName, mess.message, mess.scheduleAt, 
                mess.brandName, mess.isSent, mess.custId, mess.sourceId, mess.partner, mess.remart 
                });
        }
        public CommonListPage GetEmailSents(FilterInpNotifySend filter)
        {
            const string storedProcedure = "sp_res_email_page";
            return GetPage(storedProcedure, filter, new { CustId = filter.filter });
        }
        public async Task<int> TakeSendMail(BaseCtrlClient clt, EmailBase email)
        {
            const string storedProcedure = "sp_resident_email_set";
            return await base.GetFirstOrDefaultAsync<int>(storedProcedure, new { email.To, email.Cc, email.Bcc, email.SendBy, email.Subject, email.Contents, email.BodyType, email.Attachs, email.SendType, email.SendName, email.SendingTime, email.custId, email.isSent, email.sourceId, email.id, email.source_key });
        }
        public async Task<BaseValidate> TakeNotification(BaseCtrlClient clt, AppNotifyTake1 take)
        {
            const string storedProcedure = "sp_res_notify_push_take";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, param =>
            {
                    param.Add("@notiType", take.notiType);
                    param.Add("@subject", take.subject);
                    param.Add("@action_list", take.action_list);
                    param.Add("@content_notify", take.content_notify);
                    param.Add("@content_sms", take.content_sms);
                    param.Add("@contentType", take.contentType);
                    param.Add("@content_markdown", take.content_markdown);
                    param.Add("@content_email", take.content_email);
                    param.Add("@bodytype", take.bodytype);
                    param.Add("@external_param", take.external_param);
                    param.Add("@external_event", take.external_event);
                    //param.Add("@source_key", take.source_key);
                    if (take.attachs != null && take.attachs.Count > 0 && !string.IsNullOrEmpty(take.attachs.FirstOrDefault().attach_url))
                        param.AddTable("@attachs", "user_notify_attach", take.attachs);
                    else
                        param.AddTable("@attachs", "user_notify_attach", new List<AppNotifyAttach>());
                    param.AddTable("@notiusers", "user_notify_type", take.appUsers);
                return param;
            });
        }
        public async Task<BaseValidate> TakeNotification2(BaseCtrlClient clt, AppNotifyTake take)
        {
            const string storedProcedure = "sp_res_notify_push_take2";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, param =>
            {
                    param.Add("@n_id", take.n_id);
                    param.Add("@notiType", take.notiType);
                    param.Add("@subject", take.subject);
                    param.Add("@action_list", take.action_list);
                    param.Add("@content_notify", take.content_notify);
                    param.Add("@content_sms", take.content_sms);
                    param.Add("@contentType", take.contentType);
                    param.Add("@content_markdown", take.content_markdown);
                    param.Add("@content_email", take.content_email);
                    param.Add("@bodytype", take.bodytype);
                    param.Add("@external_key", take.external_key);
                    param.Add("@external_sub", take.external_sub);
                    param.Add("@external_param", take.external_param);
                    param.Add("@external_event", take.external_event);
                    param.Add("@send_by", take.send_by);
                    param.Add("@send_name", take.send_name);
                    param.Add("@brand_name", take.brand_name);
                    param.Add("@source_key", "system");
                    param.Add("@source_id", null);                    
                    if (take.attachs != null && take.attachs.Count > 0 && !string.IsNullOrEmpty(take.attachs.FirstOrDefault().attach_url))
                        param.AddTable("@attachs", "user_notify_attach", take.attachs);
                    else
                        param.AddTable("@attachs", "user_notify_attach", new List<AppNotifyAttach>());
                    param.AddTable("@notiusers", "user_notify_type", take.appUsers);
                return param;
            },
            async result =>
            {
                var data = await result.ReadFirstAsync<BaseValidate>();
                if (data != null && data.valid)
                {
                    var nrun = new PushNotifyRun
                        {
                            NotiId = data.work_st,
                            n_id = data.id,
                            action = take.action_list,
                            ids = new List<string>()
                        };
                        await SetNotifyToPushRun(clt.UserId, nrun);
                }
                return data;
            });
        }

        public async Task<DataSet> GetRoomNotifySendTemp(string userId, string projectCd, string buildingCd)
        {
            const string storedProcedure = "sp_res_notify_send_imports_temp";
            return await GetDataSetAsync(storedProcedure, new Dictionary<string, Dictionary<SqlDbType, object>>
            {
            { "UserId", new Dictionary<SqlDbType, object> {{SqlDbType.NVarChar, base.CommonInfo.UserId } }},
            { "projectCd", new Dictionary<SqlDbType, object> {{SqlDbType.NVarChar, projectCd } }},
            { "buildingCd", new Dictionary<SqlDbType, object> {{SqlDbType.NVarChar, buildingCd } }},
            });
        }

        public async Task<ImportRoomNotifyPushListPage> ImportRoomNotifySendAsync(string userId, string projectCd, string buildingCd, RoomNotifyPushImport rooms)
        {
            const string storedProcedure = "sp_res_notify_send_import_set";
            return await GetMultipleAsync<ImportRoomNotifyPushListPage>(storedProcedure, param =>
            {
                param.Add("userId", userId);
                param.Add("@accept", rooms.Accept);
                param.Add("@projectCd", projectCd);
                param.Add("@buildingCd", buildingCd);
                param.AddTable("rooms", TableTypes.ROOM_NOTIFY_PUSH_IMPORT_TYPE, rooms.Imports);
                if (rooms.ImportFile != null)
                {
                    param.AddDynamicParams(rooms.ImportFile);
                }
                return param;
            }, async result =>
            {
                var page = await result.ReadFirstOrDefaultAsync<ImportRoomNotifyPushListPage>();
                page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
                page.dataList = (await result.ReadAsync<object>()).ToList();
                page.importFile = await result.ReadFirstOrDefaultAsync<uImportFile>();
                page.roomModels = (await result.ReadAsync<RoomModel>()).ToList();
                return page;
            });
            
        }
        #endregion
        public CommonListPage GetNotifySentPageByRoom(FilterInpNotifySend flt)
        {
            const string storedProcedure = "sp_res_notify_sent_page_ByRoom";
            return GetPage(storedProcedure, flt, new { roomCode = flt.filter });
        }

    }
}

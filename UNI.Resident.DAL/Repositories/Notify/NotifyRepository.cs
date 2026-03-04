using DapperParameters;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Api;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Utils;


namespace UNI.Resident.DAL.Repositories.Notify
{
    /// <summary>
    /// AppManagerRepository
    /// </summary>
    /// Author: 
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="NotifyRepository" />
    public class NotifyRepository : ResidentBaseRepository, INotifyRepository
    {
        private readonly string _notifyTopic;
        private readonly IApiSenderRepository _apiSenderRepository;
        public NotifyRepository(
            IConfiguration configuration,
            IResidentCommonBaseRepository common,
            IApiSenderRepository apiSenderRepository
            ) : base(common, false)
        {
            _notifyTopic = configuration["Kafka:ProducerSettings:Topics:Notification"];
            _apiSenderRepository = apiSenderRepository;
        }

        #region message-reg
        public Task<CommonDataPage> GetNotifyMessagePage(FilterInpNotifySend flt, string externalKey)
        {
            const string storedProcedure = "sp_res_message_page";
            return GetDataListPageAsync(storedProcedure, flt,
                    new { flt.fromDate, flt.toDate, flt.source_key, custId = flt.filter }
                );
        }

        public async Task<int> TakeMessage(MessageSend mess)
        {
            const string storedProcedure = "sp_res_message_set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure,
                new { base.CommonInfo.UserId, base.CommonInfo.ClientId, base.CommonInfo.ClientIp, mess.messageId, mess.phone, mess.custName, mess.message, mess.scheduleAt, mess.brandName, mess.isSent, mess.custId, mess.sourceId, mess.partner, mess.remart });
        }


        #endregion message-reg

        #region email-reg
        public Task<CommonDataPage> GetNotifyEmailPage(FilterInpNotifySend flt, string externalKey)
        {
            const string storedProcedure = "sp_res_email_page";
            return GetDataListPageAsync(storedProcedure, flt,
                new { flt.fromDate, flt.toDate, flt.source_key, custId = flt.filter }
            );
        }

        public async Task<int> TakeSendMail(EmailBase email)
        {
            const string storedProcedure = "sp_res_email_set";
            string attachs = email.Attachs != null && email.Attachs.Count > 0 ? string.Join(",", email.Attachs) : "";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { base.CommonInfo.UserId, base.CommonInfo.ClientId, base.CommonInfo.ClientIp, email.To, email.Cc, email.Bcc, email.SendBy, email.Subject, email.Contents, email.BodyType, Attachs = attachs, email.SendType, email.SendName, email.SendingTime, email.custId, email.isSent, email.sourceId, email.id, email.source_key });
        }

        #endregion email-reg

        #region notify-man-reg

        public async Task<List<CommonValue>> GetNotiPushStatus(string userId)
        {
            const string storedProcedure = "sp_res_notify_status";
            return await GetListAsync<CommonValue>(storedProcedure, new { });
        }
        public Task<CommonDataPage> GetAppNotifyPage(FilterInpNotify flt, string externalKey)
        {
            const string storedProcedure = "sp_res_notify_info_page";
            return GetDataListPageAsync(storedProcedure, flt,
                new { externalKey, source_ref = flt.source_ref, flt.filter, flt.source_key, flt.external_sub, flt.isPublish, flt.actionlist }
            );
        }

        public async Task<resNotifyInfo> GetNotifyInfo(NotifyParam pm, string externalKey)
        {
            const string storedProcedure = "sp_res_notify_info_fields2";
            var rs = await GetFieldsAsync<resNotifyInfo>(storedProcedure, param =>
            {
                param.Add("@external_key", externalKey);
                param.Add("@n_id", pm.n_id);
                param.Add("@actions", pm.actions);
                param.Add("@source_ref", pm.source_ref);
                param.Add("@tempId", pm.tempId);
                param.Add("@to_type", pm.to_type);
                param.Add("@to_level", pm.to_level);
                param.Add("@to_groups", pm.to_groups);
                return param;
            },
                async (data, result) =>
                {
                    data.attachs = (await result.ReadAsync<NotifyAttach>()).ToList();
                    data.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
                    //data.toLevels = result.Read<NotifyToLevel>().ToList();
                    data.notifyTos = (await result.ReadAsync<NotifyToGet>()).ToList();
                    return data;
                });
            return rs;
        }
        public async Task<resNotifyInfo> SetNotifyDraft(resNotifyInfoSet noti)
        {
            const string storedProcedure = "sp_res_notify_info_draft";
            return await GetFieldsAsync<resNotifyInfo>(storedProcedure, param =>
                {
                    param.Add("@n_id", noti.n_id);
                    param.Add("@external_sub", noti.external_sub);
                    param.AddDynamicParams(noti.ToObject());
                    if (noti.attachs == null) noti.attachs = new List<NotifyAttach>();
                    param.AddTable("@attachs", "user_notify_attach", noti.attachs);
                    if (noti.notifyTos == null)
                    {
                        noti.notifyTos = new List<NotifyToSet>();
                    }
                    param.AddTable("@notiTos", "user_notify_to", noti.notifyTos);
                    return param;
                },
                    async (data, result) =>
                    {
                        data.attachs = (await result.ReadAsync<NotifyAttach>()).ToList();
                        data.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
                        //data.toLevels = info.toLevels;
                        data.notifyTos = (await result.ReadAsync<NotifyToGet>()).ToList();
                        return data;
                    });
        }
        
        public async Task<BaseValidate> SetNotifyInfo(resNotifyInfoSet noti)
        {
            const string storedProcedure = "sp_res_notify_info_set2";
            var rs = await base.GetMultipleAsync(storedProcedure, param =>
            {
                if (noti.GetValueByFieldName("content_type") == "1")
                {
                    var tmp = MarkdownHtmlHelper.ConvertMarkdownToHtml(noti.GetValueByFieldName("content_markdown"));
                    noti.SetValueByFieldName("content_email", tmp);
                }
                else
                {
                    noti.SetValueByFieldName("content_email", noti.GetValueByFieldName("content_markdown"));
                }
                param.Add("@n_id", noti.n_id);
                param.Add("@tempId", noti.GetValueByFieldName("tempId"));
                param.Add("@actionlist", noti.GetValueByFieldName("actionlist"));
                param.Add("@Subject", noti.GetValueByFieldName("Subject"));
                param.Add("@content_notify", noti.GetValueByFieldName("content_notify"));
                param.Add("@content_sms", noti.GetValueByFieldName("content_sms"));
                param.Add("@content_type", noti.GetValueByFieldName("content_type"));
                param.Add("@content_markdown", noti.GetValueByFieldName("content_markdown"));
                param.Add("@content_email", noti.GetValueByFieldName("content_email"));
                param.Add("@bodytype", noti.GetValueByFieldName("bodytype"));
                param.Add("@isPublish", noti.GetValueByFieldName("isPublish"));
                param.Add("@external_key", noti.GetValueByFieldName("external_key"));
                param.Add("@source_ref", noti.GetValueByFieldName("source_ref"));
                param.Add("@source_key", noti.GetValueByFieldName("source_key"));
                param.Add("@external_event", noti.GetValueByFieldName("external_event"));
                param.Add("@brand_name", noti.GetValueByFieldName("brand_name"));
                param.Add("@send_name", noti.GetValueByFieldName("send_name"));
                param.Add("@notiAvatarUrl", noti.GetValueByFieldName("notiAvatarUrl"));
                param.Add("@isHighLight", noti.GetValueByFieldName("isHighLight"));
                param.Add("@schedule", noti.GetValueByFieldName("schedule"));
                param.Add("@external_name", noti.GetValueByFieldName("external_name"));
                param.Add("@to_type", noti.GetValueByFieldName("to_type"));
                param.Add("@attachs_noti", noti.GetValueByFieldName("attachs"));
                param.AddDynamicParams(new
                {
                    noti.external_sub,
                    noti.sendNow
                });
                if (noti.notifyTos == null) noti.notifyTos = new List<NotifyToSet>();
                param.AddTable("@notiTos", "user_notify_to", noti.notifyTos);
                return param;
            }, async result =>
            {
                var data = result.ReadFirstOrDefault<BaseValidate>();
                if (noti.sendNow && data.valid)
                {
                    var nrun = new PushNotifyRun
                    {
                        n_id = data.id,
                        action = data.code,
                        ids = new List<string>()
                    };
                    await _apiSenderRepository.SendToKafka(nrun.SerializeToJson());
                }
                return data;
            });
            return rs;
        }
        public async Task<BaseValidate> DelNotifyInfo(Guid n_id)
        {
            const string storedProcedure = "sp_res_notify_info_del1";
            return await DeleteAsync(storedProcedure, new { n_id });
        }

        public async Task<BaseValidate> SetAppNotifyStatus(AppNotifyId noti)
        {
            const string storedProcedure = "sp_res_notify_info_status";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { noti.n_id, noti.status });
        }
        #endregion notify-man-reg


        #region notify-to-reg
        public Task<CommonDataPage> GetNotifyToPage(FilterInpNotifyId flt)
        {
            const string storedProcedure = "sp_res_notify_to_page";
            return GetDataListPageAsync(storedProcedure, flt, new { flt.n_id });
        }
        public async Task<NotifyTo> GetNotifyToAsync(Guid? n_id, Guid? id, int? to_level, string to_groups, int? to_type)
        {
            const string storedProcedure = "sp_res_notify_to_get";
            return await GetFieldsAsync<NotifyTo>(storedProcedure, new { sourceId = n_id, id, to_type, to_level, to_groups });
        }
        public async Task<BaseValidate> SetNotifyTo(NotifyTo noti)
        {
            const string storedProcedure = "sp_res_notify_to_set1";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                param =>
                {
                    param.Add("@sourceId", noti.sourceId);
                    param.Add("@id", noti.id);
                    param.Add("@to_row", noti.to_count);
                    param.Add("@to_row", noti.GetValueByFieldName("to_row"));
                    param.Add("@to_level", noti.GetValueByFieldName("to_level"));
                    param.Add("@to_groups", noti.GetValueByFieldName("to_groups"));
                    param.Add("@to_type", noti.GetValueByFieldName("to_type"));
                    return param;
                });
        }
        public async Task<BaseValidate> DelNotifyTo(Guid id)
        {
            const string storedProcedure = "sp_res_notify_to_del1";
            return await DeleteAsync(storedProcedure, new { id });
        }

        public async Task<NotifyTo> SetNotifyToDraft(NotifyTo noti)
        {
            const string storedProcedure = "sp_res_notify_to_draft1";
            return await base.SetInfoAsync<NotifyTo>(storedProcedure, noti, param =>
            {
                param.Add("@sourceId", noti.sourceId);
                param.Add("@id", noti.id);
                param.Add("@to_row", noti.to_count);
                //param.Add("@to_row", noti.GetValueByFieldName("to_row"));
                //param.Add("@to_level", noti.GetValueByFieldName("to_level"));
                //param.Add("@to_groups", noti.GetValueByFieldName("to_groups"));
                //param.Add("@to_type", noti.GetValueByFieldName("to_type"));
                //param.AddTable("@notiTos", "user_notify_to", noti.ToObjectList<NotifyToSet>()); // Uncommenting this line
                return param;
            });
        }
        public async Task<NotifyToListGet> GetNotifyToList(Guid? n_id, int? to_level, string to_groups, int to_type)
        {
            const string storedProcedure = "sp_res_notify_to_list";
            var rs = await base.GetMultipleAsync(storedProcedure, param =>
            {
                param.Add("@n_id", n_id);
                param.Add("@to_type", to_type);
                param.Add("@to_level", to_level);
                param.Add("@to_groups", to_groups);
                param.Add("@project_code", base.ProjectCode);
                return param;
            }, async result =>
            {
                var data = await result.ReadFirstOrDefaultAsync<NotifyToListGet>();
                if (data != null)
                {
                    data.toLevels = result.Read<NotifyToLevel>().ToList();
                    data.notifyTos = result.Read<NotifyToGet>().ToList();
                    data.accesses = result.Read<CommonValue>().ToList();
                    data.actions = result.Read<CommonValue>().ToList();
                }
                return data;
            });
            return rs;
        }
        public async Task<BaseValidate> SetNotifyToList(NotifyToList notiTo)
        {
            const string storedProcedure = "sp_res_notify_to_set";
            var rs = await base.GetMultipleAsync(storedProcedure, param =>
            {
                param.Add("@n_id", notiTo.n_id);
                //param.Add("@to_type", notiTo.to_type);
                param.Add("@access_role", notiTo.access_role);
                if (notiTo.notifyTos == null) notiTo.notifyTos = new List<NotifyToSet>();
                param.AddTable("@notiTos", "user_notify_to", notiTo.notifyTos);
                return param;
            }, async result =>
            {
                var data = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                return data;
            });
            return rs;
        }
        public async Task<CommonDataPage> SetNotifyToDraftPage(NotifyTo noti)
        {
            const string storedProcedure = "sp_res_notify_to_draft_page";
            return await GetDataListPageAsync(storedProcedure, null, param =>
            {
                param.Add("@sourceId", noti.sourceId);
                param.Add("@id", noti.id);
                param.Add("@to_row", noti.to_count);
                param.Add("@to_row", noti.GetValueByFieldName("to_row"));
                param.Add("@to_level", noti.GetValueByFieldName("to_level"));
                param.Add("@to_groups", noti.GetValueByFieldName("to_groups"));
                param.Add("@to_type", noti.GetValueByFieldName("to_type"));
                return param;
            });
        }
        #endregion notify-to-reg

        #region notify-push-reg
        public async Task<CommonViewInfo> GetNotifyToPushsFilter(Guid? n_id)
        {
            const string storedProcedure = "sp_res_notify_push_filter";
            return await base.GetFieldsAsync<CommonViewInfo>(storedProcedure, new { n_id });
        }
        public async Task<BaseValidate> SetNotifyCreatePush(PushNotifyCreate noti)
        {
            const string storedProcedure = "sp_res_notify_push_creates";
            return await base.SetAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("@n_id", noti.n_id);
                param.AddTable("@notiusers", "user_notify_type", noti.appUsers);
                return param;
            });
        }
        public async Task<CommonDataPage> GetNotifyPushPageByNotiId(FilterInpNotifyPush filter)
        {
            const string storedProcedure = "sp_res_notify_push_page_byNotiId";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.n_id, filter.push_st, filter.email_st, filter.sms_st });
        }
        public async Task<CommonDataPage> GetNotifySentPageByUser(FilterInpNotifyUser filter)
        {
            const string storedProcedure = "sp_res_notify_sent_page_user";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.byUser });
        }

        public async Task<BaseValidate> DelNotiPush(string id)
        {
            const string storedProcedure = "sp_res_notify_push_del";
            return await DeleteAsync(storedProcedure, new { id });
        }
        public async Task<BaseValidate> TakeNotification(AppNotifyTake take)
        {
            const string storedProcedure = "sp_res_notify_push_take";
            return await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                param =>
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
                        param.AddTable("@attachs", "user_notify_attach", new List<AppNotifyAttachNew>());
                    param.AddTable("@notiusers", "user_notify_type", take.appUsers);
                    return param;
                }
                //new { clt?.UserId, clt?.ClientId, take.n_id, take.notiType, take.subject, take.action_list, take.content_notify, take.content_sms, take.contentType, take.content_markdown, take.content_email, take.bodytype, take.external_key, take.external_sub, take.external_param, take.external_event, take.send_by, take.send_name, take.brand_name, take.sourceId, take.attachs, take.appUsers }
                );
        }
        public async Task<AppNotifyTake1> SetNotifyToPushRun(PushNotifyRun noti)
        {
            const string storedProcedure = "sp_res_notify_push_run";
            var rs = await base.GetMultipleAsync(storedProcedure,
            new { noti.n_id, noti.action, noti.run_act, ids = string.Join(",", noti.ids) },
            async result =>
            {
                var data = result.ReadFirstOrDefault<AppNotifyTake1>();
                if (data != null)
                {
                    //data.appUsers = result.Read<PushNotifyUser>().ToList();
                    //noti.ids = new List<string>();
                    noti.action = data.action_list;
                    await _apiSenderRepository.SendToKafka(_notifyTopic, noti.SerializeToJson());
                }
                
                return data;
            });
            return rs;
        }
        public async Task<List<PushNotifyUser>> GetFamilyPush(PushNotifyHomSet noti)
        {
            const string storedProcedure = "sp_res_apartment_user_byPush";
            return await GetListAsync<PushNotifyUser>(storedProcedure, new { noti.ProjectCd, noti.buildingCd, apartments = string.Join(",", noti.apartments) });
        }

        public async Task SetDocumentUrl(HomDocumentUrlSet doc)
        {
            const string storedProcedure = "sp_res_document_set";
            await base.SetAsync(storedProcedure, new { DocId = 0, doc.ProjectCd, doc.DocumentTitle, doc.DocumentUrl, IsUsed = 1 });
        }
        public async Task<CommonDataPage> GetDocumentUrl(FilterInputProject filter)
        {
            const string storedProcedure = "sp_res_document_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { filter.projectCd, filter.filter, filter.offSet, filter.pageSize });
        }

        public Task<BaseResponse<string>> SendToKafka(PushNotifyRun noti)
        {
            return _apiSenderRepository.SendToKafka(_notifyTopic, noti.SerializeToJson());
        }
        #endregion notify-push-reg

        #region scheduled-notify-reg
        public async Task<List<PushNotifyRun>> GetScheduledNotifications(int maxRecords = 100)
        {
            const string storedProcedure = "sp_res_notify_scheduled_get";
            
            return await GetMultipleAsync<List<PushNotifyRun>>(
                storedProcedure, 
                new { MaxRecords = maxRecords },
                async reader =>
                {
                    var notifyInboxList = (await reader.ReadAsync<PushNotifyRun>()).ToList();
                    foreach (var inbox in notifyInboxList)
                    {
                        inbox.ids = new List<string>();
                    }
                    
                    return notifyInboxList;
                });
        }
        #endregion scheduled-notify-reg

        #region notify-comment-reg
        public async Task<AppNotifyComment> SetNotiCommentAsync(AppNotifyCommentSet comm)
        {
            const string storedProcedure = "sp_res_notify_comment_set";
            return await GetFirstOrDefaultAsync<AppNotifyComment>(storedProcedure, new { comm.CommentId, comm.NotiId, comm.ParrentId, comm.Comments });
        }
        public async Task<CommonDataPage> GetNotiComments(FilterInpNotifyId flt)
        {
            const string storedProcedure = "sp_res_notify_comment_list";
            return await GetDataListPageAsync(storedProcedure, flt, new { flt.n_id });
        }
        public async Task<CommonDataPage> GetNotiCommentById(FilterBase flt)
        {
            const string storedProcedure = "sp_res_notify_comment_ByParrent";
            return await GetDataListPageAsync(storedProcedure, flt, new { CommentId = flt.id });
        }
        public async Task<int> SetNotiCommentAuth(AppNotifyCommentAuth comm)
        {
            const string storedProcedure = "sp_res_notify_comment_auth";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { comm.CommentId, comm.Status });
        }
        #endregion notify-comment-reg

        #region notify-app-reg

        public async Task<SentNotifyPage> GetNotifyByUser(FilterInputProject flt)
        {
            const string storedProcedure = "sp_res_app_notify_sent_byuserId";
            var rs = await base.GetMultipleAsync(storedProcedure,
            new { flt.projectCd, source_ref = flt.customOid, isHighLight = flt.gridWidth, flt.offSet, flt.pageSize },
            async result =>
            {
                var data = await result.ReadFirstOrDefaultAsync<SentNotifyPage>();
                if (data != null)
                {
                    data.Notifies = result.Read<SentNotify>().ToList();
                }
                return data;
            });
            return rs;
        }
        public async Task<SentNotifyGet> GetSentNotifyDetailAsync(Guid n_id)
        {
            const string storedProcedure = "sp_res_app_notify_sent_get";
            return await GetFirstOrDefaultAsync<SentNotifyGet>(storedProcedure, new { n_id });
        }
        public async Task<int> SetNotificationReadAll(string external_key)
        {
            const string storedProcedure = "sp_res_notify_sent_read_all";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { external_key });
        }


        #endregion notify-app-reg               

        #region notify-ref
        public Task<CommonDataPage> GetNotifyRefPage(FilterInput filter, string externalKey)
        {
            const string storedProcedure = "sp_res_notify_ref_page";
            return GetDataListPageAsync(storedProcedure, filter, new { external_key = externalKey });
        }
        public async Task<AppNotifyRef> GetNotifyRefAsync(Guid? source_ref, string externalKey)
        {
            const string storedProcedure = "sp_res_notify_ref_fields";
            return await GetFieldsAsync<AppNotifyRef>(storedProcedure, new { external_key = externalKey, source_ref });
        }
        public async Task<BaseValidate> SetNotifyRef(AppNotifyRef noti)
        {
            const string storedProcedure = "sp_res_notify_ref_set";
            return await base.SetInfoAsync<BaseValidate>(storedProcedure, noti, new { noti.Oid });
        }
        public async Task<BaseValidate> DelNotifyRef(Guid source_ref)
        {
            const string storedProcedure = "sp_res_notify_ref_del";
            return await DeleteAsync(storedProcedure, new { source_ref });
        }

        public async Task<List<CommonValue>> GetNotifyTypeList(string externalKey)
        {
            const string storedProcedure = "sp_res_notify_ref_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { externalKey });
        }
        #endregion notify-ref

        #region notify-temp
        public async Task<CommonViewInfo> GetNotifyTempFilter(string userId)
        {
            const string storedProcedure = "sp_res_notify_temp_filter";
            return await base.GetFieldsAsync<CommonViewInfo>(storedProcedure, new { });
        }
        public async Task<CommonDataPage> GetNotifyTempPage(FilterInpNotifyTemp filter, string externalKey, string projectcode)
        {
            const string storedProcedure = "sp_res_notify_temp_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { external_key = externalKey, filter.source_key, filter.app_st, projectcode });
        }
        public async Task<NotifyTemp> GetNotifyTempAsync(Guid? tempId, Guid? n_id, string external_key)
        {
            const string storedProcedure = "sp_res_notify_temp_fields";
            return await GetFieldsAsync<NotifyTemp>(storedProcedure, new { tempId, n_id, external_key });
        }
        public async Task<NotifyTemp> SetNotifyTempDraft(NotifyTemp noti)
        {
            const string storedProcedure = "sp_res_notify_temp_draft";
            return await base.GetFieldsAsync<NotifyTemp>(storedProcedure, param =>
                {
                    param.Add("@tempId", noti.id);
                    param.AddDynamicParams(noti.ToObject());
                    return param;
                });
        }
        public async Task<BaseValidate> SetNotifyTemp(NotifyTemp info)
        {
            const string storedProcedure = "sp_res_notify_temp_set";
            return await base.SetInfoAsync<BaseValidate>(storedProcedure, info, new { tempId = info.id });
        }
        public async Task<BaseValidate> DelNotifyTemp(Guid tempId)
        {
            const string storedProcedure = "sp_res_notify_temp_del";
            return await DeleteAsync(storedProcedure, new { tempId });
        }
        public async Task<List<CommonValue>> GetNotifyTempList(string external_key, int? can_st, string projectcode)
        {
            const string storedProcedure = "sp_res_notify_temp_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { external_key, projectcode });
        }
        public async Task<List<CommonValue>> GetNotifyFields(string userId)
        {
            const string storedProcedure = "sp_res_notify_field_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { });
        }
        public async Task<List<CommonValue>> GetNotifyTemplateFields(Guid tempId)
        {
            const string storedProcedure = "sp_res_get_notify_template_fields";
            return await GetListAsync<CommonValue>(storedProcedure, new { tempId });
        }
        public async Task<CommonViewInfo> GetNotifyFilterAsync(string tableKey)
        {
            const string storedProcedure = "sp_res_notify_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { tableKey });
        }
        #endregion notify-temp

        #region notify-sent-import-reg
        /// <summary>
        /// GetNotifySentImportTemp - Get template structure
        /// </summary>
        public async Task<DataSet> GetNotifySentImportTemp()
        {
            const string storedProcedure = "sp_res_notify_sent_imports_temp";
            return await GetDataSetAsync(storedProcedure);
        }

        /// <summary>
        /// SetNotifySentImport - Import danh sách gửi thông báo từ Excel
        /// </summary>
        public async Task<ImportListPage> SetNotifySentImport(NotifySentImportSet importSet, Guid n_id)
        {
            const string storedProcedure = "sp_res_notify_sent_imports";
            return await base.SetImport<NotifySentImport, NotifySentImportSet>(
                storedProcedure,
                importSet,
                "data",
                TableTypes.NOTIFY_SENT_IMPORT_TYPE,
                new { n_id, userId = base.CommonInfo.UserId });
        }
        #endregion notify-sent-import-reg

    }
}
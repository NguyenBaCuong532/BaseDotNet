using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Repositories.App;

public class AppNotifyRepository : UniBaseRepository, IAppNotifyRepository
{

    /// <summary>
    /// ctor
    /// </summary>
    /// <param name="commonRequestInfo"></param>
    /// 
    //private readonly INotifyRepository _apiNotifyRepository;
    public AppNotifyRepository(IUniCommonBaseRepository commonRequestInfo) : base(commonRequestInfo)
    {
        //_apiNotifyRepository = apiNotifyRepository;
    }
    public async Task<List<CommonValue>> GetNotifyRefList(string source_key)
    {
        return await base.GetListAsync<CommonValue>("sp_app_notify_ref_list", new { source_key });
    }
    public async Task<SentNotifyPage> GetNotifyByUser(FilterBase flt, string code)
    {
        const string storedProcedure = "sp_app_notify_sent_byuserId";
        var rs = await base.GetMultipleAsync(storedProcedure,
        new {code= code, source_ref = flt.id, isHighLight = flt.gridWidth, flt.offSet, flt.pageSize },
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
    public async Task<SentNotifyGet> GetSentNotifyDetail(Guid n_id)
    {
        const string storedProcedure = "sp_app_notify_sent_get";
        var rs = await base.GetMultipleAsync(storedProcedure,
        new { n_id },
        async result =>
        {
            var data = await result.ReadFirstOrDefaultAsync<SentNotifyGet>();
            if (data != null)
            {
                data.attachments = result.Read<AppNotifyAttach1>().ToList();
                if (data.attachments == null) data.attachments = new List<AppNotifyAttach1>();
            }
            return data;
        });
        return rs;
    }
    public async Task<int> SetNotificationReadAll(string external_key)
    {
        const string storedProcedure = "sp_notify_sent_read_all";
        return await base.GetFirstOrDefaultAsync<int>(storedProcedure, new { external_key });
    }
    //public async Task<BaseValidate> SetFeedNotifyPush(SentNotifyPush noti)
    //{
    //    const string storedProcedure = "sp_app_notify_push_feed_set";
    //    var rs = await base.GetMultipleAsync(storedProcedure, 
    //      new { type = noti.type,
    //          feedId = noti.feedId,
    //          userIdCreatedFeed = noti.userIdCreatedFeed,
    //          avatarUrl = noti.avatarUrl,
    //          feedTitle = noti.feedTitle,
    //          feedThumnail = noti.feedThumnail
    //      },
    //        async result =>
    //        {
    //            var data = await result.ReadFirstOrDefaultAsync<BaseValidate>();
    //            if (data.valid)
    //            {
    //                var pushRuns = result.Read<PushNotifyRun>();
    //                if (pushRuns != null)
    //                {
    //                    foreach (var pushRun in pushRuns)
    //                    {
    //                        pushRun.ids = new List<string>();
    //                        await _apiNotifyRepository.SendToKafka(pushRun);
    //                    }
    //                }
    //            }
    //            return (data);
    //        }); 
    //    return rs;
    //}

    public async Task<List<CommonValue>> GetFeedbackType()
    {
        const string storedProcedure = "sp_User_Feedback_Types";
        return await base.GetListAsync<CommonValue>(storedProcedure, new { });        
    }
    public async Task<int> SendFeedback(Feedback feedback)
    {
        const string storedProcedure = "sp_User_Feedback_Set";
        return await base.GetFirstOrDefaultAsync<int>(storedProcedure, feedback);        
    }
    //public async Task SetFeedbackAttach(AppNotifyAttach attach)
    //{
    //    const string storedProcedure = "sp_User_Feedback_Attach_Set";
    //    try
    //    {
    //        using (SqlConnection connection = new SqlConnection(_connectionString))
    //        {
    //            connection.Open();
    //            var param = new DynamicParameters();
    //            param.Add("@UserId", userId);
    //            //param.Add("@id", attach.n_id);
    //            //param.Add("@feedbackId", attach.requestId);
    //            //param.Add("@processId", attach.processId);
    //            //param.Add("@attachUrl", attach.attachUrl);
    //            //param.Add("@attachType", attach.attachType);
    //            //param.Add("@attachFileName", attach.attachFileName);
    //            //param.Add("@used", attach.used);
    //            await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
    //            return;
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        throw ex;
    //    }
    //}
    public async Task<FeedbackPage> GetFeedbackListAsync(FilterInputProject flt)
    {
        const string storedProcedure = "sp_User_Feedback_ByManager";
        var rs = await base.GetMultipleAsync(storedProcedure,
        new { projectCd = flt.projectCd, flt.offSet, flt.pageSize },
        async result =>
        {
            var data = await result.ReadFirstOrDefaultAsync<FeedbackPage>();
            if (data != null)
            {
                data.Feedbacks = result.Read<FeedbackGet>().ToList();
            }
            return data;
        });
        return rs;        
    }
    public async Task<FeedbackFull> GetFeedback(string feedbackId)
    {
        const string storedProcedure = "sp_User_Feedback_get";
        var rs = await base.GetMultipleAsync(storedProcedure, new { feedbackId },
        async result =>
        {
            var data = await result.ReadFirstOrDefaultAsync<FeedbackFull>();
            if (data != null)
            {
                data.attachs = result.Read<HomRequestAttach>().ToList();
            }
            return data;
        });
        return rs;
    }

}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.Model.Common;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Interfaces.App;

public interface IAppNotifyRepository
{
    Task<SentNotifyPage> GetNotifyByUser(FilterBase flt, string code);
    Task<List<CommonValue>> GetNotifyRefList(string source_key);
    Task<SentNotifyGet> GetSentNotifyDetail(Guid n_id);
    Task<int> SetNotificationReadAll(string external_key);
    //Task<BaseValidate> SetFeedNotifyPush(SentNotifyPush noti);
    Task<List<CommonValue>> GetFeedbackType();
    Task<int> SendFeedback(Feedback feedback);
    Task<FeedbackPage> GetFeedbackListAsync(FilterInputProject filter);
    Task<FeedbackFull> GetFeedback(string feedbackId);
}
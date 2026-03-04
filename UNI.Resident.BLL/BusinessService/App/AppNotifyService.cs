using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model.Common;
using UNI.Resident.Model;

namespace UNI.Resident.BLL.BusinessService.App;

public class AppNotifyService : IAppNotifyService
{
    private readonly IAppNotifyRepository _notificationRepository;
    /// <summary>
    /// ctor
    /// </summary>
    /// <param name="notificationRepository"></param>
    public AppNotifyService(IAppNotifyRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
    }
    public async Task<List<CommonValue>> GetNotifyRefList(string source_key)
    {
        return await _notificationRepository.GetNotifyRefList(source_key);
    }
    public Task<SentNotifyPage> GetNotifyByUser(FilterBase flt,string code)
    {
        return _notificationRepository.GetNotifyByUser(flt,code);
    }
    public Task<SentNotifyGet> GetSentNotifyDetail(Guid n_id)
    {
        return _notificationRepository.GetSentNotifyDetail(n_id);
    }
    public Task<int> SetNotificationReadAll(string external_key)
    {
        return _notificationRepository.SetNotificationReadAll(external_key);
    }
    //public Task<BaseValidate> SetFeedNotifyPush(SentNotifyPush noti)
    //{
    //    return _notificationRepository.SetFeedNotifyPush(userId,noti);
    //}
    public Task<List<CommonValue>> GetFeedbackType()
    {
        return _notificationRepository.GetFeedbackType();
    }
    public Task<int> SendFeedback(Feedback feedback)
    {
        return _notificationRepository.SendFeedback( feedback);
    }
    public Task<FeedbackPage> GetFeedbackList(FilterInputProject filter)
    {
        return _notificationRepository.GetFeedbackListAsync(filter);
    }
    public Task<FeedbackFull> GetFeedback(string feedbackId)
    {
        return _notificationRepository.GetFeedback(feedbackId);
    }
}
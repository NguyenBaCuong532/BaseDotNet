using System;
using System.Collections.Generic;
using UNI.Model.APPM.Notifications;

namespace UNI.Resident.Model.Notification
{
    /// <summary>
    /// Model cho thông báo đã đến lịch gửi
    /// </summary>
    public class ScheduledNotifyInfo
    {
        public NotifySendInbox NotifyInbox { get; set; }
        public List<NotifySentDetail> NotifySentList { get; set; }
    }
    public class NotifySendInbox
    {
        public Guid n_id { get; set; }
        public string actionlist { get; set; }
    }
    /// <summary>
    /// Chi tiết thông báo đã gửi
    /// </summary>
    public class NotifySentDetail
    {
        public Guid id { get; set; }
        public Guid n_id { get; set; }
    }
}


using UNI.Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace SSG.Resident.Model.Notification
{
    public class Notification
    {
    }
    public class NotifyAttach
    {
        public Guid n_id { get; set; }
        public string attach_name { get; set; }
        public string attach_url { get; set; }
        public string attach_type { get; set; }
    }

    public class NotifyTemp : viewBaseInfo
    {
        public Guid? id { get; set; }
        public string source_key { get; set; }
        public List<NotifyAttach> attachs { get; set; }
    }

    public class SentNotifyPage
    {
        public long? RecordsTotal { get; set; }
        public long? RecordsFiltered { get; set; }
        public long? TotalUnread { get; set; }
        public List<SentNotify> Notifies { get; set; }
    }

    public class SentNotify
    {
        public Guid n_id { get; set; }
        public string Subject { get; set; }
        public string Description { get; set; }
        public string NotiDate { get; set; }
        public string NotiByTime { get; set; }
        public string notiAvatarUrl { get; set; }
        public bool IsRead { get; set; }
        public int countComment { get; set; }
        public string appName { get; set; }
        public string appIcon { get; set; }
        public string refName { get; set; }
        public string refIcon { get; set; }
        public string external_event { get; set; }
        public string external_param { get; set; }
    }

    public class NotifyInfo : viewBaseInfo
    {
        public Guid? n_id { get; set; }
        public string can_id { get; set; }
        public List<NotifyAttach> attachs { get; set; }
    }
    public class NotifyTo : viewBaseInfo
    {
        public string sourceId { get; set; }
        public int to_count { get; set; }
    }

    public class SentNotifyGet
    {
        public Guid n_id { get; set; }
        public string subject { get; set; }
        public string description { get; set; }
        public string contentEdit { get; set; }
        public string contentView { get; set; }
        public bool isRead { get; set; }
        public string pushTimeAgo { get; set; }
        public string pushDate { get; set; }
        public int contentType { get; set; }
        public string external_event { get; set; }
        public string external_param { get; set; }
        public string refName { get; set; }
        public string refIcon { get; set; }
        public string notiAvatarUrl { get; set; }
    }
    public class NotifyParam
    {
        public Guid? n_id { get; set; }
        public Guid? tempId { get; set; }
    }

    public class NotifyToSet
    {
        public Guid? id { get; set; }
        public string to_level { get; set; }
        public string to_groups { get; set; }
        public string to_row { get; set; }
        public string to_type { get; set; }
    }
}

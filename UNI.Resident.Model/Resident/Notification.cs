using UNI.Resident.Model.Notification;
using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Resident
{
    //public class Notification
    //{
    //}
    //public class NotificationPage : viewBasePage<object>
    //{

    //}
    public class NotificationInfo : viewBaseInfo
    {
        //public long notiId { get; set; }
        public Guid? n_id { get; set; }
        public string external_sub { get; set; }
        public List<NotifyAttach> attachs { get; set; }
    }
    //public class NotifyAttach
    //{
    //    public long? id { get; set; }
    //    public long notiId { get; set; }
    //    public string attach_name { get; set; }
    //    public string attach_url { get; set; }
    //    public string attach_type { get; set; }
    //}
    //public class NotifyParam
    //{
    //    public Guid? n_id { get; set; }
    //    public Guid? tempId { get; set; }
    //    public string external_key { get; set; }
    //    public string external_sub { get; set; }
    //    public string external_name { get; set; }
    //    public string brand_name { get; set; }
    //    public string send_name { get; set; }
    //}
}

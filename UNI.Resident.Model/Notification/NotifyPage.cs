
using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;
using UNI.Model.APPM.Notifications;

namespace UNI.Resident.Model.Notification
{
    
    public class NotifyAttach
    {
        public Guid? n_id { get; set; }
        public string attach_name { get; set; }
        public string attach_url { get; set; }
        public string attach_type { get; set; }
        public int attach_size { get; set; }
    }

    public class NotifyTemp : viewBaseInfo
    {
        public Guid? id { get; set; }
        public string source_key { get; set; }
        public List<NotifyAttach> attachs { get; set; }
    }
    public class resNotifyInfoSet : viewBaseInfo
    {
        public bool sendNow;
        public Guid? n_id { get; set; }
        public string external_sub { get; set; }
        public int to_count { get; set; }
        public int? to_level { get; set; }
        public string to_groups { get; set; }
        public List<NotifyAttach> attachs { get; set; }
        //public List<viewGridFlex> gridflexs { get; set; }
        public List<NotifyToSet> notifyTos { get; set; }
        
    }
    public class resNotifyInfo : viewBaseInfo
    {
        public Guid? n_id { get; set; }
        public string external_sub { get; set; }
        public int to_count { get; set; }
        public int? to_level { get; set; }
        public string to_groups { get; set; }
        public List<NotifyAttach> attachs { get; set; }
        public List<viewGridFlex> gridflexs { get; set; }
        public List<NotifyToGet> notifyTos { get; set; }
    }
    public class NotifyTo : viewBaseInfo
    {
        public Guid? id { get; set; }
        public Guid? sourceId { get; set; }
        public int to_count { get; set; }
    }

}

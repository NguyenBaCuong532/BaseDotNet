using System;
using System.Collections.Generic;
using System.Web;
using UNI.Model;

namespace UNI.Resident.Model.Notification
{

    //public class resNotifyParam
    //{
    //    public Guid? n_id { get; set; }
    //    public Guid? tempId { get; set; }
    //    public string actions { get; set; }
    //    public int? to_level { get; set; }
    //    public string to_groups { get; set; }
    //    public string external_sub { get; set;}
    //}

    public class FilterInpNotifyTemp : FilterInputAppSt
    {
        public string source_key { get; set; }
    }
    public class FilterInpNotify : FilterInput
    {
        public string source_key { get; set; }
        public string external_sub { get; set; }
        public Guid? source_ref { get; set; }
        public int? isPublish { get; set; }
        public string actionlist { get; set; }
    }
    public class FilterInpNotifyPush : FilterInput
    {
        public Guid? n_id { get; set; }
        public int? sms_st { get; set; }
        public int? email_st { get; set; }
        public int? push_st { get; set; }
        public string action { get; set; }
    }
    public class FilterInpNotifyUser : FilterInput
    {
        public string byUser { get; set; }
    }
    public class FilterInpNotifyId : FilterInput
    {
        public Guid? n_id { get; set; }
    }
    public class FilterInpNotifySend : FilterInput
    {
        public string fromDate { get; set; }
        public string toDate { get; set; }
        public string source_key { get; set; }
        public void ucInputDt(string userid, string clientid, string language)
        {
            this.userId = userid;
            this.clientId = clientid;
            this.acceptLanguage = language;
            this.fromDate = HttpUtility.UrlDecode(this.fromDate);
            this.toDate = HttpUtility.UrlDecode(this.toDate);
        }
    }
}

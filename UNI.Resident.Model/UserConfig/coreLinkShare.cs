using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model.Core;

namespace UNI.Resident.Model.UserConfig
{
    //public class coreLinkShare
    //{
    //    public string link_code { get; set; }
    //    public string link_url { get; set; }
    //    public double rwd_rt { get; set; }
    //}
    //public class coreLinkClick
    //{
    //    public string link_code { get; set; }
    //    public string read_type { get; set; }
    //    public string read_id { get; set; }
    //    public string read_email { get; set; }
    //    public string read_first_name { get; set; }
    //    public string read_last_name { get; set; }
    //    public double rwd_rt { get; set; }
    //}
    //public class corePoint
    //{
    //    public string referralCd { get; set; }
    //    public decimal cur_bal_point { get; set; }
    //    public int last_dt { get; set; }
    //    public int u_rank { get; set; }
    //    public int gr_rank { get; set; }
    //}
    public class corePointTrans
    {
        public string ref_no { get; set; }
        public string tnx_no { get; set; }
        public string tnx_info { get; set; }
        public string remark { get; set; }
        public decimal Point { get; set; }
        public string dateAgo { get; set; }
        public int tnx_time { get; set; }
    }
    //public class coreUserPoint: corePoint
    //{
    //    public int stt { get; set; }
    //    public string user_info { get; set; }
    //}
    
    //public class coreLinkShareFollow : coreLinkShare
    //{
    //    public int stt { get; set; }
    //    public int click_count { get; set; }
    //}
    
    //public class chartLink
    //{
    //    public int countShare { get; set; }
    //    public int countClick { get; set; }
    //    public string valueDate { get; set; }
    //}
    //public class corePointLinkPage 
    //{
    //    public List<chartLink> chartLink { get; set; }
    //    public List<coreUserPoint> userPoint { get; set; }
    //    public List<coreLinkShareFollow> coreLinkShareFollow { get; set; }
    //}
}

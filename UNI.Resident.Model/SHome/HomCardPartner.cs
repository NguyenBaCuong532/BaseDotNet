using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    //public class HomCardPartnerPage : viewBasePage<HomCardPartnerGet>
    //{

    //}
    public class HomCardPartner
    {
        public int partner_id { get; set; }
        public string partner_cd { get; set; }
        public string partner_name { get; set; }
        public string projectCd { get; set; }
    }
    public class HomCardPartnerGet: HomCardPartner
    {
        public int countCard { get; set; }
        public int countVehicle { get; set; }
        public string create_dt { get; set; }
        public string create_by { get; set; }
        public string update_dt { get; set; }
        public string update_by { get; set; }
    }
}

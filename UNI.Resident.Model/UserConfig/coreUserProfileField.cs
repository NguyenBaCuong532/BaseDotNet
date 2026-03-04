using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;
using UNI.Model.Core;

namespace UNI.Resident.Model.UserConfig
{

    public class coreUserFields
    {
        public string loginName { get; set; }
        public List<viewField> fields { get; set; }
    }
    public class coreUserMetas
    {
        public string loginName { get; set; }
        public string meta_code { get; set; }
        public List<coreUserProfileMeta> Metas { get; set; }
    }

    //public class coreUserProfileMetas
    //{
    //    public string meta_key { get; set; }
    //    public string meta_code { get; set; }        
    //    public List<coreUserProfileMeta> Metas { get; set; }
    //}
    public class coreUserIdcardSet
    {
        public int idcard_type { get; set; }
        public string idcard_Issue_Dt { get; set; }
        public string idcard_No { get; set; }
        public string idcard_Issue_Plc { get; set; }
        public string idcard_Expire_Dt { get; set; }
        public string res_Cntry { get; set; }
        public string origin_add { get; set; }
    }
}

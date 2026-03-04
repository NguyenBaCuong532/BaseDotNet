using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model.UserConfig
{
    public class fbUserProfile
    {
        public string id { get; set; }
        public string email { get; set; }
        public string name { get; set; }
        public string gender { get; set; }
        public string birthday { get; set; }
        public string token { get; set; }
    }
    public class ggUserProfile
    {
        public string id { get; set; }
        public string email { get; set; }
        public string name { get; set; }
        public string given_name { get; set; }
        public string family_name { get; set; }
        public string gender { get; set; }
        public string locale { get; set; }
        public string picture { get; set; }
        public string link { get; set; }
    }
}

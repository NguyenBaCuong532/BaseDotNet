using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class BaseValidateForHrm
    {
        public bool valid { get; set; }
        public string messages { get; set; }
        public int work_st { get; set; }
        public bool notiQue { get; set; }
        public Guid? id { get; set; }
        public long regId { get; set; }
        public string code { get; set; }
        public int? cardIdForHrm { get; set; }
        public int? cardVehIdForHrm { get; set; }
    }
}

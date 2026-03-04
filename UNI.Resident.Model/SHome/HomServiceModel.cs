using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public enum emServiceType
    {
        Common,
        Vehicle,
        Service,
        Commerce
    }
    public class HomServiceModel
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public int ServiceTypeID { get; set; }
    }
    public class HomServiceExtend
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public int ServiceTypeID { get; set; }
        public int Amount { get; set; }
        public bool IsFree { get; set; }
    }
    
}

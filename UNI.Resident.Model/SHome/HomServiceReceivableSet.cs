using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomServiceReceivableSet
    {
        public string projectCd { get; set; }
        public List<long> receiveIds { get; set; }
    }
    public class HomServiceStopSet
    {
        public List<long> apartmentIds { get; set; }
    }
}

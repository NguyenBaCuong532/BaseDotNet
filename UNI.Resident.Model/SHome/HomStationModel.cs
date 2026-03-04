using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomStationReader
    {
        public int StationId { get; set; }
        public string StationCd { get; set; }
        public string StationName { get; set; }
        public string ServiceId { get; set; }
        public int Status { get; set; }
    }
}

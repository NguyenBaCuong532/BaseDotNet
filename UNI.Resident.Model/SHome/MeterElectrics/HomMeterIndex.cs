using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model.MeterElectrics
{
    public class HomMeterIndexPar
    {
        public string serialNumber { get; set; }
        public int type { get; set; }
        public int toDate { get; set; }
    }
    public class HomMeterIndexValue
    {
        public int time { get; set; }
        public double value { get; set; }
    }

    public class HomMeterIndexSet
    {
        public string serialNumber { get; set; }
        public int type { get; set; }
        public int fromDate { get; set; }
        public int toDate { get; set; }
        public double oldMetric { get; set; }
        public double newMetric { get; set; }
        public double consume { get; set; }
        public double estimate { get; set; }
    }
    public class HomMeterIndexResponse
    {
        public int code { get; set; }
        public string message { get; set; }
    }
}

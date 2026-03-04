using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class ElectricConsume
    {
        public string ProjectName { get; set; }
        public string roomCode { get; set; }
        public string SERIALNO { get; set; }
        public string ConsumeDate { get; set; }
        public double MeterValue { get; set; }
    }
    public class ElectricTakeConsume
    {
        public string ConsumeDate { get; set; }

    }
}

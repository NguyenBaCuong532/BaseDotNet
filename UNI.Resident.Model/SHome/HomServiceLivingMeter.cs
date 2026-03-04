using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomServiceLivingPage : viewBasePage<HomServiceLivingMeter>
    {

    }
    public class HomServiceLivingMeter
    {
        public long TrackingId { get; set; }
        public long LivingId { get; set; }
        public int ApartmentId { get; set; }
        public string MeterSerial { get; set; }
        public int LivingTypeId { get; set; }
        public string LivingTypeName { get; set; }
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public int PeriodMonth { get; set; }
        public int PeriodYear { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public int FromNum { get; set; }
        public int ToNum { get; set; }
        public int TotalNum { get; set; }
        public string InputType { get; set; }
        public int InputId { get; set; }
        public bool IsCalculate { get; set; }
        public long Amount { get; set; }
        //public bool IsBill { get; set; }
        public bool IsReceivable { get; set; }

    }
}

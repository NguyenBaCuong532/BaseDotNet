using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomServiceLivingSet
    {
        public long LivingId { get; set;}
        public long ApartmentId { get; set; }
        public int LivingType { get; set; }
        public string ContractNo { get; set; }
        public string ContractDate { get; set; }
        public string MeterSerial { get; set; }
        public long MeterNumber { get; set; }
        public string StartDate { get; set; }
        public string EmployeeCd { get; set; }
        public string DeliverName { get; set; }
        public string CustId { get; set; }
        public string CustName { get; set; }
        public string CustPhone { get; set; }
        public string Note { get; set; }
        public string ProviderCd { get; set; }
        public int NumPersonWater { get; set; } 
    }
    public class HomServiceLivingGet: HomServiceLivingSet
    {
        public string AccrualLast { get; set; }
        public string PayedLast { get; set; }
        public string ProviderName { get; set; }
    }
    public class HomLivingType
    {
        public int LivingTypeId { get; set; }
        public string LivingTypeName { get; set; }
    }

    
    public class HomServiceLivingMeterValue
    {
        public long TrackingId { get; set; }
        public long LivingId { get; set; }
        public string MeterSerial { get; set; }
        public string FromDate { get; set; }
        public int FromNum { get; set; }
        public string ToDate { get; set; }
        public int ToNum { get; set; }
        public int TotalNum { get; set; }
    }
    public class HomServiceLivingMeterCalc
    {
        public long TrackingId { get; set; }
    }
    public class HomServiceLivingMeterCalcs
    {
        public long TrackingId { get; set; }
        public int LivingType { get; set; }
        public int PeriodMonth { get; set; }
        public int PeriodYear { get; set; }
        public string projectCd { get; set; }
    }
}

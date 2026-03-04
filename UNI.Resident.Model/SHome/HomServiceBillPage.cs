using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomServiceBillPage : viewBasePage <HomServiceBillInfo>
    {
    }
    public class HomServiceBillInfo
    {
        public long ReceiveId { get; set; }
        public string PeriodMonth { get; set; }
        public string PeriodYear { get; set; }
        public string ReceivableDate { get; set; }
        public decimal TotalAmt { get; set; }
        public string ExpireDate { get; set; }
        public string fromDate { get; set; }
        public string toDate { get; set; }
        public bool IsPayed { get; set; }
        public string StatusPayed { get; set; }
        public string Remark { get; set; }
        public decimal PaidAmt { get; set; }
        public string RoomCode { get; set; }
        public string ProjectCd { get; set; }
        //public long CommonFee { get; set; }
        //public long VehicleAmt { get; set; }
        //public long LivingAmt { get; set; }
        //public long ExtendAmt { get; set; }
    }
}

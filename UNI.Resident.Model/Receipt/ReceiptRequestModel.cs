using System;
using UNI.Model;

namespace UNI.Resident.Model.Receipt
{
    public class ReceiptRequestModel : FilterBase
    {
        public string ProjectCd { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public bool? isDateFilter { get; set; }
        public int isExpected { get; set; }
        public int isResident { get; set; }
        public Guid? PeriodsOid { get; set; }
        public ReceiptRequestModel(string clientid, string userid, int? offset, int? pagesize, string filter, string ProjectCd,
             int isexpected, int isresident, bool isdateFilter, string fromdate, string todate) : base(clientid, userid, offset, pagesize, filter)
        {
            this.ProjectCd = ProjectCd;
            isExpected = isexpected;
            isResident = isresident;
            isDateFilter = isdateFilter;
            FromDate = fromdate;
            ToDate = todate;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.Model.Invoice
{
    
    public class InvoiceRequestModel : FilterBase
    {
        public int apartmentId { get; set; }
    }
    public class ServiceBill
    {
        public long ReceiveId { get; set; }
        public string BillUrl { get; set; }
        public string BillViewUrl { get; set; }
        public bool overwrite { get; set; }
    }
    //public class ServiceReceivableSet
    //{
    //    public string projectCd { get; set; }
    //    public List<long> receiveIds { get; set; }
    //}
}

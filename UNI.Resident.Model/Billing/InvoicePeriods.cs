using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Billing
{
    public class InvoicePeriodsFilter : FilterBase
    {
        public string from_month { get; set; }
        
        public string to_month { get; set; }
    }
}
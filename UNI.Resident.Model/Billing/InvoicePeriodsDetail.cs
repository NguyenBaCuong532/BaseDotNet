using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Billing
{
    public class InvoicePeriodsDetailFilter : FilterBase
    {
        public Guid InvoicePeriodOid { get; set; }
    }
}
using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Billing
{
    public class BillingPeriodsFilter : FilterBase
    {
        public string reference_date { get; set; }

        public int? status { get; set; }
    }

    public class BillingPeriods_SetLocked
    {
        public Guid Oid { get; set; }

        public bool Locked { get; set; }
    }
}
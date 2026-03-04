using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Billing
{
    public class RevenuePeriodsFilter : FilterBase
    {
        public string from_month { get; set; }

        public string to_month { get; set; }
    }
    public class RevenuePeriodsSetLocked
    {
        public Guid Oid { get; set; }

        public bool SetUnlocked { get; set; }
    }
}
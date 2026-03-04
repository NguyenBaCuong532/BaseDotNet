using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;

namespace UNI.Resident.Model.Billing
{
    public class BillingPeriodsElectricImport
    {
        public IFormFile File { get; set; }

        public Guid PeriodsOid { get; set; }
    }
}
using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.ServicePrice
{
    public class ServicePriceWaterDetailFilter : FilterBase
    {
        public Guid WaterOid { get; set; }
        public Guid? par_service_price_type_oid { get; set; }
    }
}
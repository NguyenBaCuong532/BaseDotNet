using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.ServicePrice
{
    public class ServicePriceVehicleDetailFilter : FilterBase
    {
        public Guid VehicleOid { get; set; }
        public Guid? par_vehicle_type_oid { get; set; }
    }
}
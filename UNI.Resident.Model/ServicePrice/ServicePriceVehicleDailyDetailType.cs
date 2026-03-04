using System;
using UNI.Model;

namespace UNI.Resident.Model.ServicePrice
{
    public class ServicePriceVehicleDailyDetailTypeFilter : FilterBase
    {
        public Guid VehicleDailyOid { get; set; }
        
        public Guid? par_vehicle_daily_type_oid { get; set; }
    }
}
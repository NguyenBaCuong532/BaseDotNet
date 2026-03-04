using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomVehiclePaySet
    {
        public long VehiclePayId { get; set; }
        public long CardVehicleId { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
        public int VehNum { get; set; }
        public decimal Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Amount { get; set; }
        public string CustomerName { get; set; }
        public string Remart { get; set; }
    }
}

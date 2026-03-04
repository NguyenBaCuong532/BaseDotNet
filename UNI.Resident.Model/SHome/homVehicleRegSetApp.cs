using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class homVehicleRegSetApp
    {
        public int? CardVehicleId { get; set; }
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public string VehicleName { get; set; }
        public string VehicleColor { get; set; }
        public int VehicleTypeId { get; set; }
        public string Note { get; set; }
        public string userId { get; set; }
        public List<homVehicleImage> ImageLinks { get; set; }
    }
    public class homVehicleImage
    {
        public int? Id { get; set; }
        public int? CardVehicleId { get; set; }
        public string Type { get; set; }
        public string Url { get; set; }
    }
}

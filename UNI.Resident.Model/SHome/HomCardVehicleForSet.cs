using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomCardVehicleForSet : viewBaseInfo
    {
        public long? id { get; set; }
        public Guid? gd { get; set; }
        public string cd { get; set; }
        public List<HomVehicleImage> ImageVehicle { get; set; }
    }
    public class HomVehicleImage
    {
        public int? Id { get; set; }
        public int? CardVehicleId { get; set; }
        public string Type { get; set; }
        public string Url { get; set; }
    }
}

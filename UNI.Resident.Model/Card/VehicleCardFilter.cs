using System;
namespace UNI.Resident.Model.Card
{
    public class VehicleCardFilter : CardGuestFilter
    {
        public int? VehicleTypeId { get; set; }
        public bool IsDateFilter { get; set; }
        public DateTime? EndDate { get; set; }
    }
}

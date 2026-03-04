using UNI.Resident.Model.Common;
using System.Text.Json.Serialization;

namespace UNI.Resident.Model.Card
{
    public class CardGuestFilter : GridProjectFilter
    {
        [JsonPropertyName("partner_id")]
        public int? PartnerId { get; set; }
        public int? Status { get; set; }
    }
    public class VehicleGuestFilter : GridProjectFilter
    {
        [JsonPropertyName("partner_id")]
        public int? PartnerId { get; set; }
        public int? Status { get; set; }
        public string EndDate { get; set; }
        public int? VehicleTypeId { get; set; }
        public int? IsFilterDate { get; set; }
    }
}

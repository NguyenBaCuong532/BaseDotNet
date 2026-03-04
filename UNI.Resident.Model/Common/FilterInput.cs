using UNI.Model;

namespace UNI.Resident.Model.Common
{
    public class FilterInputProject : FilterInput
    {
        public string projectCd { get; set; }
    }
    public class FilterInputBuilding : FilterInputProject
    {
        public string buildingCd { get; set; }
    }
    public class FilterTransInput : FilterInput
    {
        public int ApartmentId { get; set; }
        public string RoomCode { get; set; }
        public string fromDt { get; set; }
        public string toDt { get; set; }
        public string projectCd { get; set; }
        public int? trans_type { get; set; }
        public int? trans_st { get; set; }
    }
}

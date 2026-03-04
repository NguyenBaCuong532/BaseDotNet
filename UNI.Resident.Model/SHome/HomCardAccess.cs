using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomCardAccess
    {
        public string card_code { get; set; }
        public int card_type { get; set; }
        public string reader_id { get; set; }
        public bool open_gate { get; set; }
        public string hardware_id { get; set; }
        public int elevator_bank { get; set; }
        public int elevator_shaft_number { get; set; }
        public string elevator_shaft_name { get; set; }
        public List<HomCardFloor> accessible_floor_numbers { get; set; }
    }
    public class HomCardFloor
    {
        public int FloorNum { get; set; }
        public string FloorName { get; set; }
    }
    public class HomAccessFloor
    {
        public string FloorName { get; set; }
        public string id { get; set; }
    }
    public class HomAccessGet
    {
        public string token { get; set; }
        public List<HomAccessFloorLast> floor_lasts { get; set; }
    }
    public class HomAccessFloorLast
    {
        public int FloorNum { get; set; }
        public string FloorName { get; set; }
        public string projectCd { get; set; }
        public string buildingName { get; set; }
        public string projectName { get; set; }
        public bool isLastest { get; set; }
    }
}

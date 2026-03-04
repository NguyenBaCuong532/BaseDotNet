using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class resReportConfig
    {
        public string tableKey { get; set; }
        public string groupKey { get; set; }
        public string int_order { get; set; }
        public string report_type { get; set; }
        public string roomCode { get; set; }
        public string report_group { get; set; }
        public string report_name { get; set; }
        public string api_url_view { get; set; }
        public string api_url_dowload { get; set; }
        public List<viewGroup> group_fields { get; set; }
    }
    public class resBuildingConfig
    {
        public int value { get; set; }     /* public int id { get; set; } */ 
        public string BuildingCd { get; set; }
        public string name { get; set; }    /*public string BuildingName { get; set; } */
        public string ProjectName { get; set; }
        public string roomCode { get; set; }
    }

    public class resRoomConfig
    {
        public string value { get; set; }     /* roomCode */
        public string name { get; set; }  /* BuildingCd*/
    }

    public class ProjectBuildingRoom
    {

        public string ProjectCd { get; set; }    
        public string BuildingCd { get; set; }
        public string ProjectName { get; set; }
        public string BuildingName { get; set; }
        public string roomCode { get; set; }
    }
}

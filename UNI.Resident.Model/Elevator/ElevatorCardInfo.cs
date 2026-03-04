using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.Model.Elevator
{
    public class ElevatorCardInfo : viewBaseInfo
    {
        public string cardCd { get; set; }
        public int cardId { get; set; }
        public string projectCd { get; set; }
    }
    public class BuildAreaInfo : viewBaseInfo
    {
        public string projectCd { get; set; }
        public string buildingCd { get; set; }
        public string areaCd { get; set; }
        public int id { get; set; }

    }
}

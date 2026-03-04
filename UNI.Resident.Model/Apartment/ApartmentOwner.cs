using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.Model.Apartment
{
    public class ApartmentOwner
    {
        public bool isOwner { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public List<PrjoectCdRoomCode> ApartmentList { get; set; } = new List<PrjoectCdRoomCode>();
    }

    public class PrjoectCdRoomCode
    {
        public string projectCd { get; set; }
        public string RoomCode { get; set; }
    }
}

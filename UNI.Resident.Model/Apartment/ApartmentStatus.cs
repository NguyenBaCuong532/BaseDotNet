using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.Model.Apartment
{
    public class ApartmentStatus
    {
        public Guid apartId { get; set; }
        public string fullName { get; set; }
        public string code { get; set; }
        public string avatarUrl { get; set; }
        public string apartStatus { get; set; }
        public DateTime? created { get; set; }
        public DateTime? updated { get; set; }
    }
}

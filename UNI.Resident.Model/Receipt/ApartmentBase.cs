using System.Collections.Generic;

namespace UNI.Resident.Model.Receipt
{
    public class ApartmentsDto
    {
        public string projectCd { get; set; }
        public List<long> ApartmentIds { get; set; }
    }
}

using System.Collections.Generic;

namespace UNI.Resident.Model.Request
{
    public class RequestAssign
    {
        public int RequestId { get; set; }
        public List<UserAssignType> Assigns { get; set; }
    }
}

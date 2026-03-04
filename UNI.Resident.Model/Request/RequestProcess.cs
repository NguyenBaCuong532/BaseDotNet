using System.Collections.Generic;

namespace UNI.Resident.Model.Request
{
    public class RequestProcess
    {
        public long RequestId { get; set; }
        public string Comment { get; set; }
        public int Status { get; set; }
        public List<RequestAttachment> Attachments { get; set; }
    }

    public class RequestProcessGet : RequestProcess
    {
        public long ProcessId { get; set; }
        public string ProcessDate { get; set; }
        public string UserName { get; set; }
        public string StatusName { get; set; }
    }
}

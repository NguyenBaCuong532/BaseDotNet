using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.Model.Request
{
    public class RequestAssignmentTabInfo
    {
        public RequestAssignmentHeader Header { get; set; } = new RequestAssignmentHeader();
        public List<RequestAssignmentAssigneeGroup> Assignees { get; set; }
    = new List<RequestAssignmentAssigneeGroup>();

        public List<RequestAssignmentProcessLog> Processes { get; set; } = new List<RequestAssignmentProcessLog>();
        public List<RequestAssignmentStatusItem> Statuses { get; set; } = new List<RequestAssignmentStatusItem>();
    }

    public class RequestAssignmentHeader
    {
        public int requestId { get; set; }

        public int currentStatus { get; set; }
        public string currentStatusName { get; set; }

        public string currentAssigneeUserId { get; set; }
        public bool hasAssignee { get; set; }
        public bool isAssignee { get; set; }
        public bool canClaim { get; set; }
        public bool canChangeAssignee { get; set; }
    }


    public class RequestAssignmentAssignee
    {
        public int Id { get; set; }
        public int requestId { get; set; }
        public string userId { get; set; }
        public int assignRole { get; set; }
        public string userName { get; set; }
        public string fullName { get; set; }
        public string avatarUrl { get; set; }
        public string phone { get; set; }
        public string email { get; set; }
        public string assignRoleName { get; set; }
        public int used { get; set; }
    }

    public class RequestAssignmentProcessLog
    {
        public int ProcessId { get; set; }
        public int requestId { get; set; }
        public string userId { get; set; }
        public string userName { get; set; }
        public string fullName { get; set; }
        public string avatarUrl { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public string Comment { get; set; }
        public DateTime? ProcessDt { get; set; }
        public string processDate { get; set; }
        public bool isOwn { get; set; }
    }

    public class RequestAssignmentStatusItem
    {
        public int StatusId { get; set; }
        public string StatusName { get; set; }
    }
    public class RequestAssignmentAssigneeGroup
    {
        public int assignRole { get; set; }
        public string assignRoleName { get; set; } = "";
        public List<RequestAssignmentAssignee> users { get; set; }
            = new List<RequestAssignmentAssignee>();
    }
}

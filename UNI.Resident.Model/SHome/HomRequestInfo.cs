
using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;
namespace UNI.Resident.Model
{
    public class HomRequestBase
    {
        public long requestId { get; set; }
        public string Comment { get; set; }
        public int Status { get; set; }
    }
    public class HomRequestInfo : viewBaseInfo
    {
        public long requestId { get; set; }
        public int Status { get; set; }
        public bool IsFinished { get; set; }
        public string thread_id { get; set; }
        public List<HomRequestAttach> attachs { get; set; }
        //public List<crmBaseAssignGet> assigns { get; set; }
    }
    public class HomRequestSet : HomRequestBase
    {
        public long ApartmentId { get; set; }
        public int RequestTypeId { get; set; }
        public bool IsNow { get; set; }
        public string AtTime { get; set; }
        public string thread_id { get; set; }
        public List<HomRequestAttach> attachs { get; set; }
    }
    public class HomRequest: HomRequestSet
    {
        public string RequestTypeName { get; set; }
        public string RequestDate { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool IsFinished { get; set; }
        public List<HomRequestProcessGet> Processes { get; set; }
        public HomRequestVote vote { get; set; }
    }
    public class HomRequestVote: HomRequestBase
    {
        public int rating { get; set; }
        public string review_date { get; set; }
        public List<HomRequestAttach> attachs { get; set; }
    }

}

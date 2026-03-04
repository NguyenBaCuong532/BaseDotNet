using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class FeedbackGet
    {
        public int FeedbackId { get; set; }
        public string ProjectName { get; set; }
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string FeedbackTypeName { get; set; }
        public string Title { get; set; }
        public string Comment { get; set; }
        public string FeedbackDate { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
    }
    public class FeedbackFull : FeedbackGet
    {
        public List<FeedbackProcessGet> Processes { get; set; }
        public List<HomRequestAttach> attachs { get; set; }
    }
    public class FeedbackPage 
    {
        public long? RecordsTotal { get; set; }
        public long? RecordsFiltered { get; set; }
        public List<FeedbackGet> Feedbacks { get; set; }        
    }
    public class FeedbackProcess
    {
        public int FeedbackId { get; set; }
        public string Comment { get; set; }
        public int Status { get; set; }
    }
    public class FeedbackProcessGet : FeedbackProcess
    {
        public int ProcessId { get; set; }
        public string ProcessDate { get; set; }
        public string EmployeeName { get; set; }
        public string StatusName { get; set; }
    }
}

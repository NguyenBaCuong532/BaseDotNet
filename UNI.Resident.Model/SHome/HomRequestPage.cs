using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomRequestPage : viewBasePage<HomRequestList>
    {
    }
    public class HomRequestList
    {
        public int ApartmentId { get; set; }
        public int RequestId { get; set; }
        public int RequestTypeId { get; set; }
        public string Comment { get; set; }
        public string BrokenUrl1 { get; set; }
        public bool IsNow { get; set; }
        public string AtTime { get; set; }
        public string RequestTypeName { get; set; }
        public string RequestDate { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool IsFinished { get; set; }
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string UserLogin { get; set; }
        public string UserId { get; set; }
    }

}

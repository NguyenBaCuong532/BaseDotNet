using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomRequestSevSet
    {
        public int ApartmentId { get; set; }
        public int RequestId { get; set; }
        public string Comment { get; set; }
        public int RequestTypeId { get; set; }
        public bool IsNow { get; set; }
        public string AtTime { get; set; }
    }
    public class HomRequestSev : HomRequestSevSet
    {
        public string RequestTypeName { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public string RequestDate { get; set; }
        public string RequestKey { get; set; }
        public List<HomRequestProcessGet> Processes { get; set; }
    }
    public class HomRequestSevGet : HomRequestSev
    {
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string UserLogin { get; set; }
    }

    public class HomRequestService: Countable
    {
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string FullName { get; set; }
        public string RequestKey { get; set; }
        public int RequestId { get; set; }
        public string RoomCode { get; set; }
        public string cardCd { get; set; }
        public string TypeName { get; set; }
        public string RequestTypeName { get; set; }
        public int TypeId { get; set; }
        public string RequestDate { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public string Comment { get; set; }
        public string UserLogin { get; set; }
    }

    public class HomRequestServiceGet
    {
        public HomRequestFixGet RequestFix { get; set; }
        public HomRequestSevGet RequestSev { get; set; }
        public HomRequestCardReg CardRegister { get; set; }
        public HomRequestCardReg CardVehicle { get; set; }
        public HomRequestCardLost CardLost { get; set; }
    }
    public class FilterRequestService : FilterBaseManger
    {
        public string RequestKey { get; set; }
        public bool IsCardReq { get; set; }
        public FilterRequestService(string clientid, string userid, int? offset, int? pagesize,
            string projectcd, string roomcd, string requestkey, string statuses, bool isCardReq, string filter, int gridwidth) : base(clientid, userid, offset, pagesize, projectcd, roomcd, statuses, filter, gridwidth, 0)
        {
            this.RequestKey = requestkey;
            this.IsCardReq = isCardReq;
        }
    }
    public class ServiceRequestedSum
    {
        public int newRequestedNum { get; set; }
        public int reviewedNum { get; set; }
        public int wipNum { get; set; }
        public int doneNum { get; set; }
    }
    public class ServiceRequestedProject : ServiceRequestedSum
    {
        public string projectCd { get; set; }
        public string projectName { get; set; }
        public string color { get; set; }
    }

    public class ProjectInfoX
    {
        public string projectCd { get; set; }
        public string projectName { get; set; }
        public string color { get; set; }
    }
    public class ServiceRequestedView
    {
        public List<ServiceRequestedProject> ServiceRequestedProjects { get; set; }
        public List<ProjectInfoX> ProjectInfoList { get; set; }
        public List<HomRequestService> SaleRevenueProjectDetailsList { get; set; }
    }
}

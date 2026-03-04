using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomRequestFixSet
    {
        public long ApartmentId { get; set; }
        public long RequestId { get; set; }
        public int RequestTypeId { get; set; }
        public string Comment { get; set; }
        public string BrokenUrl1 { get; set; }
        public string BrokenUrl2 { get; set; }
        public string BrokenUrl3 { get; set; }
        public bool IsNow { get; set; }
        public string AtTime { get; set; }
    }
    public class HomRequestFix : HomRequestFixSet
    {
        public string RequestTypeName { get; set; }
        public string RequestDate { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool IsFinished { get; set; }
        public int rating { get; set; }
        public List<HomRequestProcessGet> Processes { get; set; }
    }
    public class HomRequestFixGet : HomRequestFix
    {
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string UserLogin { get; set; }
        public List<HomRequestEmployee> Employees { get; set; }
    }
    public class HomRequestEmployee
    {
        public string CustId { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string AvatarUrl { get; set; }
        public int IsSex { get; set; }
        public string Birthday { get; set; }
        public string PassNo { get; set; }
        public string PassDate { get; set; }
        public string PassPlace { get; set; }
        public string Address { get; set; }
        public string ProvinceCd { get; set; }
        public bool IsForeign { get; set; }
        public string CountryCd { get; set; }
        public string EmployeeId { get; set; }
        public string UserId { get; set; }
        public string Organization { get; set; }
        public string Position { get; set; }
        public string WorkDate { get; set; }
        public string ProjectCd { get; set; }
        public bool IsUser { get; set; }
        public string DepartmentCd { get; set; }
        public string Extent { get; set; }
        public string OrganizationCd { get; set; }
        public long RequestId { get; set; }
        public string UserLogin { get; set; }
        public string code { get; set; }
        public string EmployeeName { get { return this.FullName; } }
        public string SexName { get; set; }
        public bool IsLock { get; set; }
        public string LockName { get; set; }
        public string DepartmentName { get; set; }
        //public List<EmpGroup> Groups { get; set; }
        public bool IsFaced { get; set; }
        public bool IsProfileFull { get; set; }
        public bool IsApproved { get; set; }
        public bool IsContacted { get; set; }
        public bool IsCard { get; set; }
        public bool IsVehicle { get; set; }
        public int VehicleCount { get; set; }

    }

    public class HomRequestProcess
    {
        public long RequestId { get; set; }
        public string Comment { get; set; }
        public int Status { get; set; }
        public List<HomRequestAttach> attachs { get; set; }
    }
    public class HomRequestProcessGet : HomRequestProcess
    {
        public long processId { get; set; }
        public string ProcessDate { get; set; }
        public string UserName { get; set; }
        public string StatusName { get; set; }
    }
    public class HomRequestSevicePrice
    {
        public string RequestTypeName { get; set; }
        public string PriceDate { get; set; }
        public string Contents { get; set; }
    }
    public class HomRequestTypePrice
    {
        public int RequestTypeId { get; set; }
        public string RequestTypeName { get; set; }
        public List<HomRequestSevicePriceItem> PriceItem { get; set; }
    }

    public class RequestTypeUpdate
    {
        public int RequestTypeId { get; set; }
        public string RequestTypeName { get; set; }
        public int requestCategoryId { get; set; }
        public string category { get; set; }
        public int isFree { get; set; }
        public int price { get; set; }
        public string unit { get; set; }
        public string note { get; set; }
        public string typeName { get; set; }
        public int isReady { get; set; }
        public string iconUrl { get; set; }
        public string sub_prod_cd { get; set; }
        public string chat_cd { get; set; }
    }
    public class HomRequestSevicePriceItem
    {
        public int PriceId { get; set; }
        public int RequestTypeId { get; set; }
        public string ItemName { get; set; }
        public bool IsFree { get; set; }

        public int Price { get; set; }
        public string Unit { get; set; }
        public string Note { get; set; }
    }
    public class RequestSeviceItemUpdate: HomRequestSevicePriceItem
    {
        public int? isUsed { get; set; }
        public int Post { get; set; }
    }

}

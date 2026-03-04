using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Resident
{
    //public class Request
    //{
    //}
    // Căn hộ/Yêu cầu từ căn hộ
    //public class ApartmentRequestPage : viewBasePage<object>
    //{

    //}
    public class ApartmentRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; }
    }
    // Xử lý yêu cầu/ Yêu cầu
    //public class RequestPage : viewBasePage<object>
    //{

    //}
    public class RequestModel : FilterBase
    {
        public string ProjectCd { get; set; }
        public int Status { get; set; }
        public int IsNow { get; set; }
        public string fromDate { get; set; }
        public string toDate { get; set; }
    }

    /// <summary>
    /// Request model cho API GetCleaningServiceInfo
    /// </summary>
    public class CleaningServiceInfoRequest
    {
        public string requestId { get; set; }
    }
    // Thông tin chung
    public class RequestInfo : viewBaseInfo
    {
        public int? RequestId { get; set; }
        public int Status { get; set; }
        public bool IsFinished { get; set; }
        public string thread_id { get; set; }
        public List<RequestAttach> attachs { get; set; }
        public List<BaseAssignGet> assigns { get; set; }
    }
    public class RequestAttach
    {
        public long id { get; set; }
        public long requestId { get; set; }
        public long processId { get; set; }
        public string attachUrl { get; set; }
        public string attachType { get; set; }
        public string attachFileName { get; set; }
        public bool used { get; set; }
    }
    public class BaseAssignGet
    {
        public string assignRoleName { get; set; }
        public int assignRole { get; set; }
        public List<BaseUserGet> Users { get; set; }
    }
    public class BaseUserGet
    {
        public long id { get; set; }
        public string userName { get; set; }
        public string fullName { get; set; }
        public string avatarUrl { get; set; }
        public string phone { get; set; }
        public string email { get; set; }
        public string userId { get; set; }
        public int assignRole { get; set; }
        public bool used { get; set; }
    }
}

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using UNI.Model;

namespace UNI.Resident.Model.Resident
{
    
    // Căn hộ
    //public class Apartment
    //{
    //}
    //public class ApartmentPage : viewBasePage<object>
    //{

    //}
    public class ApartmentRequestModel1: FilterBase
    {
        public string ProjectCd { get; set; }
        public string buildingCd { get; set; }
        public string Receive { get; set; }
        //public string RoomCd { get; set; }
        public string Rent { get; set; }
        public int Debt { get; set; }
        public int setupStatus { get; set; }
        //public ApartmentRequestModel1(string clientid, string userid, int? offset, int? pagesize,
        //    string projectcd, string roomcd, string buildingcd, string receive, string rent, int debt, int setupstatus) 
        //    : base(clientid, userid, offset, pagesize,"",0)
        //{
        //    this.buildingCd = buildingcd;
        //    //this.RoomCd = roomcd;
        //    this.Receive = receive;
        //    this.Rent = rent;
        //    this.Debt = debt;
        //    this.setupStatus = setupstatus;
        //}
    }
    public class ApartmentInfo : viewBaseInfo
    {
        public string ApartmentId { get; set; }//ID căn hộ
        public string roomCode { get; set; }//Mã căn hộ
        public string IsReceived { get; set; }// Trạng thái bàn giao
        public string ReceivedStatus { get; set; }// Tên trạng thái bàn giao
        public Guid? apartOid { get; set; }
    }
    
    // Thành viên trong căn hộ
    //public class FamilyMemberPage : viewBasePage<object>
    //{

    //}
    public class FamilyMemberRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? Oid { get; set; } // Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
        public string MemberType { get; set; } // 'All', 'Current', 'Old' - Mặc định: 'Current'
    }
    public class MemberHistoryRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? Oid { get; set; } // Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
        public string CustId { get; set; }
        public string filter { get; set; }
    }
    public class FamilyMemberChangeHostInfo : viewBaseInfo
    {
        public Guid? Id { get; set; }
    }
    public class FamilyMemberInfo : viewBaseInfo
    {
        public Guid? Id { get; set; } // Oid của MAS_Apartment_Member (GUID)
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? apartOid { get; set; } // Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
    }

    /// <summary>
    /// Request/response dùng cho merge
    /// </summary>
    public class MergeMemberInfo : viewBaseInfo
    {
        public int ApartmentId { get; set; }
        public string CustId { get; set; } 
        public string CustId1 { get; set; } 
        public List<MergeMemberItem> dataList { get; set; }
        public List<MergeMemberFieldItem> arrObj { get; set; } 
        public List<viewGridFlex> gridflexs { get; set; } 
    }

    public class MergeMemberItem
    {
        public string fieldName { get; set; }
        public string name { get; set; }
        public bool? value { get; set; }
        public string name1 { get; set; }
        public bool? value1 { get; set; }
        public string result { get; set; }
        public string custId { get; set; }
    }

    /// <summary>
    /// Model cho table type MergeMemberField - có 3 trường: fieldName, result, custId
    /// </summary>
    public class MergeMemberFieldItem
    {
        public string fieldName { get; set; }
        public string result { get; set; }
        public string custId { get; set; }
    }

    /// <summary>
    /// Request model cho API GetMergeMemberInfo
    /// </summary>
    public class GetMergeMemberInfoRequest : FilterBase
    {
        public int ApartmentId { get; set; }
        
        public string CustIds { get; set; } // Danh sách CustId cách nhau bởi dấu phẩy
    }

    /// <summary>
    /// Response model cho API GetMergeMemberInfo - trả về tối đa 2 thành viên
    /// </summary>
 
    public class FamilyMemberLeaveBulkRequest
    {
        public int ApartmentId { get; set; }
        public string[] CustIds { get; set; }
        public string ActionDate { get; set; } // dd/MM/yyyy or null
        public string Note { get; set; }
    }


    // Hộ khẩu
    //public class HouseholdPage : viewBasePage<object>
    //{

    //}
    public class HouseholdRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? Oid { get; set; } // Ưu tiên sử dụng (GUID) của MAS_Apartments
    }
    public class HouseholdRequestModel1 : FilterBase
    {
        public string projectCd { get; set; }
        public string buildingCd { get; set; }
    }
    public class HouseholdInfo : viewBaseInfo
    {
        public Guid? Id { get; set; } // Oid của MAS_Customer_Household (GUID)
        public string CustId { get; set; }
        public string UserID { get; set; }
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? apartOid { get; set; } // Oid của MAS_Apartments
        //public int IsResident { get; set; }
        //public string ResAdd1 { get; set; }
        //public string ContactAdd1 { get; set; }
        //public string PassNo { get; set; }
        //public string PassDate { get; set; }
        //public string PassPlace { get; set; }
        //public int ApartmentId { get; set; }
    }

    // Thông báo app
    //public class SentNotifyHistoryPage : viewBasePage<object>
    //{

    //}
    public class SentNotifyHistoryRequestModel : FilterBase
    {
        public string RoomCode { get; set; }
    }
    // Thông báo email
    //public class SentEmailHistoryPage : viewBasePage<object>
    //{

    //}
    public class SentEmailHistoryRequestModel : FilterBase
    {
        public int ApartmentId { get; set; }
    }
    // Thông báo tin nhắn
    //public class SentSmsHistoryPage : viewBasePage<object>
    //{

    //}
    public class SentSmsHistoryRequestModel : FilterBase
    {
        public int ApartmentId { get; set; }
    }

    public class ApartmentViolationHistoryInfo : viewBaseInfo
    {
        public int ApartmentId { get; set; } // Backward compatible
        public Guid? apartOid { get; set; } // Ưu tiên sử dụng (GUID)
        public Guid? Id { set; get; } // UNIQUEIDENTIFIER trong database
    }

    public class ApartmentViolationHistoryRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? Oid { get; set; } // Ưu tiên sử dụng (GUID)
    }

    public class ApartmentProfileInfo : viewBaseInfo
    {
        public int ApartmentId { get; set; } // Backward compatible
        public Guid? apartOid { get; set; } // Ưu tiên sử dụng (GUID)
        public string Id { set; get; }
    }

    public class ApartmentProfileRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; } // Backward compatible
        public Guid? Oid { get; set; } // Ưu tiên sử dụng (GUID)
    }

}

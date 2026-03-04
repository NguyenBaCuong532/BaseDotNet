using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomMemberBase
    {
        public string userId { get; set; }
        public string custId { get; set; }
        public long apartmentId { get; set; }
    }
    public class HomFamilyProfile
    {
        public bool IsReceived { get; set; }
        public string ReceiveDate { get; set; }
        public bool Sex { get; set; }
        public int IsRent { get; set; }
        public int ApartmentId { get; set; }
        public string RoomCode { get; set; }
        public string RoomCodeView { get; set; }
        public string BuildingCd { get; set; }
        public string ProjectCd { get; set; }
        public int CardCount { get; set; }
        public int MemberCount { get; set; }
        public int vehicleCount { get; set; }
        public string FullName { get; set; }
        public string isMain { get; set; }
        public int IsApprove { get; set; }
        public string ProjectName { get; set; }
        public Guid? UserId { get; set; }
        public string UserLogin { get; set; }
        public string AvatarUrl { get; set; }
        public string CifNo { get; set; }
        public string FamilyImageUrl { get; set; }
        public int Floor { get; set; }
        public string BuildingName { get; set; }
        public string CustId { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string projectHotline { get; set; }
        public decimal currBal { get; set; }
        public decimal currPoint { get; set; }
    }
    //public class HomFamilySet
    //{
    //    public int ApartmentId { get; set; }
    //    public string UserId { get; set; }
    //    public string UserLogin { get; set; }
    //    public string UserPassword { get; set; }
    //    public string FamilyImageUrl { get; set; }
    //}
    //public class HomApartmentProfile
    //{
    //    public int ApartmentId { get; set; }
    //    public string ProjectCd { get; set; }
    //    public string ProjectName { get; set; }
    //    public string RoomCode { get; set; }
    //}
    
    public class HomApartmentMemberSet 
    {
        public int ApartmentId { get; set; }
        public int RelationId { get; set; }
        public string custId { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string AvatarUrl { get; set; }
        public bool IsForeign { get; set; }
        public int IsSex { get; set; }
        public string Birthday { get; set; }
        public bool IsNotification { get; set; }
        public string CountryCd { get; set; }
        public Guid? userId { get; set; }
    }
    public class HomApartmentMemberGet : HomApartmentMemberSet
    {
        public string SexName { get; set; }
        public bool IsHost { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public string RelationName { get; set; }
        public string loginname { get; set; }
        public bool isApp { get; set; }
    }
    public class HomApartmentGet: HomApartment
    {
        public List<HomApartmentMemberGet> Members { get; set; }
        public List<HomCardFull> Cards { get; set; }
    }
    public class HomApartmentHouseholdSet
    {
        public int ApartmentId { get; set; }
        public string custId { get; set; }
        public bool IsResident { get; set; }
        public string ResAdd1 { get; set; }
        public string ContactAdd1 { get; set; }
        public string PassNo { get; set; }
        public string PassDate { get; set; }
        public string PassPlace { get; set; }
    }
    public class HomApartmentExport
    {
        public int STT { get; set; }
        public string DuAn { get; set; }
        public string TenToaNha { get; set; }
        public string Tang { get; set; }
        public string MaCan { get; set; }
        public string DienTichThongThuy { get; set; }
        public string TenChuNha { get; set; }
        public int SoThanhVien { get; set; }
        public int SoTheDaCap { get; set; }
        public int SoXeDangKy { get; set; }
        public string DienThoai { get; set; }
        public string Email { get; set; }
        public string NgayNhanNha { get; set; }
        public string ChoThue { get; set; }
    }
    public class HomApartmentHousehold: HomApartmentHouseholdSet
    {        
        public string FullName { get; set; }
        public string AvatarUrl { get; set; }
        public string RelationName { get; set; }
        public string roomCode { get; set; }
        public string buildingName { get; set; }
        public string projectName { get; set; }
        public string sexName { get; set; }
        public string birthday { get; set; }
        public string phone { get; set; }
        public string email { get; set; }
        public bool isHost { get; set; }
        public bool isForeign { get; set; }
        public bool isApp { get; set; }
        public bool isNotification { get; set; }
        public string countryName { get; set; }
    }
    public class HomApartmentStatus
    {
        public int ApartmentId { get; set; }
        public int Status { get; set; }
    }
    public class HomApartmentReceived: HomApartmentStatus
    {
        public string ReceiveDate { get; set; }
        public string ReceiveNote { get; set; }
    }
    public class HomApartmentFee: Countable
    {
        public int ApartmentId { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string RoomCode { get; set; }
        public bool IsReceived { get; set; }
        public string ReceiveDate { get; set; }
        public bool IsRent { get; set; }
        public bool isFeeStart { get; set; }
        public string FeeStart { get; set; }
        public bool IsFree { get; set; }
        public int FreeMonth { get; set; }
        public string FreeToDate { get; set; }
        public string FeeNote { get; set; }
        public int Floor { get; set; }
        public double WaterwayArea { get; set; }
        public decimal FeePrice { get; set; }
        public int CardCount { get; set; }
        public int VehicleCount { get; set; }
        public int MemberCount { get; set; }
        public decimal DebitAmt { get; set; }
        public bool isLinkApp { get; set; }
    }
    public class HomApartmentRent: HomApartmentFee
    {
        public string Gender { get; set; }
        public string nation { get; set; }
        public string vehicle { get; set; }
    }

    public class HomApartmentFeeGet: HomApartmentFee
    {
        public List<HomServiceVehicleGet> ServiceVehicles { get; set; }
        public List<HomServiceLivingGet> ServiceLivings { get; set; }
        public List<HomServiceExtendGet> ServiceExtends { get; set; }
    }
    public class HomApartmentHost
    {
        public int ApartmentId { get; set; }
        public string UserLogin { get; set; }
        public string CustId { get; set; }
        public string ContractRemark { get; set; }
        public string ContractDate { get; set; }
    }
    public class BuildingFloor
    {
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string BuildingCd { get; set; }
        public string BuildingName { get; set; }
        public string Floor { get; set; }
        public string ProjectShort { get; set; }
    }

    
    public class FilterBaseApartments : FilterBaseProject
    {
        public string buildingCd { get; set; }
        public string Receive { get; set; }
        public string RoomCd { get; set; }
        public string Rent { get; set; }
        public int Debt { get; set; }
        public int setupStatus { get; set; }
        public FilterBaseApartments(string clientid, string userid, int? offset, int? pagesize,
            string projectcd, string roomcd, string buildingcd, string receive, string rent, int debt, int setupstatus) : base(clientid, userid, offset, pagesize, projectcd)
        {
            this.buildingCd = buildingcd;
            this.RoomCd = roomcd;
            this.Receive = receive;
            this.Rent = rent;
            this.Debt = debt;
            this.setupStatus = setupstatus;
        }
    }
    public class HomApartmentRelation
    {
        public int RelationId { get; set; }
        public string RelationName { get; set; }
    }
}

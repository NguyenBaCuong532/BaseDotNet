using UNI.Utils;
using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model
{

    public class HomCardBase
    {
        public string CardCd { get; set; }
    }
    public class HomCardLock:HomCardBase
    {
        public int Status { get; set; }
    }
    public class HomVehicleLock 
    {
        public long CardVehicleId { get; set; }
        public int StatusLock { get; set; }
    }
    public class HomAppVehicleLock
    {
        public int? Status { get; set; }
        public int CardVehicleId { get; set; }
        public string Reason { get; set; }
        public string userId { get; set; }
    }
    public class HomCardCust : HomCardBase
    {
        public string custId { get; set; }
    }
    public class HomCardInfoSet
    {
        public string CardCd { get; set; }
        public string CustId { get; set; }
        public string IssueDate { get; set; }
        public string ExpireDate { get; set; }
        public int CardTypeId { get; set; }
        public bool IsVip { get; set; }
    }
    public class HomCardAuth
    {
        public int RequestId { get; set; }
        public string CardCd { get; set; }
        public int Status { get; set; }
    }
    public class HomCardServiceStatus
    {
        public int ServiceId { get; set; }
        public string CardCd { get; set; }
        public int Status { get; set; }
        public int Id { get; set; }
    }
    public class HomCardSet
    {
        public int CardId { get; set; }
        public string RoomCd { get; set; }
        public string CardCd { get; set; }
        public string CustId { get; set; }
        public int CardTypeId { get; set; }
        public int IsVehicle { get; set; }
        
        public HomCardRegVehicle RegVehicle { get; set; }
        public HomCardRegCredit RegCredit { get; set; }
    }
    
    public class HomCardGet
    {
        public int cardId { get; set; }
        public string cardCd { get; set; }
        public string issueDate { get; set; }
        public string expireDate { get; set; }
        public string cifNo { get; set; }
        public int cardTypeId { get; set; }
        public string cardTypeName { get; set; }
        public string imageUrl { get; set; }
        public string fullName { get; set; }
        public string custId { get; set; }
        public long currentPoint { get; set; }
        public string status { get; set; }
        public string statusName { get; set; }
        public string roomCode { get; set; }
        public int apartmentId { get; set; }
        public string cardHex { get; set; }
        public bool isVehicle { get; set; }
        public string services { get; set; }
    }
    public class HomCardDailyExport
    {
        public int STT { get; set; }
        public string MaThe { get; set; }
        public string NgayCap { get; set; }
        public string TrangThai { get; set; }
    }
    public class HomCardExport
    {
        public int STT { get; set; }
        public string MaThe { get; set; }
        public string MaTheThangMay { get; set; }
        public string HoVaTen { get; set; }
        public string CanHo { get; set; }
        public string NgayCapThe { get; set; }
        //public string CifNo { get; set; }
        public string LoaiThe { get; set; }
        public string TrangThai { get; set; }
    }
    public class HomCardVipExport
    {
        public int STT { get; set; }
        public string MaThe { get; set; }
        public string MaTheThangMay { get; set; }
        public string TenThe { get; set; }
        public string NgayCapThe { get; set; }
        public string TenNguoiDung { get; set; }
        public string DienThoai { get; set; }
        public string Email { get; set; }
        public string PhongBan { get; set; }
        public string ViTri { get; set; }
        public string TrangThai { get; set; }
    }
    public class HomCardFull: HomCardGet
    {
        public List<HomServiceVehicleGet > VehicleServices { get; set; }
    }
    public class HomCardService
    {
        public int ApartmentId { get; set; }
        public string CardCd { get; set; }
        public string FullName { get; set; }
        public string RoomCode { get; set; }
        public int CardTypeId { get; set; }
        public string CardTypeName { get; set; }
        public string IssueDate { get; set; }
        public string ExpireDate { get; set; }
        public string StatusName { get; set; }
        public int CardStatus { get; set; }
        public int CurrentPoint { get; set; }
        public string imageUrl { get; set; }
        public List<HomServiceModel> GeneralServices { get; set; }
        public List<HomServiceVehicleGet > VehicleServices { get; set; }
        public List<HomCardServiceExtGet> ExtendServices { get; set; }
        public HomCardRegCredit CreditService { get; set; }
    }
    public class HomServiceVehicleSet
    {
        public int CardVehicleId { get; set; }
        public long ApartmentId { get; set; }
        public string CardCd { get; set; }
        public string CustId { get; set; }
        public int VehicleTypeId { get; set; }
        public string VehicleNo { get; set; }
        public string VehicleName { get; set; }
        public bool isVehicleNone { get; set; }
        public int ServiceId { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public int Status { get; set; }
        public bool? isCharginFee { get; set; }
    }
    public class HomCardServiceVehChange
    {
        public int CardVehicleId { get; set; }
        public int CardId { get; set; }
    }
    public class HomServiceVehicleGet: HomServiceVehicleSet
    {
        public string AssignDate { get; set; }
        public string VehicleTypeName { get; set; }
        public string ServiceName { get; set; }
        public string StatusName { get; set; }
        public bool IsLock { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string ProjectCd { get; set; }
    }
    public class HomRequestCardReg
    {
        public string RoomCode { get; set; }
        public string ProjectName { get; set; }
        public string FullName { get; set; }
        public string RequestDate { get; set; }
        public string regForm { get; set; }
        public HomCardRegVehicle CardVehicle { get; set; }
        public HomCardRegCredit CardCredit { get; set; }
        public HomCardVehiclePar Card { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
    }
    public class HomCardVehiclePar
    {
        public string FullName { get; set; }
        public string RoomCode { get; set; }
        public string CardTypeName { get; set; }
        public string CardCd { get; set; }
        public string VehicleName { get; set; }
        public string VehicleNo { get; set; }
    }
    public class HomRequestCardLost
    {
        public string RoomCode { get; set; }
        public string ProjectName { get; set; }
        public string FullName { get; set; }
        public string RequestDate { get; set; }
        public string CardFullName { get; set; }
        public string regForm { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public string CardCd { get; set; }
    }
    public class HomCardServiceExtSet
    {
        public int ExtendId { get; set; }
        public string CardCd { get; set; }
        public int ServiceId { get; set; }
        public string RegDate { get; set; }
        public string ExpireDate { get; set; }
        public int Amount { get; set; }
        public bool IsFree { get; set; }
    }
    public class HomCardServiceExtGet: HomCardServiceExtSet
    {
        public string ServiceName { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool IsLock { get; set; }
    }
    public class HomCardLogs
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public string StationName { get; set; }
        public string LogDate { get; set; }
    }
    public class HomCardPayments
    {
        public string StationName { get; set; }
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public string LogDate { get; set; }
        public int Amount { get; set;  }
        public int Point { get; set; }
    }
    
    public class HomVehicleServiceAuth
    {
        public int RequestId { get; set; } = 0;
        public int CardVehicleId { get; set; }
        public int Status { get; set; }
    }
    public class HomCardType
    {
        public int CardTypeId { get; set; }
        public string CardTypeName { get; set; }
    }
    public class HomCardDailySet
    {
        public string CardCd { get; set; }
        public int VehicleTypeId { get; set; }
        public string StartDate { get; set; }
        public string ExpireDate { get; set; }
        public string ProjectCd { get; set; }
    }
    public class HomCardDaily: HomCardDailySet
    {
        public int CardId { get; set; }
        public string InputDate { get; set; }
        public string VehicleTypeName { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool isUsed { get; set; }
        public long countUsed { get; set; }
        public string lastUsed { get; set; }
        public long lostTrackId { get; set; }
        public bool isLost { get; set; }
        public string lostDate { get; set; }
        public string ProjectName { get; set; }
    }
    public class HomCardVipSet: HomCardInfoSet
    {
        public string EmployeeId { get; set; }
        public string CardName { get; set; }
        public string ProjectCd { get; set; }
    }
    public class HomCardVip: HomCardVipSet
    {
        public int CardId { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Position { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool IsClose { get; set; }
        public DateTime CloseDate { get; set; }
        public List<HomServiceVehicleGet> VehicleServices { get; set; }
        //public string ProjectName { get; set; }
        public bool IsVihecle { get; set; }
        public string DepartmentName { get; set; }
    }
    
    
    public class HomVehicle
    {
        public int VehicleId { get; set; }
        public string VehicleName { get; set; }
        public int VehicleType { get; set; }
    }
    public class HomVehicleType
    {
        public int VehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
    }
    public class HomCardTypeGet : HomCardType
    {
        public string ImageUrl { get; set; } 
    }
    //public class HomCardPolicyUpdation:crmPolicyCardSet
    //{
    //    public int PolicyId { get; set; }
        
    //}

    

    public class HomCardDetail: HomCardGet
    {
        public bool isVip { get; set; }
        public int currPoint { get; set; }
        public float discount { get; set; }
    }
    
    //public class HomCardPolicy : HomCardTypeGet
    //{
    //    public int PolicyId { get; set; }
    //    public string PolicyName { get; set; }
    //    public string FromDate { get; set; }
    //    public string ToDate { get; set; }
    //    public float Discount { get; set; }
    //    public bool IsVip { get; set; }
    //    public int MinPoint { get; set; } 
    //}

    public class HomCardGuestSet
    {
        public string CardCd { get; set; }
        public string CustId { get; set; }
        public string CustPhone { get; set; }
        public string CustName { get; set; }
        public string IssueDate { get; set; }
        public string ExpireDate { get; set; }
        public string ProjectCd { get; set; }
        public int partner_id { get; set; }
    }
    public class HomCardGuestGet: HomCardGuestSet
    {
        public int Status { get; set; }
        public string StatusName { get; set; }
        public bool IsVehicle { get; set; }
        public string projectName { get; set; }
        public string partner_name { get; set; }
        public int CardVehicleId { get; set; }
    }
    public class CardBase
    {
        public string CardNum { get; set; }
        public string Code { get; set; }
    }
    public class ElevatorBuilding
    {
        public int Id { get; set; }
        public string BuildCd { get; set; }
        public string BuildName { get; set; }
        public string ProjectCd { get; set; }
        public DateTime SysDate { get; set; }
        public string CreatedBy { get; set; }
    }

    public class ElevatorFloor
    {
        public int Id { get; set; }
        public string FloorName { get; set; }
        public string FloorNumber { get; set; }
        public int FloorTypeId { get; set; }
        public string BuildCd { get; set; }
        public string BuildZoneId { get; set; }
        public string BuildZone { get; set; }
        public string ProjectCd { get; set; }
        public DateTime SysDate { get; set; }
        public string CreatedBy { get; set; }
    }

    public class ElevatorCardRole
    {
        public int Id { get; set; }
        public string RoleName { get; set; }
        public DateTime SysDate { get; set; }
        public string CreatedBy { get; set; }
    }

    public class ElevatorFloorType
    {
        public int Id { get; set; }
        public string FloorTypeName { get; set; }
        public string BuildCd { get; set; }
        public DateTime SysDate { get; set; }
        public string CreatedBy { get; set; }
    }

    public class ElevatorBuildZone
    {
        public int Id { get; set; }
        public string BuildZoneName { get; set; }
        public string BuildCd { get; set; }
        public DateTime SysDate { get; set; }
        public string CreatedBy { get; set; }
    }

    public class MAS_Elevator_Card
    {
        public int Id { get; set; }
        public string CardId { get; set; }
        public string CardRole { get; set; }
        public string CardType { get; set; }
        public string ProjectCd { get; set; }
        public string BuildCd { get; set; }
        public int? FloorNumber { get; set; }
        public string Note { get; set; }
        //public DateTime? SysDate { get; set; }
    }

    public class MAS_Elevator_Device
    {
        public int Id { get; set; }
        public string HardwareId { get; set; }
        public int FloorNumber { get; set; }
        public string FloorName { get; set; }
        public int? ElevatorBank { get; set; }
        public string ElevatorShaftName { get; set; }
        public int? ElevatorShaftNumber { get; set; }
        public string ProjectCd { get; set; }
        public string BuildCd { get; set; }
        public string BuildZone { get; set; }
        public bool? IsActived { get; set; }
        public DateTime? SysDate { get; set; }
    }
    public class MAS_Elevator_Device_Page : MAS_Elevator_Device
    {
        public string ProjectName { get; set; }
    }

    public class MAS_Elevator_Floor
    {
        public int Id { get; set; }
        public string ProjectCd { get; set; }
        public string BuildCd { get; set; }
        public string BuildZone { get; set; }
        public string FloorName { get; set; }
        public string FloorType { get; set; }
        public int FloorNumber { get; set; }
        public DateTime? SysDate { get; set; }
    }
    public class MAS_Elevator_Floor_Page : MAS_Elevator_Floor
    {
        public string ProjectName { get; set; }
    }
    public class ElevatorBankShaft
    {
        public int Id { get; set; }
        public int ElevatorBank { get; set; }
        public string ElevatorShaftName { get; set; }
        public int ElevatorShaftNumber { get; set; }
        public string ProjectCd { get; set; }
        public string BuildZone { get; set; }
        public DateTime? SysDate { get; set; }
        public string CreatedBy { get; set; }
    }
    public class CardInfo
    {
        public string Id { get; set; }
        public string CardId { get; set; }
        public string FullName { get; set; }
        public string CardRole { get; set; }
        public string CardType { get; set; }
        public string HardwareId { get; set; }
        public string ElevatorBank { get; set; }
        public string ElevatorShaftNumber { get; set; }
        public string ElevatorShaftName { get; set; }
        public string IssueDate { get; set; }
        public string ExpireDate { get; set; }
        public string ProjectName { get; set; }
        public string BuildName { get; set; }
        public string FloorName { get; set; }
        public string CardNumber { get; set; }
        public string RoleName { get; set; }
        public string CardTypeName { get; set; }
        public string ProjectCd { get; set; }
        public string BuildCd { get; set; }
        public string FloorNumber { get; set; }
        public Guid Oid { get; set; }
    }
    public class CardCustomer : CommonValue
    {
        public string CardId { get; set; }
        public string CardCd { get; set; }
        public string CardNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string FullName { get; set; }
        public string RoomCode { get; set; }
        public string CardTypeName { get; set; }
        public bool IsNoiBo { get; set; }
        public bool IsTheKhach { get; set; }
        public int IsVehicle { get; set; }
        public string IssueDate { get; set; }
        public string ExpireDate { get; set; }
        public string Status { get; set; }
    }

    //public class BLD_Project
    //{
    //    public string projectCd { get; set; }
    //    public string projectName { get; set; }
    //}

    public class FloorInfoGo
    {
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string BuildCd { get; set; }
        public string BuildZone { get; set; }
        public string FloorName { get; set; }
        public int FloorNum { get; set; }
        public string FloorType { get; set; }
        public string FloorTypeName { get; set; }
        public string HardWareId { get; set; }
    }
}

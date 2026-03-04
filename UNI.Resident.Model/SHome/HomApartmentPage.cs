using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomApartmentPage 
    {
        public List<homApartmentShort> apartments;
    }
    public class HomApartment
    {
        public int ApartmentId { get; set; }
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string BuildingName { get; set; }
        public string RoomCode { get; set; }
        public int Floor { get; set; }
        public float WaterwayArea { get; set; }
        public string CifNo { get; set; }
        public string FullName { get; set; }
        public string UserLogin { get; set; }
        public string FamilyImageUrl { get; set; }
        public int MemberCount { get; set; }
        public int HouseholdCount { get; set; }
        public int CardCount { get; set; }
        public int VehicleCount { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public bool isReceived { get; set; }
        public string ReceiveDate { get; set; }
        public bool IsRent { get; set; }
        public bool isFeeStart { get; set; }
        public bool SetupStatus { get; set; }
        public decimal CurrBal { get; set; }
        public bool isLinkApp { get; set; }
        //public bool ServerVihicleStatus { get; set; }
        //public bool ServerLivingStatus { get; set; }
    }
}

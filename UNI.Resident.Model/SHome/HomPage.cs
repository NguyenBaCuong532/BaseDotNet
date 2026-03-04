using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomApartmentPageHome
    {
        public string instruction { get; set; }
        public string projectHotline { get; set; }
        public bool isResident { get; set; }
        public HomApartmentRegGet registed { get; set; }
        public HomFamilyProfile Profile { get; set; }
    }
    public class homApartmentShort
    {
        public long apartmentId { get; set; }
        public string roomCode { get; set; }
        public string address { get; set; }
        public string projectCd { get; set; }
        public string projectName { get; set; }
        public string projectIntroUrl { get; set; }
        public bool isMain { get; set; }
    }
    
    public class homApartmentPage
    {
        public List<homApartmentShort> apartments { get; set; }
    }
    public class homApartmentCartPage
    {
        public List<homApartmentCart> apartments { get; set; }
    }
    public class PageHome
    {
        public HomFamilyProfile Profile { get; set; }
        //public Wallet wallet { get; set; }
    }

    public class PageFamilyMember
    {
        public List<HomApartmentMemberGet> Members { get; set; }
    }
    public class PageFamilyCard
    {
        public List<HomCardGet> Cards { get; set; }
    }
    //public class PageNotification
    //{
    //    public ResponseListNotification<List<SentNotify>> Notifications { get; set; }
    //}
    public class PageRequestFix
    {
        public ResponseList<List<HomRequestFix>> Requests { get; set; }
    }

    public class PagePayment
    {
        public ResponseList<List<HomReceivable>> Payments { get; set; }
    }

    public class PageRequestSev
    {
        public ResponseList<List<HomRequestSev>> CleanUps { get; set; }
    }



}

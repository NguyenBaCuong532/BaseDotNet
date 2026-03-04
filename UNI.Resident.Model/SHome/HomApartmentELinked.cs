using UNI.Resident.Model;
using UNI.Model;
namespace UNI.Resident.Model
{
    public class ApartmentELinked : Countable
    {
        public int ApartmentId { get; set; }
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Gender { get; set; }
        public string nation { get; set; }
        public string birthday { get; set; }
        public string FeeStart { get; set; }
        public int vehicle { get; set; }
    }
    public class ApartmentReceived : Countable
    {
        public int ApartmentId { get; set; }
        public string RoomCode { get; set; }
        public string carpetArea { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Gender { get; set; }
        public string nation { get; set; }
        public string birthday { get; set; }
        public string FeeStart { get; set; }
        public string receivedDate { get; set; }
        public int vehicle { get; set; }
    }
    public class ApartmentMember : Countable
    {
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string RelationName { get; set; }
        public string requestDt { get; set; }
        public string StatusName { get; set; }
    }
}

using UNI.Model;

namespace UNI.Resident.Model.Receipt
{
    public class ReceiptInfo : viewBaseInfo
    {
        public long? Id { get; set; }
    }
    public class ReceiptHistoryByApartmentIdModel : FilterBase
    {
        public int apartmentId { get; set; }
    }
    //public class ReceiptHistoryPage : viewBasePage<object>
    //{
    //}
}

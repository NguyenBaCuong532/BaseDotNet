using UNI.Model;
namespace UNI.Resident.Model
{
    public class HomReceiptPaySet
    {
        public int ReceiveId { get; set; }
        public long Amount { get; set; }
        public string ServiceKey { get; set; }
        public string PosCd { get; set; }
        public HomReceiptSet Receipt()
        {
            return new HomReceiptSet
            {
                ReceiptId = 0,
                ApartmentId = 0,
                ReceiveId = this.ReceiveId,
                Amount = this.Amount,
                TranferCd = "SPay"
            };
        }
    }
    public class HomReceiptSet
    {
        public int ReceiptId { get; set; }
        public string ReceiptNo { get; set; }
        public string ReceiptDate { get; set; }
        public int ApartmentId { get; set; }
        public int ReceiveId { get; set; }
        public string CustId { get; set; }
        public string Object { get; set; }
        public string PassNo { get; set; }
        public string PassDate { get; set; }
        public string PassPlc { get; set; }
        public string Address { get; set; }
        public string Contents { get; set; }
        public decimal Amount { get; set; }
        public string TranferCd { get; set; }
        public string Attach { get; set; }
        public string ProjectCd { get; set; }
        public bool IsDebit { get; set; }
        public string ReceiptBillViewUrl { get; set; }
        public decimal SubtractPoint { get; set; }
        public bool IsCreatetReceipt { get; set; }
    }
    public class HomReceiptGet : HomReceiptSet
    {
        public string FullName { get; set; }
        public string RoomCode { get; set; }
        public string AmountText { get; set; }
        public int ReceiptType { get; set; }
        public string BillUrl { get; set; }
        public string DBCR { get; set; }
        public string creatorCd { get; set; }
        public string createDate { get; set; }
        //public WalPayment BuildPayment(string serviceKey, string posCd)
        //{
        //    if (serviceKey == null)
        //    {
        //        serviceKey = "SK251196";
        //        posCd = "PC8448668311";
        //    }
        //    return new WalPayment
        //    {
        //        Amount = this.Amount,
        //        RefNo = this.ReceiptNo +"-"+ this.ReceiptId.ToString(),
        //        OrderInfo = "Thanh toán hóa đơn căn hộ " + this.RoomCode,
        //        ServiceKey = serviceKey,
        //        PosCd = posCd
        //    };
        //}
    }

    //public class BillResult
    //{
    //    public string Project { get; set; }
    //    public string BillUrl { get; set; }
    //    public string Message { get; set; }
    //}
}

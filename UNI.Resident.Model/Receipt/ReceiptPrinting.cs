namespace UNI.Resident.Model.Receipt
{
    public class ReceiptPrinting
    {
            public long ReceiptId { get; set; }
            public string ReceiptBillUrl { get; set; }
            public string ReceiptBillViewUrl { get; set; }
            public bool overwrite { get; set; }
    }
}

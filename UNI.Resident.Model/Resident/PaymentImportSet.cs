using System.Xml.Serialization;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model.Resident
{
    public class PaymentImportSet : BaseImportSet<PaymentImportItem>
    {
    }

    public class PaymentImportItem
    {
        [XmlElement("RoomCode")]
        [Excel(ExcelCol = "A")]
        public string RoomCode { get; set; }

        [XmlElement("InvoiceCode")]
        [Excel(ExcelCol = "B")] //ReceiveId
        public string InvoiceCode { get; set; }

        [XmlElement("EndDate")]
        [Excel(ExcelCol = "C")]
        public string EndDate { get; set; }

        [XmlElement("PaymentSection")]
        [Excel(ExcelCol = "D")]
        public string PaymentSection { get; set; }

        [XmlElement("PaymentAmount")]
        [Excel(ExcelCol = "E")]
        public string PaymentAmount { get; set; }

        [XmlElement("PaymentContent")]
        [Excel(ExcelCol = "F")]
        public string PaymentContent { get; set; }

        [XmlElement("PaymentDate")]
        [Excel(ExcelCol = "G")]
        public string PaymentDate { get; set; }

        [XmlElement("Target")]
        [Excel(ExcelCol = "H")]
        public string Target { get; set; }
    }
}




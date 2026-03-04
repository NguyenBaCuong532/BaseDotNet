using System.Collections.Generic;
using System.Xml.Serialization;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model.Resident
{
    public class DebitAmtImportSet : BaseImportSet<DebitAmtImportItem>
    {
        //public bool accept { get; set; }
        //public uImportFile importFile { get; set; }
        //public List<DebitAmtImportItem> imports { get; set; }
        //public DebitAmtImportSet()
        //{
        //    this.imports = new List<DebitAmtImportItem>();
        //}
    }

    public class DebitAmtImportItem
    {
        [XmlElement("RoomCode")]
        [Excel(ExcelCol = "A")]
        public string RoomCode { get; set; }

        [XmlElement("DebitAmt")]
        [Excel(ExcelCol = "B")]
        public string DebitAmt { get; set; }
    }
}

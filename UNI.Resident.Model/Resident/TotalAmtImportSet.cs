using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model.Resident
{
    public class TotalAmtImportSet : BaseImportSet<TotalAmtImportItem>
    {
        //public bool accept { get; set; }
        //public uImportFile importFile { get; set; }

        //public List<TotalAmtImportItem> imports { get; set; }
        //public TotalAmtImportSet()
        //{
        //    this.imports = new List<TotalAmtImportItem>();
        //}
    }

    public class TotalAmtImportItem
    {
        [XmlElement("RoomCode")]
        [Excel(ExcelCol = "A")]
        public string RoomCode { get; set; }

        [XmlElement("TotalAmt")]
        [Excel(ExcelCol = "B")]
        public string TotalAmt { get; set; }
    }
}

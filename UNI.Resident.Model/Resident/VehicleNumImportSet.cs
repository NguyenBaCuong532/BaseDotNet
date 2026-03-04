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
    public class VehicleNumImportSet : BaseImportSet<VehicleNumImportItem>
    {
        //public bool accept {  get; set; }
        //public uImportFile importFile { get; set; }
        //public List<VehicleNumImportItem> imports { get; set; }
        //public VehicleNumImportSet() 
        //{
        //    this.imports = new List<VehicleNumImportItem>();
        //}
    }

    public class VehicleNumImportItem
    {
        [XmlElement("VehicleNo")]
        [Excel(ExcelCol = "A")]
        public string VehicleNo { get; set; }

        [XmlElement("VehicleNum")]
        [Excel(ExcelCol = "B")]
        public string VehicleNum { get; set; }
    }
}

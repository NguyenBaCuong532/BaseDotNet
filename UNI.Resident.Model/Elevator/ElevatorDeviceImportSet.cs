using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model.Elevator
{
    public class ElevatorDeviceImportSet : BaseImportSet<ElevatorDeviceImportItem>
    {

    }

    public class ElevatorDeviceImportItem
    {
        [Excel(ExcelCol = "A")]
        public string Seq { get; set; }
        [Excel(ExcelCol = "B")]
        public string ProjectCd { get; set; }
        [Excel(ExcelCol = "C")]
        public string BuildCd { get; set; }
        [Excel(ExcelCol = "D")]
        public string HardwareId { get; set; }
        [Excel(ExcelCol = "E")]
        public string BuildZone { get; set; }
        [Excel(ExcelCol = "F")]
        public string FloorName { get; set; }
        [Excel(ExcelCol = "G")]
        public string ElevatorBank { get; set; }
        [Excel(ExcelCol = "H")]
        public string ElevatorShaftName { get; set; }
        [Excel(ExcelCol = "I")]
        public string ElevatorShaftNumber { get; set; }
        [Excel(ExcelCol = "J")]
        public string FloorNumber { get; set; }
        [Excel(ExcelCol = "K")]
        public string IsActive { get; set; }

    }
}

using UNI.Model;
using UNI.Resident.Model.Common;
using UNI.Utils;

namespace UNI.Resident.Model.Card
{
    public class CardImportSet: BaseImportSet<CardImportItem>
    {

    }
    public class CardVehicleImportSet : BaseImportSet<CardVehicleImportItem>
    {

    }
    public class CardVehicleImportItem
    {
        [Excel(ExcelCol = "A")]
        public string Seq { get; set; }
        [Excel(ExcelCol = "B")]
        public string Code { get; set; }
        //public string errors { get; set; }
    }
    public class CardImportItem
    {
        [Excel(ExcelCol = "A")]
        public string Seq { get; set; }
        [Excel(ExcelCol = "B")]
        public string Serial { get; set; }
        [Excel(ExcelCol = "C")]
        public string Code { get; set; }
        [Excel(ExcelCol = "D")]
        public string Hex { get; set; }
        [Excel(ExcelCol = "E")]
        public string ProjectName { get; set; }
        [Excel(ExcelCol = "F")]
        public string LotNumber { get; set; }
        //[Excel(ExcelCol = "F")]
        //public string errors { get; set; }
    }
}

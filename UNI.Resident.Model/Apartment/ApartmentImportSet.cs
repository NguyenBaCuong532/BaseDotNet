using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Utils;

namespace UNI.Resident.Model.Apartment
{
    public class ApartmentImportSet : BaseImportSet<ApartmentImportItem>
    {
    }
    public class ApartmentImportItem
    {
        [Excel(ExcelCol = "A")]
        public string Seq { get; set; }
        [Excel(ExcelCol = "B")]
        public string ProjectCd { get; set; }
        [Excel(ExcelCol = "C")]
        public string BuildingCd { get; set; }
        [Excel(ExcelCol = "D")]
        public string FloorName { get; set; }
        [Excel(ExcelCol = "E")]
        public string RoomCode { get; set; }
        [Excel(ExcelCol = "F")]
        public string WallArea { get; set; }
        [Excel(ExcelCol = "G")]
        public string WaterwayArea { get; set; }
        [Excel(ExcelCol = "H")]
        public string IsReceived { get; set; }
        [Excel(ExcelCol = "I")]
        public string ReceiveDt { get; set; }
        [Excel(ExcelCol = "J")]
        public string IsRent { get; set; }
        [Excel(ExcelCol = "K")]
        public string FeeStart { get; set; }
        [Excel(ExcelCol = "L")]
        public string numFeeMonth { get; set; }
    }
}

using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model.Resident
{
    public class LivingImportSet : BaseImportSet<LivingImportItem>
    {
        //public bool accept { get; set; }
        public int livingTypeId { get; set; }
        
        public Guid PeriodsOid { get; set; }

        //public uImportFile importFile { get; set; }
        //public List<LivingImportItem> imports { get; set; }
        //public LivingImportSet()
        //{
        //    this.imports = new List<LivingImportItem>();
        //}
    }
    //public class LivingImportFile
    //{
    //    public int livingTypeId { get; set; }
    //    public IFormFile file { get; set; }
    //}
    public class LivingImportItem
    {
       
        [XmlElement("room_code")]
        [Excel(ExcelCol = "A")]
        public string room_code { get; set; }

        [XmlElement("period_month")]
        [Excel(ExcelCol = "B")]
        public string period_month { get; set; }
        [XmlElement("period_year")]
        [Excel(ExcelCol = "C")]
        public string period_year { get; set; }

        [XmlElement("from_dt")]
        [Excel(ExcelCol = "D")]
        public string from_dt { get; set; }

        [XmlElement("to_dt")]
        [Excel(ExcelCol = "E")]
        public string to_dt { get; set; }

        [XmlElement("from_num")]
        [Excel(ExcelCol = "F")]
        public string from_num { get; set; }

        [XmlElement("to_num")]
        [Excel(ExcelCol = "G")]
        public string to_num { get; set; }

    }
}

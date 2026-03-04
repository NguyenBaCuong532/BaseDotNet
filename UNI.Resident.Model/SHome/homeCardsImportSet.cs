using UNI.Utils;
using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class homeCardsImportSet : BaseImportSet<homeCardsImportItem>
    {
        //public bool accept { get; set; }
        //public List<homCardsImport> imports { get; set; }
        //public homeCardsImportSet()
        //{
        //    this.imports = new List<homCardsImport>();
        //}
    }
    public class homeCardsImportItem
    {
        [XmlElement("cardType")]
        [Excel(ExcelCol = "A")]
        public string cardType { get; set; }
        [XmlElement("projectCd")]
        [Excel(ExcelCol = "B")]
        public string projectCd { get; set; }
        [XmlElement("cardCd")]
        [Excel(ExcelCol = "C")]
        public string cardCd { get; set; }
        [XmlElement("orgId")]
        [Excel(ExcelCol = "D")]
        public string orgId { get; set; }
        [XmlElement("fullName")]
        [Excel(ExcelCol = "E")]
        public string fullName { get; set; }
        [XmlElement("phone")]
        [Excel(ExcelCol = "F")]
        public string code { get; set; }
        [XmlElement("email")]
        [Excel(ExcelCol = "G")]
        public string email { get; set; }
        [XmlElement("endDate")]
        [Excel(ExcelCol = "H")]
        public string endDate { get; set; }
        public string custId { get; set; }
        [XmlElement("errors")]
        [Excel(ExcelCol = "I")]
        public string errors { get; set; }
        public string cardId { get; set; }
    }

    public class homCardVehicleImportSet : BaseImportSet<homCardVehicleImportItem>
    {
        //public bool accept { get; set; }
        //public List<homCardVehicleImportItem> imports { get; set; }
        //public homCardVehicleImportSet()
        //{
        //    this.imports = new List<homCardVehicleImportItem>();
        //}
    }
    public class homCardVehicleImportItem
    {
        [XmlElement("ordId")]
        [Excel(ExcelCol = "A")]
        public string ordId { get; set; }
        [XmlElement("fullName")]
        [Excel(ExcelCol = "B")]
        public string fullName { get; set; }
        [XmlElement("code")]
        [Excel(ExcelCol = "C")]
        public string code { get; set; }
        [XmlElement("cardCd")]
        [Excel(ExcelCol = "D")]
        public string cardCd { get; set; }
        [XmlElement("vehicle_type")]
        [Excel(ExcelCol = "E")]
        public string vehicle_type { get; set; }
        [XmlElement("vehicle_no")]
        [Excel(ExcelCol = "F")]
        public string vehicle_no { get; set; }
        [XmlElement("vehicle_name")]
        [Excel(ExcelCol = "G")]
        public string vehicle_name { get; set; }
        [XmlElement("start_date")]
        [Excel(ExcelCol = "H")]
        public string start_date { get; set; }
        [XmlElement("end_date")]
        [Excel(ExcelCol = "I")]
        public string end_date { get; set; }
        public string custId { get; set; }
        [XmlElement("errors")]
        [Excel(ExcelCol = "J")]
        public string errors { get; set; }
        public string cardvehicleId { get; set; }

    }

    public class homCustomerInfo {
        public Guid? empId { get; set; }
        public string code { get; set; }
        public string custId { get; set; }
        public string avatar_url { get; set; }
        public string birthday { get; set; }
        public string email1 { get; set; }
        public string full_name { get; set; }
        public string phone1 { get; set; }
        public bool? sex { get; set; }
        public string userId { get; set; }
        public string cif_no { get; set; }
        public string idcard_no { get; set; }
        public string idcard_issue_dt { get; set; }
        public string idcard_issue_plc { get; set; }
        public string res_add { get; set; }
        public string res_cntry { get; set; }
       
    }

}

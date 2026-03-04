using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class homApartmentCart : homApartmentShort
    {
        public string roomCd { get; set; }
        public int handOver_st { get; set; }
        public string handOver_status { get; set; }
    }
    public class homApartmentCartDetail
    {
        public string roomCd { get; set; }
        public string roomCode { get; set; }
        public double waterwayArea { get; set; }
        public string floorNo { get; set; }
        public string buildingName { get; set; }
        public string projectCd { get; set; }
        public string projectName { get; set; }
        public homContractShort contract { get; set; }
        public List<SchedulePay> payments { get; set; }
    }

    public class homContractShort
    {
        public string ContractNo { get; set; }
        public string Contract_Dt { get; set; }
        public decimal totalAmt { get; set; }
        public string investorName { get; set; }
    }
    public class SchedulePay
    {
        //public long SchPayId { get; set; }
        public int InstallNum { get; set; }
        public DateTime InstallDt { get; set; }
        public string strInstallDt { get; set; }
        public string InstallNote { get; set; }
        public decimal InstallAmt { get; set; }
        public decimal MainFee { get; set; }
        public decimal Amount { get; set; }
        public decimal PayedAmt { get; set; }
        public DateTime PayDt { get; set; }
        public string strPayDt { get; set; }
        public DateTime ExpDt { get; set; }
        public string strExpDt { get; set; }
        public bool Status { get; set; }
    }
}

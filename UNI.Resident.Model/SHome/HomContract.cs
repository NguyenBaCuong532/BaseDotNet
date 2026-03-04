using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    //public class HomContractSet
    //{
    //    public int ContractId { get; set; }
    //    public string ProjectCd { get; set; }
    //    public int ContractTypeId { get; set; }
    //    public string ProviderCd { get; set; }
    //    //public int ApartmentId { get; set; }
    //    public string RoomCode { get; set; }
    //    //
    //    public string ContractNo { get; set; }
    //    public string ContractDate { get; set; }
    //    //public string ExpireDate { get; set; }
    //    public string CustId { get; set; }
    //    public string CustomerName { get; set; }
    //    public string IdCard { get; set; }
    //    public string IssueDate { get; set; }
    //    public string IssueBy { get; set; }

    //    public string IsCompany { get; set; }
    //    public string CompanyName { get; set; }
    //    public string CompanyRepresent { get; set; }
    //    public string CompanyCode { get; set; }
    //    public string CompanyAddress { get; set; }       

    //    public List<HomContractDevice> ContractDevices { get; set; }
    //    //public HomContractUser ContractUser { get; set; }
    //    //public HomContractMeter ContractMeter { get; set; }
    //    public HomContractSchedulePay ContractSchedulePay { get; set; }
    //}
    //public class HomContractDevice
    //{
    //    public int ContractId { get; set; }
    //    public long DeviceId { get; set; }
    //    public string DeviceSerial { get; set; }
    //    public string DeviceName { get; set; }
    //    public string DeviceWarranty { get; set; }
    //    public string UserType { get; set; }
    //    public string UserName { get; set; }
    //    public string UserPassword { get; set; }
    //    public string MeterSeri { get; set; }
    //    public string MeterDateStart { get; set; }
    //    public double MeterNumStart { get; set; }
    //}
    //public class HomContractUser
    //{
    //    public string UserName { get; set; }
    //    public string UserPassword { get; set; }
    //    public string UserType { get; set; }
    //}
    //public class HomContractMeter
    //{
    //    //public string MeterSeri { get; set; }
        
        
    //}
    //public class HomContractSchedulePay
    //{
    //    public int ContractId { get; set; }
    //    public long SchedulePayId { get; set; }
    //    public int PayType { get; set; }
    //    public int ContractPriceId { get; set; }
    //    public int Term { get; set; }
    //    public int Extant { get; set; }
    //    public string ExpireDate { get; set; }
    //    public int BasePrice { get; set; }
    //    public int DevicePrice { get; set; }
    //    public int TermPrice { get; set; }
    //    public int TotalAmount { get; set; }
    //    public bool AutoRenewal { get; set; }
    //    public string lastReceivable { get; set; }
    //}
    //public class HomServiceContractGet : HomContractSet
    //{
    //    public bool IsClose { get; set; }
    //    public string CloseDate { get; set; }
    //    public string ProviderName { get; set; }
    //    public string ContractTypeName { get; set; }
    //    public int ApartmentId { get; set; }
    //}
    
    public class HomPackPrice
    {
        public int PackPriceId { get; set; }
        public string PriceCode { get; set; }
        public string PriceName { get; set; }
        public int SpeedUD { get; set; }
        public int BasePrice { get; set; }
        public int SixPrice { get; set; }
        public int YearPrice { get; set; }
        public int DevicePrice { get; set; }
        public string BaseFee { get; set; }
    }
}

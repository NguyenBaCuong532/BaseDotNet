using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomExtendType
    {
        public int ExtendTypeId { get; set; }
        public string ExtendTypeName { get; set; }
    }
    public class HomServiceExtendSet
    {
        public long ExtendId { get; set; }
        public long ApartmentId { get; set; }
        public int ContractType { get; set; }
        public string ContractNo { get; set; }
        public string ContractDate { get; set; }
        public string DeviceSerial { get; set; }
        public string DeviceName { get; set; }
        public string DeviceWarranty { get; set; }
        public string ContractUser { get; set; }
        public string ContractPassword { get; set; }
        public string PackPriceId { get; set; }
        public string ProviderCd { get; set; }
        public string CustId { get; set; }
        public string CustName { get; set; }
        public string CustPhone { get; set; }
        public string IsCompany { get; set; }
        public string CompanyName { get; set; }
        public string CompanyRepresent { get; set; }
        public string CompanyCode { get; set; }
        public string CompanyAddress { get; set; }
    }
    public class HomServiceExtendGet: HomServiceExtendSet
    {
        public string RoomCode { get; set; }
        public string PayedLast { get; set; }
        public string PackPriceName { get; set; }
    }
}

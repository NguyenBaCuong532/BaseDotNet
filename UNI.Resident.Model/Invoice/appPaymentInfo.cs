using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using UNI.Utils;

namespace UNI.Resident.Model.Invoice
{
    public class appPaymentInfo
    {
        public bool isKlb { get; set; }
        public Guid Oid { get; set; }
        public string prefix { get; set; }
        public string virtualPartNum { get; set; }
        public string coop_name { get; set; }
        public string tran_content { get; set; }
        public string coop_cif_no { get; set; }
        public string coop_acc_no_ic { get; set; }
        public string short_name { get; set; }
        public string coop_acc_no
        {
            get
            {
                return isKlb
            ? VitualAccount.GenerateVirtualAccount(prefix, virtualPartNum)
            : coop_acc_no_ic;
            }
        }
        public string coop_acc_name { get; set; }
        public string coop_bank_branch { get; set; }
        public string coop_bank_name { get; set; }
        public string bank_code { get; set; }
        public decimal trans_amt { get; set; }
        public string trans_amt_text { get; set; }
        public string investor_name { get; set; }
        public string room_code { get; set; }
        public string qr_code_pay
        {
            get
            {
                return VietQrHelpers.GenerateVietQR(bank_code, coop_acc_no, trans_amt, tran_content);
            }
        }
        [JsonIgnore]
        public bool? valid { get; set; }
        [JsonIgnore]
        public string messages { get; set; }
    }
    //public class appTransaction
    //{
    //    public decimal? trans_amt { get; set; }
    //    public DateTime? trans_dt { get; set; }
    //    public string trans_amt_text { get; set; }
    //}
    public class appVirtualAccSet
    {
        public string virtualAcc { get; set; }
        public Guid Oid { get; set; }
    }
}

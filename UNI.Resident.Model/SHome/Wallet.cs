using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.Model.SHome
{
    public class Wallet
    {
        public string CustId { get; set; }
        public string WalletCd { get; set; }
        public WalBankLink TranferLink { get; set; }
        public long CurrentAmount { get; set; }
        public long PayLimitAmount { get; set; }
        public string linkID { get; set; }
        public bool isRequirePincode { get; set; }
        public long CurrentPoint { get; set; }
    }
    public class WalBankLink
    {
        public int LinkedID { get; set; }
        public string TranferCd { get; set; }
        public string SourceCd { get; set; }
        public string ShortName { get; set; }
        public string SourceName { get; set; }
        public string LogoUrl { get; set; }
        public string LinkedToken { get; set; }
    }
    public class WalPointTran
    {
        public string PointTranId { get; set; }
        public string TranType { get; set; }
        public string CardToken { get; set; }
        public string CardSerial { get; set; }
        public int Point { get; set; }
        public int CurrPoint { get; set; }
        public string TranDt { get; set; }
        public string Remark { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public int PointType { get; set; }
    }

}

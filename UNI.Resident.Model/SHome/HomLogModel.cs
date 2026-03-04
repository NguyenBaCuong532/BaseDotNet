using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomLogRead
    {
        public int StationId { get; set; }
        public string CardCd { get; set; }
    }
    public class HomLogPay
    {
        public string CardCd { get; set; }
        public int StationId { get; set; }
        public int Amount { get; set; }
        public int Point { get; set; }
    }
}

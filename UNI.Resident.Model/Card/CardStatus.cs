using System;
using UNI.Model;

namespace UNI.Resident.Model.Card
{
    public class CardStatus
    {
        public string CardCd { get; set; }
        /// <summary>Khóa logic thẻ (MAS_Cards.oid). Ưu tiên dùng khi có; nếu có thì bỏ qua CardCd.</summary>
        public Guid? CardOid { get; set; }
        public int Status { get; set; }
        public string Reason { get; set; }
        public bool IsHardLock { get; set; }
    }
    
}

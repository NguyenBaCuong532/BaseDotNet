using System;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces.Card
{
    public interface ICardGuestRepository
    {
        #region web-apartment
        
        Task<CommonViewInfo> GetCardFilter();
        //Thẻ khách
        Task<CommonDataPage> GetGuestCardPageAsync(CardGuestFilter query);
        Task<CommonViewInfo> GetInfoAsync(string cardId, string partner_id, Guid? cardOid = null);
        Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info);
        Task<CommonViewInfo> SetGuestCardDraft(CommonViewInfo info);
        Task<BaseValidate> DeleteCardAsync(string cardId, Guid? cardOid = null);
        Task<BaseValidate> SetCardLockedAsync(string cardId, int Status, Guid? cardOid = null);//Mở/Khóa thẻ
        #endregion
    }
}

using System;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.Card
{
    public interface ICardGuestService
    {
        #region web-apartment
        // QL thẻ thuộc căn hộ
        
        Task<BaseValidate> DeleteCardAsync(string cardId, Guid? cardOid = null);
        Task<BaseValidate> SetCardLockedAsync(string CardCd, int Status, Guid? cardOid = null);//Mở/Khóa thẻ
        // Thêm mới thẻ: Thẻ căn hộ, thẻ xe, thẻ tín dụng
        // thẻ cư dân
        Task<CommonDataPage> GetCardGuestPage(CardGuestFilter query);
        Task<CommonViewInfo> GetCardGuestInfo(string cardId, string partner_id, Guid? cardOid = null);
        Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info);
        Task<CommonViewInfo> GetCardFilter();
        Task<CommonViewInfo> SetGuestCardDraft(CommonViewInfo info);

        #endregion
    }
}

using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;
using System;

namespace UNI.Resident.DAL.Interfaces.Card
{
    public interface ICardResidentRepository
    {
        #region web-apartment

        // QL thẻ thuộc căn hộ
        Task<CommonViewInfo> GetResidentCardFilter();
        Task<CommonDataPage> GetResidentCardPage(FilterCardResident query);
        Task<CommonViewInfo> GetCardInfoAsync(string cardId, string apartmentId, Guid? apartOid = null, Guid? cardOid = null);
        Task<BaseValidate> SetCardInfoAsync(CommonViewInfo info);
        Task<BaseValidate> DeleteCardAsync(string cardId);
        Task<BaseValidate> SetCardLockedAsync(string cardId, int Status);//Mở/Khóa thẻ
        // Thêm mới thẻ: Thẻ căn hộ, thẻ xe, thẻ tín dụng
        
        #endregion
    }
}

using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using System;

namespace UNI.Resident.BLL.BusinessInterfaces.Card
{
    public interface ICardResidentService
    {
        #region web-apartment
        Task<CommonViewInfo> GetResidentCardFilter();
        Task<CommonDataPage> GetResidentCardPage(FilterCardResident query);
        Task<BaseValidate> SetCardInfoAsync(CommonViewInfo info);
        Task<BaseValidate> DeleteCardAsync(string cardId);
        Task<BaseValidate> SetCardLockedAsync(string cardId, int Status);//Mở/Khóa thẻ
        // Thêm mới thẻ: Thẻ căn hộ, thẻ xe, thẻ tín dụng
        
        Task<CommonViewInfo> GetCardInfoAsync(string cardId, string apartmentId, Guid? apartOid = null, Guid? cardOid = null);
        #endregion
    }
}

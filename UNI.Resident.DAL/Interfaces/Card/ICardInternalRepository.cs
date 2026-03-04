using System;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Interfaces.Card
{
    public interface ICardInternalRepository
    {
        #region web-apartment

        Task<CommonViewInfo> GetCardFilter();
        Task<CommonDataPage> GetCardPage(FilterBaseProject query);
        Task<CommonViewInfo> GetCardInfo(string cardId, Guid? cardOid = null);
        Task<BaseValidate> SetCardInfo(CommonViewInfo info);
        Task<BaseValidate> DeleteCard(string cardId, Guid? cardOid = null);
        Task<BaseValidate> SetCardLocked(string cardId, int Status, Guid? cardOid = null);//Mở/Khóa thẻ
        
        #endregion
    }
}

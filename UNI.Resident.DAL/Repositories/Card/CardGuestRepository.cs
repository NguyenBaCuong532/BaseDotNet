using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardGuestRepository : UniBaseRepository, ICardGuestRepository
    {

        public CardGuestRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        #region web-Card
                
        public async Task<CommonViewInfo> GetCardFilter()
        {
            const string storedProcedure = "card_guest_filter";
            return await GetTableFilterAsync(storedProcedure);
        }

        public async Task<CommonDataPage> GetGuestCardPageAsync(CardGuestFilter query)
        {
            const string storedProcedure = "sp_res_card_guest_page";
            return await GetDataListPageAsync(storedProcedure, query, 
                new {query.ProjectCd, partner_id = query.PartnerId, Statuses = query.Status });
        }

        public async Task<CommonViewInfo> GetInfoAsync(string cardId, string partner_id, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_guest_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { cardId, partner_id, cardOid });
        }
        public async Task<CommonViewInfo> SetGuestCardDraft(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_guest_draft";
            return await SetInfoAsync<CommonViewInfo>(storedProcedure, info, new { info.id } );
        }

        public async Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_guest_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { CustId = info.GetValueByFieldName("CustId") });
        }
        public async Task<BaseValidate> DeleteCardAsync(string cardId, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_guest_del";
            return await DeleteAsync(storedProcedure, new { cardId, cardOid });
        }
        public async Task<BaseValidate> SetCardLockedAsync(string cardId, int Status, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_guest_loked";
            return await SetAsync(storedProcedure, new { cardId, Status, cardOid });
        }
        #endregion
    }
}

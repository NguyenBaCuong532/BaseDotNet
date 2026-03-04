using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardInternalRepository : UniBaseRepository, ICardInternalRepository
    {

        public CardInternalRepository(IUniCommonBaseRepository common) : base(common)
        {
            //_logger = logger;
        }
        #region web-Card
        public async Task<CommonViewInfo> GetCardFilter()
        {
            const string storedProcedure = "card_internal_filter";
            return await GetTableFilterAsync(storedProcedure);
        }
        public async Task<CommonDataPage> GetCardPage(FilterBaseProject query)
        {
            const string storedProcedure = "sp_res_card_internal_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd });
        }
        public async Task<CommonViewInfo> GetCardInfo(string cardId, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_internal_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { cardId, cardOid });
        }
        public async Task<BaseValidate> SetCardInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_internal_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, 
                new { custId = info.GetValueByFieldName("CustId"), cardCd = info.GetValueByFieldName("CardCd") });
        }
        public async Task<BaseValidate> DeleteCard(string cardId, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_internal_del";
            return await DeleteAsync(storedProcedure, new { cardId, cardOid });
        }
        public async Task<BaseValidate> SetCardLocked(string cardId, int Status, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_internal_loked";
            return await SetAsync(storedProcedure, new { cardId, Status, cardOid });
        }
        
        #endregion
    }
}

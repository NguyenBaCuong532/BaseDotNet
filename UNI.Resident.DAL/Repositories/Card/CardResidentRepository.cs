using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardResidentRepository : UniBaseRepository, ICardResidentRepository
    {

        public CardResidentRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        #region web-Card

        public async Task<CommonViewInfo> GetResidentCardFilter()
        {
            const string storedProcedure = "card_resident_filter";
            return await GetTableFilterAsync(storedProcedure);
        }

        public async Task<CommonDataPage> GetResidentCardPage(FilterCardResident query)
        {
            const string storedProcedure = "sp_res_card_resident_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.apartmentId, query.apartOid, query.cardOid, Statuses = query.Statuses, vehicle = query.isVehicle });
        }
        public async Task<CommonViewInfo> GetCardInfoAsync(string cardId, string apartmentId, Guid? apartOid = null, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_resident_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { cardId, apartmentId, apartOid, cardOid });
        }
        public async Task<BaseValidate> SetCardInfoAsync(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_resident_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, 
                new { custId = info.GetValueByFieldName("CustId"), cardCd = info.GetValueByFieldName("CardCd") });
        }
        public async Task<BaseValidate> DeleteCardAsync(string cardId)
        {
            const string storedProcedure = "sp_res_card_resident_del";
            return await DeleteAsync(storedProcedure, new { cardId });
        }
        public async Task<BaseValidate> SetCardLockedAsync(string cardId, int Status)
        {
            const string storedProcedure = "sp_res_card_resident_loked";
            return await SetAsync(storedProcedure, new { cardId, Status });
        }
        

        #endregion
    }
}

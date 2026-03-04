using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Common;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardPartnerRepository : UniBaseRepository, ICardPartnerRepository
    {
        public CardPartnerRepository(IUniCommonBaseRepository common) : base(common) { }

        #region res_card
        public async Task<BaseValidate> DeleteAsync(long? id)
        {
            const string storedProcedure = "sp_res_card_partner_del";
            return await DeleteAsync(storedProcedure, new { partner_id = id });
        }

        public async Task<CommonViewInfo> GetInfoAsync(long? id)
        {
            const string storedProcedure = "sp_res_card_partner_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id });
        }

        public async Task<IEnumerable<CommonValue>> GetListAsync(string projectCd)
        {
            const string storedProcedure = "sp_res_card_partner_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { projectCd });
        }

        public async Task<CommonDataPage> GetPageAsync(GridProjectFilter query)
        {
            const string storedProcedure = "sp_res_card_partner_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd });
        }

        public async Task<BaseValidate> SetInfoAsync(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_partner_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { partner_id = info.id });
        }
        #endregion res_card
    }
}

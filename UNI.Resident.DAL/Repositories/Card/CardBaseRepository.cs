using DapperParameters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardBaseRepository : ResidentBaseRepository, ICardBaseRepository
    {
        public CardBaseRepository(IResidentCommonBaseRepository common) : base(common)
        {
        }

        public async Task<CommonDataPage> GetCardBasePage(FilterBase filter, long startNum, long endNum, bool status)
        {
            const string storedProcedure = "sp_res_card_base_page";
            return await GetDataListPageAsync(storedProcedure, filter, new { startNum, endNum, status });
        }
        public async Task<BaseValidate> SetBaseClassify(CardClassificationInfo info)
        {
            const string storedProcedure = "sp_res_card_base_set";
            return await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, param =>
            {
                var guidItems = info.Ids?.Select(x => new GuidItem { Id = x }).ToList() ?? new List<GuidItem>();
                param.AddTable("ids", TableTypes.GUID_LIST, guidItems);
                //param.Add("projectCode", info.GetDatetimeValueByFieldName("projectCode"));
                param.Add("projectCode", info.GetValueByFieldName("projectCode"));
                //param.Add("type", info.GetDatetimeValueByFieldName("type"));
                param.Add("type", info.GetValueByFieldName("type"));
                return param;
            });
        }

        public async Task<CardClassificationInfo> GetClassifyInfo(Guid? id)
        {
            const string storedProcedure = "sp_res_card_base_field";
            return await GetFieldsAsync<CardClassificationInfo>(storedProcedure, new { id });
        }

        public async Task<BaseValidate> DeleteCardBase(string id)
        {
            const string storedProcedure = "sp_res_card_base_del";
            return await DeleteAsync(storedProcedure, new { id });
        }

        public async Task<DataSet> GetCardBaseImportTemp()
        {
            const string storedProcedure = "sp_res_card_base_import_temp";
            return await GetDataSetAsync(storedProcedure);
        }
        public async Task<ImportListPage> SetCardBaseImportAsync(CardImportSet importSet)
        {
            const string storedProcedure = "sp_res_card_base_import";
            return await base.SetImport<CardImportItem, CardImportSet>(storedProcedure,
                importSet, "cards", TableTypes.CARD_IMPORT_TYPE, new { });
        }
        public async Task<List<CommonValue>> GetCardBaseList(string projectCd, Guid? oid, string filter)
        {
            const string storedProcedure = "sp_res_card_base_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { projectCd, oid, filter });
        }

        public CommonViewInfo GetCardBaseFilter(string userId)
        {
            const string storedProcedure = "sp_res_card_base_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId }).Result;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.CardVehicle
{
    public class VehicleInternalRepository : UniBaseRepository, IVehicleInternalRepository
    {

        public VehicleInternalRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        public Task<CommonViewInfo> GetVehicleFilter()
        {
            const string storedProcedure = "vehicle_internal_filter";
            return base.GetTableFilterAsync(storedProcedure, new { });
        }        
        public async Task<CommonDataPage> GetVehiclePage(VehicleCardRequestModel query)
        {
            const string storedProcedure = "sp_res_vehicle_internal_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.CardCd });
        }
        public async Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_internal_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { cardVehicleId = CardVehicleId, cardVehicleOid });
        }
        public async Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info)
        {
            const string storedProcedure = "sp_res_vehicle_internal_set1";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { CardVehicleId = info.GetValueByFieldName("CardVehicleId") });
        }
        public async Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_internal_loked";
            return await SetAsync(storedProcedure, new { CardVehicleId, Status, cardVehicleOid });
        }
        
        public async Task<BaseValidate> DelVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_internal_del";
            return await DeleteAsync(storedProcedure, new { cardVehicleId, cardVehicleOid });
        }
        public async Task<DataSet> GetVehicleImportTemp()
        {
            const string storedProcedure = "sp_res_vehicle_internal_imports_temp";
            return await GetDataSetAsync(storedProcedure);
        }
        public async Task<ImportListPage> SetImportVehicleAsync(CardVehicleImportSet importSet)
        {
            const string storedProcedure = "sp_res_vehicle_internal_import";
            return await base.SetImport<CardVehicleImportItem, CardVehicleImportSet>(storedProcedure,
                importSet, "cards", TableTypes.CARD_IMPORT_TYPE, new { });
        }
    }
}

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
    public class VehicleGuestRepository : UniBaseRepository, IVehicleGuestRepository
    {

        public VehicleGuestRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        public Task<CommonViewInfo> GetVehicleFilter()
        {
            const string storedProcedure = "vehicle_guest_filter";
            return base.GetTableFilterAsync(storedProcedure, new { });
        }
        //public async Task<CommonDataPage> GetResidentVehiclePage(VehicleGuestFilter query)
        //{
        //    const string storedProcedure = "sp_res_vehicle_guest_page";
        //    return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.PartnerId, query.Status, DateFilter = query.IsFilterDate, query.EndDate });
        //}
        public async Task<CommonDataPage> GetVehiclePage(VehicleGuestFilter query)
        {
            const string storedProcedure = "sp_res_vehicle_guest_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.PartnerId, query.Status, DateFilter = query.IsFilterDate, query.EndDate });
        }
        public async Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_guest_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { id = CardVehicleId, cardVehicleOid });
        }
        public async Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info)
        {
            const string storedProcedure = "sp_res_vehicle_guest_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { CardVehicleId = info.GetValueByFieldName("CardVehicleId") });
        }
        public async Task<BaseValidate> SetVehicleLocked(int CardVehicleId, int Status, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_guest_loked";
            return await SetAsync(storedProcedure, new { CardVehicleId, Status, cardVehicleOid });
        }
        public async Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string startDate, string endDate, string ProjectCd)
        {
            const string storedProcedure = "sp_res_vehicle_guest_payment_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { CardVehicleId, startDate, endDate, ProjectCd });
        }
        public async Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info)
        {
            const string storedProcedure = "sp_res_vehicle_guest_payment_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.CardVehicleId });
        }
        public async Task<BaseValidate> DelVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_guest_del";
            return await DeleteAsync(storedProcedure, new { cardVehicleId, cardVehicleOid });
        }
        public async Task<DataSet> GetVehicleCardBaseImportTemp()
        {
            const string storedProcedure = "sp_res_vehicle_guest_imports_temp";
            return await GetDataSetAsync(storedProcedure);
        }
        public async Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet importSet)
        {
            const string storedProcedure = "sp_res_vehicle_guest_import";
            return await base.SetImport<CardVehicleImportItem, CardVehicleImportSet>(storedProcedure,
                importSet, "cards", TableTypes.CARD_IMPORT_TYPE, new { });
        }
    }
}

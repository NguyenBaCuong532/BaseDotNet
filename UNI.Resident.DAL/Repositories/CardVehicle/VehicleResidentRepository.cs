using System;
using System.Data;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.CardVehicle
{
    public class VehicleResidentRepository : ResidentBaseRepository, IVehicleResidentRepository
    {

        public VehicleResidentRepository(IResidentCommonBaseRepository common) : base(common, false)
        {
        }
        public Task<CommonViewInfo> GetVehicleFilter()
        {
            const string storedProcedure = "vehicle_resident_filter";
            return base.GetTableFilterAsync(storedProcedure, new { });
        }

        public async Task<CommonDataPage> GetVehiclePage(ResidentVehicleRequestModel query)
        {
            const string storedProcedure = "sp_res_vehicle_resident_page";
            return await GetDataListPageAsync(storedProcedure, query,
                new { query.EndDate, query.IsFilterDate, query.VehicleTypeId, query.ProjectCd, query.Statuses });
        }
        public async Task<VehicleCardInfo> GetVehicleInfo(int? CardVehicleId, VehicleCardInfo info = null, Guid? cardVehicleOid = null)
        {
            var objParam = info != null ? info.ToObject() : new { CardVehicleId, cardVehicleOid };
            const string storedProcedure = "sp_res_vehicle_resident_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure,
                objParams: objParam,
                parametersHandler: param =>
                {
                    param.Add("@projectCd", base.ProjectCode);
                    if (cardVehicleOid.HasValue) param.Add("@cardVehicleOid", cardVehicleOid.Value);
                    return param;
                });
        }
        public async Task<BaseValidate> SetVehicleInfo(VehicleCardInfo info, string projectCd)
        {
            const string storedProcedure = "sp_res_card_vehicle_set1";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { CardVehicleId = info.GetValueByFieldName("CardVehicleId"), projectCd });
        }
        public async Task<BaseValidate> SetVehicleLockedAsync(int CardVehicleId, int Status, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_card_vehicle_loked";
            return await SetAsync(storedProcedure, new { CardVehicleId, Status, cardVehicleOid });
        }
        public async Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string startDate, string endDate, string ProjectCd)
        {
            const string storedProcedure = "sp_res_vehicle_resident_payment_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { CardVehicleId, startDate, endDate, ProjectCd });
        }
        public async Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info)
        {
            const string storedProcedure = "sp_res_vehicle_resident_payment_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.CardVehicleId });
        }
        public async Task<BaseValidate> DeleteVehicleInfo(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_card_vehicle_del";
            return await DeleteAsync(storedProcedure, new { cardVehicleId, cardVehicleOid });
        }
        public async Task<DataSet> GetVehicleCardBaseImportTemp()
        {
            const string storedProcedure = "sp_res_vehicle_resident_imports_temp";
            return await GetDataSetAsync(storedProcedure);
        }
        public async Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet importSet)
        {
            const string storedProcedure = "sp_res_vehicle_resident_import";
            return await base.SetImport<CardVehicleImportItem, CardVehicleImportSet>(storedProcedure,
                importSet, "cards", TableTypes.CARD_IMPORT_TYPE, new { });
        }

        public async Task<VehicleCardInfo> GetVehicleLockInfo(int? cardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_vehicle_lock_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { cardVehicleId, cardVehicleOid });
        }

        /// <summary>
        /// Thông tin hủy thẻ xe
        /// </summary>
        /// <param name="cardVehicleId"></param>
        /// <returns></returns>
        public async Task<CommonViewInfo> GetCancelVehicleCardFields(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_mas_cancel_vehicle_card_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { CardVehicleId = cardVehicleId.ToString(), cardVehicleOid });
        }

        /// <summary>
        /// Lưu thông tin hủy thẻ xe
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetCancelVehicleCardFields(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_mas_cancel_vehicle_card_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, info.ConvertToParam());
        }
    }
}
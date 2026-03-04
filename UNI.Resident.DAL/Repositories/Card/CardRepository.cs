using Dapper;
using DapperParameters;
using DocumentFormat.OpenXml.EMMA;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardRepository : ResidentBaseRepository, ICardRepository
    {
        //protected ILogger<CardRepository> _logger;
        protected string _connectionString;

        public CardRepository(IConfiguration configuration, IResidentCommonBaseRepository common) : base(common, false)
        {
            _connectionString = configuration.GetConnectionString("SHomeConnection");
            //_logger = logger;
        }
        #region web-Card

        public async Task<CommonDataPage> GetCardPageAsync(FamilyCardRequestModel query)
        {
            const string storedProcedure = "sp_res_card_family_page";
            return await GetDataListPageAsync(storedProcedure, query, new
            {
                query.ApartmentId,
                query.apartOid,
                HostUrl = base.CommonInfo.hostUrl
            });
        }
        public async Task<FamilyCardInfo> GetCardInfoAsync(string CardCd, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_family_field";
            return await GetFieldsAsync<FamilyCardInfo>(storedProcedure, new { CardCd, cardOid, HostUrl = base.CommonInfo.hostUrl });
        }
        public async Task<BaseValidate> SetCardInfoAsync(FamilyCardInfo info)
        {
            const string storedProcedure = "sp_res_card_family_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info,
                new { custId = info.GetValueByFieldName("CustId"), cardCd = info.GetValueByFieldName("CardCd") });
        }
        public async Task<BaseValidate> DeleteCardAsync(string CardCd)
        {
            const string storedProcedure = "sp_res_card_apartment_del";
            return await DeleteAsync(storedProcedure, new { CardCd });
        }
        public async Task<BaseValidate> SetCardLockedAsync(string CardCd, int Status, string Reason, bool IsHardLock)
        {
            const string storedProcedure = "sp_res_card_loked";
            return await SetAsync(storedProcedure, new { CardCd, Status, Reason, IsHardLock });
        }

        /// <summary>
        /// Gửi yêu cầu đóng thẻ gửi xe
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetCardReturnRequest(CardVehicle_CardReturnRequest inputParam)
            => SetAsync("sp_res_card_vehicle_set_card_return_request", inputParam);

        public async Task<CommonDataPage> GetVehicleCardPageAsync(VehicleCardRequestModel query)
        {
            const string storedProcedure = "sp_res_card_vehicle_page_bycd";
            return await GetDataListPageAsync(storedProcedure, query, new { query.CardCd });
        }
        public async Task<VehicleCardInfo> GetVehicleCardInfoAsync(int? CardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_card_vehicle_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { CardVehicleId, cardVehicleOid });
        }
        public async Task<BaseValidate> SetVehicleCardInfoAsync(VehicleCardInfo info, string projectCd)
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
            const string storedProcedure = "sp_res_card_vehicle_paymentByDay_field";
            return await GetFieldsAsync<VehicleCardInfo>(storedProcedure, new { CardVehicleId, startDate, endDate, ProjectCd });
        }
        public async Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info)
        {
            const string storedProcedure = "sp_res_card_vehicle_paymentByDay_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.CardVehicleId });
        }
        public async Task<BaseValidate> DeleteVehicleCardAsync(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_card_vehicle_del";
            return await DeleteAsync(storedProcedure, new { cardVehicleId, cardVehicleOid });
        }
        public async Task<CardInfoV2> GetCardInfoV2(string RoomCd)
        {
            const string storedProcedure = "sp_res_card_field";
            return await GetFieldsAsync<CardInfoV2>(storedProcedure, new { RoomCd });
        }
        public async Task<BaseValidate> SetCardInfoV2(CardInfoV2 info)
        {
            const string storedProcedure = "sp_res_card_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.RoomCd });
        }
        public CommonViewInfo GetResidentVehicleFilter(string userId)
        {
            const string storedProcedure = "resident_vehicle_filter";
            return GetTableFilterAsync(storedProcedure, new { }).Result;
        }
        /// <summary>
        /// Xe cư dân
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetResidentVehiclePage(ResidentVehicleRequestModel query)
        {
            const string storedProcedure = "sp_res_resident_vehicle_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.Statuses, query.VehicleTypeId, DateFilter = query.IsFilterDate, query.EndDate });
        }
        public CommonViewInfo GetResidentCardFilter(string userId)
        {
            const string storedProcedure = "sp_res_resident_card_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { }).Result;
        }

        public async Task<CommonDataPage> GetResidentCardPage(FilterCardResident query)
        {
            const string storedProcedure = "sp_res_card_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, roomCd = query.apartmentId, Statuses = query.Statuses, vehicle = query.isVehicle });
        }

        public async Task<CommonDataPage> GetGuestCardPageAsync(CardGuestFilter query)
        {
            const string storedProcedure = "sp_res_card_guest_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, partner_id = query.PartnerId, Statuses = query.Status });
        }

        public async Task<CommonViewInfo> GetInfoAsync(string cardType, string cardCode)
        {
            const string storedProcedure = "sp_res_card_guest_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { cardType, cardCode, project_code = base.ProjectCode });
        }

        public async Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_guest_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { CustId = info.GetValueByFieldName("CustId") });
        }

        public async Task<ImportListPage> ImportAsync(CardImportSet importSet)
        {
            const string storedProcedure = "sp_res_card_base_import";
            return await base.SetImport<CardImportItem, CardImportSet>(storedProcedure,
                importSet, "cards", TableTypes.CARD_IMPORT_TYPE, new { });
            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@accept", cards.Accept);
            //    param.AddTable("cards", TableTypes.CARD_IMPORT_TYPE, cards.Imports);
            //    if (cards.ImportFile != null)
            //    {
            //        param.AddDynamicParams(cards.ImportFile);
            //    }
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();

            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    page.dataList = (await result.ReadAsync<object>()).ToList();
            //    page.importFile = result.ReadFirst<uImportFile>();
            //    return page;
            //});
        }

        //public async Task<CommonDataPage> GetCardBasePageAsync(FilterBase filter)
        //{
        //    const string storedProcedure = "sp_res_card_base_page";
        //    return await GetDataListPageAsync(storedProcedure, filter, new {});
        //}

        //public async Task<BaseValidate> GetCardBaseAsync(CardClassificationInfo info)
        //{

        //    const string storedProcedure = "sp_res_card_base_set";
        //    return await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, param =>
        //    {
        //        param.AddTable("ids", TableTypes.GUID_LIST, info.Ids);
        //        param.Add("projectCode", info.GetDatetimeValueByFieldName("projectCode"));
        //        param.Add("type", info.GetDatetimeValueByFieldName("type"));
        //        return param;
        //    });

        //}

        //public async Task<CardClassificationInfo> GetClassifyInfoAsync(string id)
        //{
        //    const string storedProcedure = "sp_res_card_base_field";
        //    return await GetFieldsAsync<CardClassificationInfo>(storedProcedure, new { id });
        //}

        //public async Task<BaseValidate> DeleteCardBaseAsync(string id)
        //{
        //    const string storedProcedure = "sp_res_card_base_del";
        //    return await DeleteAsync(storedProcedure, new { id });
        //}

        //public async Task<DataSet> GetCardBaseImportTemp(string userId)
        //{
        //    const string storedProcedure = "sp_res_card_imports_temp";
        //    return await GetDataSetAsync(storedProcedure);
        //}
        public async Task<DataSet> GetVehicleCardBaseImportTemp(string userId)
        {
            const string storedProcedure = "sp_res_card_vehicle_imports_temp";
            return await GetDataSetAsync(storedProcedure);
        }
        public async Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet importSet)
        {
            const string storedProcedure = "sp_res_card_vehicle_import";
            return await base.SetImport<CardVehicleImportItem, CardVehicleImportSet>(storedProcedure,
                importSet, "cards", TableTypes.VEHICLE_CARD_IMPORT_TYPE, new { });
            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@accept", importSet.Accept);
            //    param.AddTable("cards", TableTypes.VEHICLE_CARD_IMPORT_TYPE, importSet.Imports);
            //    if (importSet.ImportFile != null)
            //    {
            //        param.AddDynamicParams(importSet.ImportFile);
            //    }
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();

            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    page.dataList = (await result.ReadAsync<object>()).ToList();
            //    page.importFile = result.ReadFirst<uImportFile>();
            //    return page;
            //});
        }

        public CommonViewInfo GetVehicleCardDailyFilter(string userId)
        {
            const string storedProcedure = "sp_res_card_vehicle_daily_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { }).Result;
        }

        public async Task<CommonDataPage> GetVehicleCardDailyPage(VehicleCardDailyRequestModel query)
        {
            const string storedProcedure = "sp_res_card_vehicle_daily_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.Statuses });
        }
        public async Task<CommonDataPage> GetVehicleHistoryChange(VehicleHistoryChange query)
        {
            const string storedProcedure = "sp_res_card_vehicle_history_change_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.CardId });
        }

        public async Task<BaseValidate> SetVehicleLockedWithReasonAsync(int cardVehicleId, int status, string reason, bool isHardLock, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_card_vehicle_locked1";
            return await SetAsync(storedProcedure, new { cardVehicleId, status, reason, isHardLock, cardVehicleOid });
        }

        public async Task<FamilyCardInfo> GetCardLockInfoAsync(string cardCd, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_card_lock_field";
            return await GetFieldsAsync<FamilyCardInfo>(storedProcedure, new { cardCd, cardOid, HostUrl = base.CommonInfo.hostUrl });
        }

        public async Task<FamilyCardInfo> GetEditCardInfoAsync(string cardCd, Guid? cardOid = null)
        {
            const string storedProcedure = "sp_res_edit_card_family_field";
            return await GetFieldsAsync<FamilyCardInfo>(storedProcedure, new { cardCd, cardOid, HostUrl = base.CommonInfo.hostUrl });
        }

        public async Task<BaseValidate> SetEditCardInfoAsync(FamilyCardInfo info)
        {
            const string storedProcedure = "sp_res_edit_card_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info,
                new { custId = info.GetValueByFieldName("CustId"), cardCd = info.GetValueByFieldName("CardCd") });
        }

        public async Task<VehicleCardInfo> GetVehicleCardDraftAsync(VehicleCardInfo info)
        {
            const string storedProcedure = "sp_res_card_vehicle_field_draft";
            return await SetInfoAsync<VehicleCardInfo>(storedProcedure, info, param =>
            {
                param.Add("@CardVehicleId", info.GetValueByFieldName("CardVehicleId"));
                return param;
            });
        }
        public async Task<int> SetCardVehicleServiceAuth(HomVehicleServiceAuth card)
        {
            const string storedProcedure = "sp_Hom_Card_Vehicle_Auth";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@RequestId", card.RequestId);
                    param.Add("@CardVehicleId", card.CardVehicleId);
                    param.Add("@Status", card.Status);
                    var result = await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<CommonDataPage> GetVehicleCardServicePageAsync(VehicleCardRequestModel query)
        {
            const string storedProcedure = "sp_res_card_vehicle_service_info";
            return await GetDataListPageAsync(storedProcedure, query, new { query.CardCd });
        }

        public async Task<VehiclePaymentLoadFormInfo> GetVehiclePaymentLoadFormAsync(
    int cardVehicleId,
    Guid? paymentId,
    Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_card_vehicle_payment_load_form";

            return await GetFieldsAsync<VehiclePaymentLoadFormInfo>(
                storedProcedure,
                new
                {
                    CardVehicleId = cardVehicleId,
                    cardVehicleOid,
                    PaymentId = paymentId
                }
            );
        }

        public async Task<BaseValidate> SetVehiclePaymentSubmitAsync(
    string userId,
    string projectCd,
    VehiclePaymentSubmitRequest request)
        {
            const string storedProcedure = "sp_res_card_vehicle_payment_submit";

            return await SetAsync(
                storedProcedure,
                new
                {
                    UserID = userId,
                    ProjectCd = projectCd,
                    CardVehicleId = request.CardVehicleId,
                    StartDt = request.StartDate,
                    FirstMonthPaymentMethod = request.FirstMonthPaymentMethod
                }
            );
        }




        #endregion
    }
}

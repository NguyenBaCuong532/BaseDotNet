using System;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class VehicleCardRepository : UniBaseRepository, IVehicleCardRepository
    {
        public VehicleCardRepository(IUniCommonBaseRepository common) : base(common) { }

        #region res_card_vehicle
        public async Task<CommonViewInfo> GetInfoAsync(string type, long id, Guid? cardVehicleOid = null)
        {
            string storedProcedure = "sp_res_card_vehicle_guest_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id, cardVehicleOid });
        }

        public async Task<CommonDataPage> GetPageAsync(VehicleCardFilter query)
        {
            const string storedProcedure = "sp_res_card_vehicle_page";
            return await GetDataListPageAsync(storedProcedure, query, 
                new { query.ProjectCd, query.PartnerId, query.VehicleTypeId, query.Status, DateFilter = query.IsDateFilter, query.EndDate });
        }

        public async Task<CommonViewInfo> GetTicketInfoAsync(string cardCd, long id, Guid? cardVehicleOid = null)
        {
            string storedProcedure = "sp_res_card_vehicle_ticket_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id, cardCode = cardCd, cardVehicleOid });
        }

        public async Task<BaseValidate> SetCardVehicleServiceAuthAsync(VehicleCardAuth card)
        {
            const string storedProcedure = "sp_res_Card_Vehicle_Auth";
            return await SetAsync(storedProcedure, new { card.RequestId, card.CardVehicleId, card.Status });
        }

        public async Task<BaseValidate> SetGuestVehicleCardInfoAsync(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_card_vehicle_guest_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.id });
        }

        public async Task<CommonDataPage> GetSwipeHistoryPageAsync(VehicleCardSwipeHistoryFilter filter)
        {
            const string storedProcedure = "sp_res_card_vehicle_swipe_history_page";
            return await GetDataListPageAsync(storedProcedure, filter,
                new
                {
                    filter.ProjectCd,
                    CardCd = filter.CardCd ?? string.Empty,
                    VehicleNo = filter.VehicleNo ?? string.Empty,
                    VehicleTypeId = filter.VehicleTypeId ?? -1,
                    Status = filter.Status ?? -1,
                    StartDate = filter.StartDate.HasValue ? filter.StartDate.Value.ToString("dd/MM/yyyy") : null,
                    EndDate = filter.EndDate.HasValue ? filter.EndDate.Value.ToString("dd/MM/yyyy") : null
                });
        }

        public async Task<CommonDataPage> GetHistoryPageAsync(VehicleCardHistoryFilter filter)
        {
            const string storedProcedure = "sp_res_card_vehicle_history_page";
            return await GetDataListPageAsync(storedProcedure, filter,
                new
                {
                    filter.ProjectCd,
                    ActionType = filter.ActionType ?? -1,
                    CardCd = filter.CardCd ?? string.Empty,
                    VehicleNo = filter.VehicleNo ?? string.Empty,
                    VehicleTypeId = filter.VehicleTypeId ?? -1,
                    StartDate = filter.StartDate.HasValue ? filter.StartDate.Value.ToString("dd/MM/yyyy") : null,
                    EndDate = filter.EndDate.HasValue ? filter.EndDate.Value.ToString("dd/MM/yyyy") : null
                });
        }

        public async Task<CommonDataPage> GetPaymentHistoryPageAsync(VehicleCardPaymentHistoryFilter filter)
        {
            const string storedProcedure = "sp_res_card_vehicle_payment_history_page";
            return await GetDataListPageAsync(storedProcedure, filter,
                new
                {
                    filter.ProjectCd,
                    CardVehicleId = filter.CardVehicleId ?? -1,
                    CardCd = filter.CardCd ?? string.Empty,
                    VehicleNo = filter.VehicleNo ?? string.Empty,
                    VehicleTypeId = filter.VehicleTypeId ?? -1,
                    PaymentStatus = filter.PaymentStatus ?? -1,
                    StartDate = filter.StartDate.HasValue ? filter.StartDate.Value.ToString("dd/MM/yyyy") : null,
                    EndDate = filter.EndDate.HasValue ? filter.EndDate.Value.ToString("dd/MM/yyyy") : null
                });
        }
        #endregion res_card_vehicle
    }
}

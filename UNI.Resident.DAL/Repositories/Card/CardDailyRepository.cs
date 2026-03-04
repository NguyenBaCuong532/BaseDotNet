using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Card
{
    public class CardDailyRepository : UniBaseRepository, ICardDailyRepository
    {
        //protected ILogger<CardRepository> _logger;

        public CardDailyRepository(IUniCommonBaseRepository common) : base(common)
        {
            //_logger = logger;
        }
        #region web-Card

        public CommonViewInfo GetVehicleCardDailyFilter()
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
            return await GetDataListPageAsync(storedProcedure, query, new { query.CardId, query.cardOid });
        }

        #endregion
    }
}

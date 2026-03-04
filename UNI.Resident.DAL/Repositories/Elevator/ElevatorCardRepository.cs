using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Elevator;

namespace UNI.Resident.DAL.Repositories.Elevator
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IElevatorRepository" />
    public class ElevatorCardRepository : UniBaseRepository, IElevatorCardRepository
    {

        public ElevatorCardRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        public async Task<ElevatorCardInfo> GetElevatorCardsDraft(ElevatorCardInfo card)
        {
            const string storedProcedure = "sp_res_elevator_card_get";
            return await GetFieldsAsync<ElevatorCardInfo>(storedProcedure, card.ToObject());
        }
        public async Task<ElevatorCardInfo> GetElevatorCardsInfo(string cardId)
        {
            const string storedProcedure = "sp_res_elevator_card_get";
            return await GetFieldsAsync<ElevatorCardInfo>(storedProcedure, new { cardId });
        }
        public async Task<CommonViewInfo> GetElevatorCardFilter()
        {
            const string storedProcedure = "elevator_card_filter";
            return await GetTableFilterAsync(storedProcedure);
        }
        public async Task<CommonDataPage> GetElevatorCardPage(FilterElevatorDevice flt)
        {
            const string storedProcedure = "sp_res_elevator_card_page";
            return await GetDataListPageAsync(storedProcedure, flt,
                new { flt.cardId, flt.filter, flt.ProjectCd, buildingCd = flt.BuildingCd, flt.BuildZone, flt.FloorNumber });
        }
        public async Task<BaseValidate> SetElevatorCardInfo(CommonViewIdInfo info)
        {
            const string storedProcedure = "sp_res_elevator_card_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.id });
        }
        public Task<BaseValidate> DelElevatorCardInfo(IEnumerable<Guid> oids)
        {
            const string storedProcedure = "sp_res_elevator_card_del";
            var ids = string.Join(",", oids);
            return base.DeleteAsync(storedProcedure, new { Oids = ids });
        }
        public async Task<CommonViewIdInfo> GetElevatorCardInfo(string id, string cardId)
        {
            const string storedProcedure = "sp_res_elevator_card_field";
            return await GetFieldsAsync<CommonViewIdInfo>(storedProcedure, new { id, cardId });
        }
        public async Task<CommonViewIdInfo> SetElevatorCardDraft(CommonViewIdInfo info)
        {
            const string storedProcedure = "sp_res_elevator_card_draft";
            return await SetInfoAsync<CommonViewIdInfo>(storedProcedure, info, param =>
            {
                param.Add("id", info.id);
                return param;
            });
        }
        public async Task<List<CommonValue>> GetElevatorCards(string cardId, string filter)
        {
            const string storedProcedure = "sp_res_elevator_card_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { cardId, filter });
        }
    }
}

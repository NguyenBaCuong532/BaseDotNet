using Dapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories.App
{
    public class AppCardRepository : UniBaseRepository, IAppCardRepository
    {
        protected ILogger<AppCardRepository> _logger;
        private IHostingEnvironment _environment;
        private FlexcellUtils flexcellUtils;
        private readonly IFirebaseRepository _notifyRepository;
        private readonly INotifyRepository _appRepository;

        public AppCardRepository(IUniCommonBaseRepository common,
            IConfiguration configuration,
            ILogger<AppCardRepository> logger,
            IFirebaseRepository notifyRepository,
            INotifyRepository appRepository,
            IHostingEnvironment environment) : base(common)
        {
            _notifyRepository = notifyRepository;
            _appRepository = appRepository;
            _environment = environment;
            _logger = logger;
            flexcellUtils = new FlexcellUtils();
        }
        #region app-apartment-reg
        public async Task<PageFamilyCard> GetPageFamilyCardAsync(int? ApartmentId)
        {
            const string storedProcedure = "sp_Hom_App_FamilyCard_ByUserId";
            var cards = await GetListAsync<HomCardGet>(storedProcedure, new { ApartmentId });
            return new PageFamilyCard { Cards = cards };
        }
        #endregion

        #region card-reg
        public async Task<List<HomCardType>> GetCardTypesAsync()
        {
            const string storedProcedure = "sp_Hom_Card_Types";
            return await GetListAsync<HomCardType>(storedProcedure, new {});
        }
        public async Task<int> SetCardBaseAsync(CardBase card)
        {
            const string storedProcedure = "sp_Hom_Card_Base_Set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { card.CardNum, card.Code });
        }
        public async Task<long> SetCardRegisterAsync(HomCardRegSet cardSet)
        {
            const string storedProcedure = "sp_Hom_Card_Reg";
            var param = new DynamicParameters();
            //param.Add("@UserID", userId);
            param.Add("@ApartmentId", cardSet.ApartmentId);
            param.Add("@RequestId", cardSet.RequestId);
            param.Add("@CifNo", cardSet.CifNo);
            param.Add("@CardType", cardSet.CardTypeId);
            param.Add("@IsVehicle", cardSet.IsVehicle);
            if (cardSet.RegVehicle != null)
            {
                param.Add("@VehicleTypeId", cardSet.RegVehicle.VehicleTypeId);
                param.Add("@VehicleNo", cardSet.RegVehicle.VehicleNo);
                param.Add("@ServiceId", cardSet.RegVehicle.ServiceId);
                param.Add("@VehicleName", cardSet.RegVehicle.VehicleName);
            }
            if (cardSet.RegCredit != null)
            {
                param.Add("@CifNo2", cardSet.RegCredit.CifNo2);
                param.Add("@CreditLimit", cardSet.RegCredit.CreditLimit);
                param.Add("@SalaryAvg", cardSet.RegCredit.SalaryAvg);
                param.Add("@IsSalaryTranfer", cardSet.RegCredit.IsSalaryTranfer);
                param.Add("@ResidenProvince", cardSet.RegCredit.ResidenProvince);
            }
            param.Add("@OutRequestId", 0, DbType.Int64, ParameterDirection.InputOutput);
            await SetAsync(storedProcedure, param);
            return param.Get<long>("@OutRequestId");
        }
        public async Task<BaseValidate> SetCardLostAsync(HomCardBase card)
        {
            const string storedProcedure = "sp_Hom_Card_Losted";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { card.CardCd });
        }
        public async Task SetCardLockedAsync(HomCardLock card)
        {
            const string storedProcedure = "sp_Hom_Card_Loked";
            await SetAsync(storedProcedure, new { card.CardCd, card.Status });
        }
        public async Task<BaseValidate> DeleteCardAsync(string cardCd)
        {
            const string storedProcedure = "sp_Hom_Card_Del";
            return await DeleteAsync(storedProcedure, new { cardCd });
        }
        public async Task<HomCardService> GetCardDetailAsync(string cardCd)
        {
            const string storedProcedure = "sp_Hom_Card_Resident_Get";
            return await GetMultipleAsync<HomCardService>(storedProcedure, new { cardCd }, async reader =>
            {
                var cardServ = await reader.ReadFirstOrDefaultAsync<HomCardService>();
                if (cardServ != null)
                {
                        cardServ.GeneralServices = (await reader.ReadAsync<HomServiceModel>()).ToList();
                        cardServ.VehicleServices = reader.Read<HomServiceVehicleGet>().ToList();
                        cardServ.ExtendServices = reader.Read<HomCardServiceExtGet>().ToList();
                        cardServ.CreditService = reader.ReadFirstOrDefault<HomCardRegCredit>();
                }
                return cardServ;
            });
        }
        public async Task<BaseValidate> SetCardServiceVehicleAsync(HomServiceVehicleSet vehicle)
        {
            const string storedProcedure = "sp_Hom_Card_Vehicle_Set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, vehicle );
        }
        public async Task<List<HomVehicle>> GetVehiclesAsync(int VehicleType)
        {
            const string storedProcedure = "sp_Hom_Vehicle_Type_Get";
            return await GetListAsync<HomVehicle>(storedProcedure, new { VehicleType });
        }
        public async Task<List<HomVehicleType>> GetVehicleTypesAsync()
        {
            const string storedProcedure = "sp_Hom_Vehicle_Type_List";
            return await GetListAsync<HomVehicleType>(storedProcedure, new {});
        }
        public async Task<List<HomStatus>> GetVehicleStatusAsync()
        {
            const string storedProcedure = "sp_Hom_Vehicle_Status_List";
            return await GetListAsync<HomStatus>(storedProcedure, new {});
        }
        public async Task SetCardServiceVehicleChangeAsync(HomCardServiceVehChange change)
        {
            const string storedProcedure = "sp_Hom_Card_Vehicle_Change";
            await SetAsync(storedProcedure, new { change.CardVehicleId, change.CardId });
        }
        public async Task SetVehiclePaymentAsync(HomVehiclePaySet payment)
        {
            const string storedProcedure = "sp_Hom_Vehicle_Pay_Set";
            await SetAsync(storedProcedure, payment);
        }
        public async Task<HomVehiclePaySet> GetVehiclePaymentViewAsync(string cardVehicleId, string endDate, string projectCd)
        {
            const string storedProcedure = "sp_Hom_Vehicle_Pay_Get";
            return await GetFirstOrDefaultAsync<HomVehiclePaySet>(storedProcedure, new { cardVehicleId, endDate, projectCd });
        }
        #endregion
    }
}

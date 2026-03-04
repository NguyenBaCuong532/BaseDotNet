using DapperParameters;
using Microsoft.AspNetCore.Hosting;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Repositories.CardVehicle
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="ICardVehicleExtRepository" />
    public class CardVehicleExtRepository : UniBaseRepository, ICardVehicleExtRepository
    {

        public CardVehicleExtRepository(IUniCommonBaseRepository common,
            IHostingEnvironment environment) : base(common)
        {
        }
       
        #region card-reg
        
        public async Task SetCardLocked(string userId, HomCardLock card)
        {
            const string storedProcedure = "sp_Hom_Card_Loked";
            await SetAsync(storedProcedure, new { card.CardCd, Status = card.Status });
        }

        public async Task<BaseValidate> DeleteCard(string userId, string cardCd)
        {
            const string storedProcedure = "sp_Hom_Card_Del";
            return await DeleteAsync(storedProcedure, new { cardCd });
        }

        #endregion card-reg

        #region card vehicle

        public async Task<BaseValidateForHrm> SetCardVehicle(string userId, CommonViewInfo info)
        {
            const string storedProcedure = "sp_Hom_Card_vehicle_Resident_Set";
            return await SetAsync<BaseValidateForHrm>(storedProcedure, param =>
            {
                param.Add("@CardCd", info.GetValueByFieldName("CardCd"));
                param.Add("@CustId", info.GetValueByFieldName("CustId"));
                param.Add("@CardTypeId", info.GetValueByFieldName("CardTypeId"));
                param.Add("@IssueDate", info.GetValueByFieldName("IssueDate"));
                param.Add("@ExpireDate", info.GetValueByFieldName("ExpireDate"));
                param.Add("@CardName", info.GetValueByFieldName("CardName"));
                param.Add("@ProjectCd", info.GetValueByFieldName("ProjectCd"));
                param.Add("@startTime", info.GetValueByFieldName("startTime"));
                param.Add("@endTime", info.GetValueByFieldName("endTime"));
                param.Add("@ServiceId", info.GetValueByFieldName("ServiceId"));
                return param;
            });
        }
        public async Task<BaseValidateForHrm> SetEmployeeVehicleRes(string userId, HomCardVehicleForSet vehicleSet)
        {
            const string storedProcedure = "sp_resident_employee_vehicle_reg";
            return await base.SetAsync<BaseValidateForHrm>(storedProcedure, param =>
            {
                param.Add("@userId", userId);
                param.Add("@CardVehicleId", vehicleSet.GetValueByFieldName("CardVehicleId"));
                param.Add("@VehicleTypeId", vehicleSet.GetValueByFieldName("VehicleTypeId"));
                param.Add("@VehicleNo", vehicleSet.GetValueByFieldName("VehicleNo"));
                param.Add("@VehicleName", vehicleSet.GetValueByFieldName("VehicleName"));
                param.Add("@VehicleColor", vehicleSet.GetValueByFieldName("VehicleColor"));
                param.Add("@isVehicleNone", vehicleSet.GetValueByFieldName("isVehicleNone"));
                param.Add("@CustId", vehicleSet.GetValueByFieldName("CustId"));
                param.Add("@ProjectCd", "");
                param.Add("@Reason", vehicleSet.GetValueByFieldName("Reason"));
                param.Add("@note", vehicleSet.GetValueByFieldName("note"));
                param.Add("@CardCd", vehicleSet.GetValueByFieldName("CardCd"));
                param.Add("@StartTime", vehicleSet.GetValueByFieldName("StartTime"));
                param.Add("@EndTime", vehicleSet.GetValueByFieldName("EndTime"));
                param.AddTable("@ImageLinks", "VehicleImageType", vehicleSet.ImageVehicle);
                return param;
            });
        }

        public async Task<List<CommonValue>> GetCardVehicle(string userId, string CustId)
        {
            const string storedProcedure = "sp_resident_card_for_customer";
            return await GetListAsync<CommonValue>(storedProcedure, new { userId, CustId });
        }

        public async Task<BaseValidate> SetVehicleRegCancel(string userId, HomVehicleRegCancel regSet)
        {
            const string storedProcedure = "sp_resident_employee_vehicle_del";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { userId, CardVehicleId = regSet.CardVehicleId });
        }

        public async Task SetVehicleApprove(HomVehicleApprove vehicle)
        {
            const string storedProcedure = "sp_resident_employee_vehicle_approve";
            await SetAsync(storedProcedure, new { vehicle.CardVehicleId, vehicle.CardCd, vehicle.EndTime });
        }

        public async Task<BaseValidate> SetVehicleLockRes(string userId, HomVehicleLock vehicle)
        {
            const string storedProcedure = "sp_Hom_Vehicle_Loked_For_Hrm";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { CardVehicleId = vehicle.CardVehicleId, Status = vehicle.StatusLock });
        }

        public async Task<ImportListPage> SetCardsAcceptRes(string userId, homeCardsImportSet importSet)
        {
            const string storedProcedure = "sp_hom_cards_imports";
            return await base.SetImport<homeCardsImportItem, homeCardsImportSet>(storedProcedure,
                importSet, "cards", "CardsImportType", new { });
            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@accept", importSet.accept);
            //    //if (cards.importFile != null)
            //    //{
            //    //    param.AddDynamicParams(vehicleNumImport.importFile);
            //    //}
            //    param.AddTable("@cards", "CardsImportType", importSet.imports);
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();
            //    //page.importFile = vehicleNumImport.importFile;
            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    var list = (await result.ReadAsync<object>()).ToList();
            //    page.dataList = list;
            //    return page;
            //});
        }

        public async Task<ImportListPage> SetCardVehicleAcceptRes(string userId, homCardVehicleImportSet importSet)
        {
            const string storedProcedure = "sp_hom_card_vehicle_imports";
            return await base.SetImport<homCardVehicleImportItem, homCardVehicleImportSet>(storedProcedure,
                importSet, "cards", "CardVehicleImportType", new { });

            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@accept", importSet.accept);
            //    //if (cards.importFile != null)
            //    //{
            //    //    param.AddDynamicParams(vehicleNumImport.importFile);
            //    //}
            //    param.AddTable("@cards", "CardVehicleImportType", importSet.imports);
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();
            //    //page.importFile = vehicleNumImport.importFile;
            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    var list = (await result.ReadAsync<object>()).ToList();
            //    page.dataList = list;
            //    return page;
            //});
        }

        public async Task SetCustomerResident(string userId, homCustomerInfo cust)
        {
            const string storedProcedure = "sp_Hom_Mas_Customer_Set";
            await SetAsync(storedProcedure, cust );
        }

        #endregion

        #region app

        public async Task<BaseValidateForHrm> SetVehicleRegisterRes(string userId, homVehicleRegSetApp vehicle)
        {
            const string storedProcedure = "sp_hom_app_card_vehicle_reg";
            return await GetFirstOrDefaultAsync<BaseValidateForHrm>(storedProcedure, param =>
            {
                param.Add("@UserId", vehicle.userId);
                param.Add("@CardVehicleId", vehicle.CardVehicleId);
                param.Add("@CardCd", vehicle.CardCd);
                param.Add("@VehicleTypeId", vehicle.VehicleTypeId);
                param.Add("@VehicleNo", vehicle.VehicleNo);
                param.Add("@VehicleName", vehicle.VehicleName);
                param.Add("@VehicleColor", vehicle.VehicleColor);
                param.Add("@Note", vehicle.Note);
                param.AddTable("@ImageLinks", "VehicleImageType", vehicle.ImageLinks);
                return param;
            });
        }

        public async Task<BaseValidate> LockVehicleRes(string userId, HomAppVehicleLock vehicle)
        {
            const string storedProcedure = "sp_hom_app_card_vehicle_lock";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, 
                new { vehicle.Reason, CardVehicleId = vehicle.CardVehicleId, Status = vehicle.Status });
        }

        #endregion

        
    }
}

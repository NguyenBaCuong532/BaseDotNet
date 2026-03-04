using Dapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.SHome;

namespace UNI.Resident.DAL.Repositories
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="ISHomeRepository" />
    public class SHomeRepository : ISHomeRepository
    {
        protected string _connectionString;
        protected ILogger<SHomeRepository> _logger;

        public SHomeRepository(IConfiguration configuration,
            ILogger<SHomeRepository> logger,
            IHostingEnvironment environment)
        {
            _connectionString = configuration.GetConnectionString("SHomeConnection");
            _logger = logger;
        }
        #region app-apartment-reg
        public async Task SetApartmentReg(BaseCtrlClient clt, HomApartmentReg reg)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Reg";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", clt.UserId);
                    param.Add("@roomCode", reg.roomCode);
                    param.Add("@contractNo", reg.contractNo);
                    param.Add("@relationId", reg.relationId);
                    param.Add("@id", reg.id);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                    if (valid.notiQue)
                    {
                        var notiTake = result.ReadFirstOrDefault<AppNotifyTake>();
                        if (notiTake != null)
                        {
                            notiTake.appUsers = result.Read<PushNotifyUser>().ToList();
                            //await _appRepository.TakeNotification(notiTake);
                        }
                    }
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomApartmentPageHome GetApartmentPageHome(string userId, string language)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Home";
            try
            {

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@language", language);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.ReadFirstOrDefault<HomApartmentPageHome>();
                    if (data != null)
                    {
                        data.Profile = result.ReadFirstOrDefault<HomFamilyProfile>();
                        data.registed = result.ReadFirstOrDefault<HomApartmentRegGet>();
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public homApartmentPage GetApartmentList(string userId)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var data = new homApartmentPage();
                    data.apartments = connection.Query<homApartmentShort>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetApartmentMain(string userId, HomApartmentStatus main)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Main_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    param.Add("@ApartmentId", main.ApartmentId);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public homApartmentCartPage GetApartmentCart(string userId)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Cart_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var data = new homApartmentCartPage();
                    data.apartments = connection.Query<homApartmentCart>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public homApartmentCartDetail GetApartmentCartDetail(string userId, string language, string roomCd)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Cart_Get";
            try
            {

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@roomCd", roomCd);
                    param.Add("@language", language);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.ReadFirstOrDefault<homApartmentCartDetail>();
                    if (data != null)
                    {
                        //data.contract = result.ReadFirstOrDefault<homContractShort>();
                        //data.payments = result.Read<SchedulePay>().ToList();
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public PageRequestFix GetPageRequest(FilterBaseApartment filter)
        {
            const string storedProcedure = "sp_Hom_App_Request_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", filter.userId);
                    param.Add("@ApartmentId", filter.ApartmentId);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var reqPage = new PageRequestFix();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var requestList = result.Read<HomRequestFix>().ToList();
                    reqPage.Requests = new ResponseList<List<HomRequestFix>>(requestList, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return reqPage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<HomApartmentMemberGet> SetMemberProfile(string userId, HomMemberProfileSet face)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Member_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@CustId", face.CustId);
                    param.Add("@FaceId", face.FaceId);
                    param.Add("@AvatarUrl", face.AvatarUrl);
                    param.Add("@FullName", face.FullName);
                    param.Add("@Phone", face.Phone);
                    param.Add("@Email", face.Email);
                    param.Add("@Address", face.Address);
                    param.Add("@Sex", face.Sex);
                    param.Add("@Birthday", face.Birthday);
                    param.Add("@FaceRecogUrl1", face.FaceRecogUrl1);
                    param.Add("@FaceRecogUrl2", face.FaceRecogUrl2);
                    param.Add("@FaceRecogUrl3", face.FaceRecogUrl3);
                    param.Add("@FaceRecogUrl4", face.FaceRecogUrl4);
                    param.Add("@FaceRecogUrl5", face.FaceRecogUrl5);
                    param.Add("@ApartmentId", 0);
                    param.Add("@RelationId", face.RelationId);
                    var result = await connection.QueryFirstAsync<HomApartmentMemberGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public PageFamilyMember GetPageFamilyMember(string userId, int? ApartmentId)
        {
            const string storedProcedure = "sp_Hom_App_FamilyMember_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ApartmentId", ApartmentId);
                    var memberPage = new PageFamilyMember();
                    memberPage.Members = connection.Query<HomApartmentMemberGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return memberPage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public PageFamilyCard GetPageFamilyCard(string userId, int? ApartmentId)
        {
            const string storedProcedure = "sp_Hom_App_FamilyCard_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ApartmentId", ApartmentId);
                    var cardPage = new PageFamilyCard();
                    cardPage.Cards = connection.Query<HomCardGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return cardPage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<HomServiceVehicleGet> GetPageServiceVehicles(string userId, int? ApartmentId)
        {
            const string storedProcedure = "sp_Hom_App_ServiceVehicle_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ApartmentId", ApartmentId);
                    return connection.Query<HomServiceVehicleGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        public PagePayment GetPagePayment(FilterBasePayment filter)
        {
            const string storedProcedure = "sp_Hom_App_Payment_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@ApartmentId", filter.ApartmentId);
                    param.Add("@payType", filter.payType);
                    param.Add("@month", filter.Month);
                    param.Add("@year", filter.Year);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var shopPage = new PagePayment();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var paylist = result.Read<HomReceivable>().ToList();
                    shopPage.Payments = new ResponseList<List<HomReceivable>>(paylist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return shopPage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomPaymentGet GetPaymentDetail(string userId, long receiveId)
        {
            const string storedProcedure = "sp_Hom_App_Payment_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@receiveId", receiveId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var pay = result.ReadFirstOrDefault<HomPaymentGet>();
                    if (pay != null)
                    {
                        pay.apartmentFee = result.ReadFirstOrDefault<HomPaymentApartmentFee>();
                        pay.ServiceVehicle = result.Read<HomPaymentServiceVehicle>().ToList();
                        pay.ServiceLiving = result.Read<HomPaymentServiceLiving>().ToList();
                        pay.ServiceExtend = result.Read<HomPaymentServiceExtend>().ToList();
                        if (pay.ServiceLiving != null)
                        {
                            var callist = result.Read<HomServiceLivingCalSheet>().ToList();
                            foreach (var sl in pay.ServiceLiving)
                            {
                                sl.calSheets = callist.Where(c => c.TrackingId == sl.TrackingId).ToList();
                            }
                        }
                    }
                    return pay;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomTransferInfo GetTransferInfo(string userId, long receiveId)
        {
            const string storedProcedure = "sp_Hom_App_Payment_Transfer";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@receiveId", receiveId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var pay = result.ReadFirstOrDefault<HomTransferInfo>();
                    return pay;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion app-apartment-reg

        #region web-apartment
        
        public List<HomApartmentRelation> GetApartmentRations(string userId)
        {
            const string storedProcedure = "sp_Hom_Apartment_Relation_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.Query<HomApartmentRelation>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //public async Task<BaseValidate> SetFamilyMember(HomApartmentMemberSet customer)
        //{
        //    const string storedProcedure = "sp_Hom_Apartment_Member_Set";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserId", userId);
        //            param.Add("@CustId", customer.custId);
        //            param.Add("@FullName", customer.FullName);
        //            param.Add("@Phone", customer.Phone);
        //            param.Add("@Email", customer.Email);
        //            param.Add("@AvatarUrl", customer.AvatarUrl);
        //            param.Add("@IsSex", customer.IsSex);
        //            param.Add("@Birthday", customer.Birthday);
        //            param.Add("@ApartmentId", customer.ApartmentId);
        //            param.Add("@RelationId", customer.RelationId);
        //            param.Add("@IsForeign", customer.IsForeign);
        //            param.Add("@IsNotification", customer.IsNotification);
        //            param.Add("@CountryCd", customer.CountryCd);
        //            var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            return result;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        public async Task<BaseValidate> SetFamilyMemberAuth(BaseCtrlClient clt, HomMemberBase customer)
        {
            const string storedProcedure = "sp_res_apartment_home_member_approve";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", clt.UserId);
                    param.Add("@apartmentId", customer.apartmentId);
                    param.Add("@CustId", customer.custId);
                    param.Add("@memberUserId", customer.userId);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                    if (valid.notiQue)
                    {
                        var notiTake = result.ReadFirstOrDefault<AppNotifyTake>();
                        if (notiTake != null)
                        {
                            notiTake.appUsers = result.Read<PushNotifyUser>().ToList();
                            //await _appRepository.TakeNotification(notiTake);
                        }
                    }
                    return valid;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetFamilyMemberReject(BaseCtrlClient clt, HomMemberBase customer)
        {
            const string storedProcedure = "sp_Hom_Apartment_Member_Reject";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", clt.UserId);
                    param.Add("@apartmentId", customer.apartmentId);
                    param.Add("@memberUserId", customer.userId);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                    if (valid.notiQue)
                    {
                        var notiTake = result.ReadFirstOrDefault<AppNotifyTake>();
                        if (notiTake != null)
                        {
                            notiTake.appUsers = result.Read<PushNotifyUser>().ToList();
                            //await _appRepository.TakeNotification(notiTake);
                        }
                        
                    }
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public HomApartmentMemberGet GetFamilyMember(string userId, string custId, int apartmentId)
        {
            const string storedProcedure = "sp_Hom_Apartment_Member_ByCustId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@CustId", custId);
                    param.Add("@apartmentId", apartmentId);
                    var result = connection.QueryFirstOrDefault<HomApartmentMemberGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<BaseValidate> DeleteFamilyMember(string userId, string custId, int apartmentId)
        {
            const string storedProcedure = "sp_Hom_Apartment_Member_Del";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@custId", custId);
                    param.Add("@apartmentId", apartmentId);
                    return await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"DeleteFamilyMember{ex}-param:{custId},{apartmentId}");
                throw ex;
            }
        }
        
        #endregion web-apartment

        #region card-reg
        public List<HomCardType> GetCardTypes()
        {
            const string storedProcedure = "sp_Hom_Card_Types";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    var result = connection.Query<HomCardType>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public async Task<long> SetCardRegister(string userId, HomCardRegSet cardSet)
        {
            const string storedProcedure = "sp_Hom_Card_Reg";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserID", userId);
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
                    var result = await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return param.Get<long>("@OutRequestId");
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<BaseValidate> SetCardLost(string userId, HomCardBase card)
        {
            const string storedProcedure = "sp_Hom_Card_Losted";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserID", userId);
                    param.Add("@CardCd", card.CardCd);
                    var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public HomCardService GetCardDetail(string cardCd)
        {
            const string storedProcedure = "sp_Hom_Card_Resident_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@CardCd", cardCd);
                    var cardServ = new HomCardService();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    cardServ = result.Read<HomCardService>().FirstOrDefault();
                    if (cardServ != null)
                    {
                        cardServ.GeneralServices = result.Read<HomServiceModel>().ToList();
                        cardServ.VehicleServices = result.Read<HomServiceVehicleGet>().ToList();
                        cardServ.ExtendServices = result.Read<HomCardServiceExtGet>().ToList();
                        cardServ.CreditService = result.ReadFirstOrDefault<HomCardRegCredit>();
                    }
                    return cardServ;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public async Task<BaseValidate> SetCardServiceVehicle(string userId, HomServiceVehicleSet vehicle)
        {
            const string storedProcedure = "sp_Hom_Card_Vehicle_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@CardVehicleId", vehicle.CardVehicleId);
                    param.Add("@CardCd", vehicle.CardCd);
                    param.Add("@VehicleTypeId", vehicle.VehicleTypeId);
                    param.Add("@VehicleNo", vehicle.VehicleNo);
                    param.Add("@VehicleName", vehicle.VehicleName);
                    param.Add("@ServiceId", vehicle.ServiceId);
                    param.Add("@StartTime", vehicle.StartTime);
                    param.Add("@EndTime", vehicle.EndTime);
                    param.Add("@Status", vehicle.Status);
                    param.Add("@isVehicleNone", vehicle.isVehicleNone);
                    var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        #endregion card-reg

        #region request-reg
        
        public List<HomRequestCategoryGet> GetRequestCategoryList(string userId, int categoryType, string language)
        {
            const string storedProcedure = "sp_Hom_Request_Category_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@categoryType", categoryType);
                    param.Add("@language", language);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.Read<HomRequestCategoryGet>().ToList();
                    if (data != null && data.Count > 0)
                    {
                        var rqtypes = result.Read<HomRequestType>().ToList();
                        foreach (var d in data)
                        {
                            d.RequestTypes = rqtypes.Where(r => r.RequestCategoryId == d.RequestCategoryId).ToList();
                        }
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetRequest(string userId, HomRequestSet request)
        {
            const string storedProcedure = "sp_Hom_Request_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserID", userId);
                    param.Add("@ApartmentId", request.ApartmentId);
                    param.Add("@RequestId", request.requestId);
                    param.Add("@RequestTypeId", request.RequestTypeId);
                    param.Add("@Comment", request.Comment);
                    param.Add("@IsNow", request.IsNow);
                    param.Add("@thread_id", request.thread_id);
                    if (request.AtTime != null)
                        param.Add("@AtTime", UNI.Utils.StringHelper.StringToDate(request.AtTime));
                    var result = await connection.QueryFirstOrDefaultAsync<HomRequestInfo>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    if (result != null && request.attachs != null && request.attachs.Count > 0)
                    {
                        foreach (var a in request.attachs)
                        {
                            a.requestId = result.requestId;
                            a.processId = 0;
                            await this.SetRequestAttach(userId, a);
                        }
                    }
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetRequestVoted(string userId, HomRequestVote request)
        {
            const string storedProcedure = "sp_Hom_Request_Voted";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserID", userId);
                    param.Add("@RequestId", request.requestId);
                    param.Add("@Comment", request.Comment);
                    param.Add("@rating", request.rating);
                    var result = await connection.QueryFirstOrDefaultAsync<HomRequestInfo>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    if (result != null && request.attachs != null && request.attachs.Count > 0)
                    {
                        foreach (var a in request.attachs)
                        {
                            a.requestId = result.requestId;
                            a.processId = 0;
                            await this.SetRequestAttach(userId, a);
                        }
                    }
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetRequestConfirm(string userId, HomRequestBase confirm)
        {
            const string storedProcedure = "sp_Hom_Request_Closed";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserID", userId);
                    param.Add("@RequestId", confirm.requestId);
                    //param.Add("@Comment", confirm.Comment);
                    var result = await connection.QueryFirstOrDefaultAsync<HomRequestInfo>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetRequestAttach(string userId, HomRequestAttach attach)
        {
            const string storedProcedure = "sp_Hom_Request_Attach_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    param.Add("@id", attach.id);
                    param.Add("@requestId", attach.requestId);
                    param.Add("@processId", attach.processId);
                    param.Add("@attachUrl", attach.attachUrl);
                    param.Add("@attachType", attach.attachType);
                    param.Add("@attachFileName", attach.attachFileName);
                    param.Add("@used", attach.used);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomRequest GetRequest(string userId, long requestId)
        {
            const string storedProcedure = "sp_Hom_App_Request_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@RequestId", requestId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var req = result.ReadFirstOrDefault<HomRequest>();
                    if (req != null)
                    {
                        req.attachs = result.Read<HomRequestAttach>().ToList();
                        req.Processes = result.Read<HomRequestProcessGet>().ToList();
                        if (req.IsFinished)
                        {
                            req.vote = result.ReadFirstOrDefault<HomRequestVote>();
                            if (req.vote != null)
                            {
                                req.vote.attachs = result.Read<HomRequestAttach>().ToList();
                            }
                        }
                    }
                    return req;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public async Task<HomRequestProcessGet> SetRequestProcess(string userId, HomRequestProcess process)
        {
            const string storedProcedure = "sp_Hom_Request_Process";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserID", userId);
                    param.Add("@RequestId", process.RequestId);
                    param.Add("@Comment", process.Comment);
                    param.Add("@Status", process.Status);
                    var result = connection.QueryFirstOrDefault<HomRequestProcessGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    if (process.attachs != null && process.attachs.Count > 0)
                    {
                        foreach (var a in process.attachs)
                        {
                            a.requestId = process.RequestId;
                            a.processId = result.processId;
                            await this.SetRequestAttach(userId,a);
                        }
                    }
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public HomRequestFixGet GetRequestFix(string userId, string requestId)
        {
            const string storedProcedure = "sp_Hom_Get_RequestFix_ByRequestId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@RequestId", requestId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var req = result.ReadFirstOrDefault<HomRequestFixGet>();
                    if (req != null)
                    {
                        req.Processes = result.Read<HomRequestProcessGet>().ToList();
                        req.Employees = result.Read<HomRequestEmployee>().ToList();
                    }

                    return req;

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
       
        public HomRequestSevGet GetRequestSev(string userId, string requestId)
        {
            const string storedProcedure = "sp_Hom_Get_RequestSev_ByRequestId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@RequestId", requestId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var req = result.Read<HomRequestSevGet>().FirstOrDefault();
                    if (req != null)
                    {
                        req.Processes = result.Read<HomRequestProcessGet>().ToList();

                    }
                    return req;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomRequestSev SetRequestSev(string userId, HomRequestSevSet clean)
        {
            const string storedProcedure = "sp_Hom_Insert_RequestSev";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    param.Add("@ApartmentId", clean.ApartmentId);
                    param.Add("@RequestId", clean.RequestId);
                    param.Add("@RequestTypeId", clean.RequestTypeId);
                    //param.Add("@Title", clean.Title);
                    param.Add("@Comment", clean.Comment);
                    param.Add("@IsNow", clean.IsNow);
                    param.Add("@AtTime", UNI.Utils.StringHelper.StringToDate(clean.AtTime));
                    var result = connection.QueryFirstOrDefault<HomRequestSev>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<HomRequestSevGet>> GetRequestSevList(FilterBaseManger filter)
        {
            const string storedProcedure = "sp_Hom_Get_RequestSev_List_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", filter.userId);
                    param.Add("@ProjectCd", filter.ProjectCd);
                    param.Add("@RoomCd", filter.RoomCd);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var cleanlist = result.Read<HomRequestSevGet>().ToList();
                    return new ResponseList<List<HomRequestSevGet>>(cleanlist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //app admin
        public ResponseList<List<HomRequestService>> GetRequestServiceList(FilterRequestService filter)
        {
            const string storedProcedure = "sp_Hom_Get_Request_Services";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@clientId", filter.clientId);
                    param.Add("@projectCd", filter.ProjectCd);
                    param.Add("@filter", filter.RoomCd);
                    param.Add("@statuses", filter.Statuses);
                    param.Add("@RequestKey", filter.RequestKey);
                    param.Add("@IsCardReq", filter.IsCardReq);

                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var reqlist = result.Read<HomRequestService>().ToList();
                    return new ResponseList<List<HomRequestService>>(reqlist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomRequestServiceGet GetRequestSeviceDetail(string userId, string requestKey, int requestid)
        {
            var reqs = new HomRequestServiceGet();
            if (requestKey == "RequestFix")
                reqs.RequestFix = this.GetRequestFix(userId, requestid.ToString());
            else if (requestKey == "RequestSev")
                reqs.RequestSev = this.GetRequestSev(userId, requestid.ToString());
            else if (requestKey == "CardRegister")
                reqs.CardRegister = this.GetRequestCardReg(requestid);
            else if (requestKey == "CardAdd")
                reqs.CardVehicle = this.GetRequestCardAdd( requestid);
            else//CardLost
                reqs.CardLost = this.GetRequestCardLost(requestid);
            return reqs;
        }

        public PageRequestFix GetPageRequestFix(FilterBaseApartment filter)
        {
            const string storedProcedure = "sp_Hom_Get_Page_RequestFix_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", filter.userId);
                    param.Add("@ApartmentId", filter.ApartmentId);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var reqPage = new PageRequestFix();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var requestList = result.Read<HomRequestFix>().ToList();
                    reqPage.Requests = new ResponseList<List<HomRequestFix>>(requestList, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return reqPage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public PageRequestSev GetPageRequestSev(FilterBaseApartment filter)
        {
            const string storedProcedure = "sp_Hom_Get_Page_RequestSev_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@ApartmentId", filter.ApartmentId);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var notPage = new PageRequestSev();
                    var cleanlist = connection.Query<HomRequestSev>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    notPage.CleanUps = new ResponseList<List<HomRequestSev>>(cleanlist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return notPage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion request-reg

        #region vehicle-reg

        public List<HomVehicleType> GetVehicleTypes()
        {
            const string storedProcedure = "sp_Hom_Vehicle_Type_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    var result = connection.Query<HomVehicleType>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        #endregion vehicle-reg

        public HomRequestCardReg GetRequestCardReg(int Id)
        {
            const string storedProcedure = "sp_Hom_Get_RequestCard_Reg_ById";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@userId", userId);
                    param.Add("@requestId", Id);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var cardRegs = result.ReadFirstOrDefault<HomRequestCardReg>();
                    if (cardRegs != null)
                    {
                        cardRegs.Card = result.ReadFirstOrDefault<HomCardVehiclePar>();
                        cardRegs.CardVehicle = result.ReadFirstOrDefault<HomCardRegVehicle>();
                        cardRegs.CardCredit = result.ReadFirstOrDefault<HomCardRegCredit>();
                    }
                    return cardRegs;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomRequestCardReg GetRequestCardAdd(int requestId)
        {
            const string storedProcedure = "sp_Hom_Get_RequestCard_Add_ById";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@userId", userId);
                    param.Add("@requestId", requestId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var cards = result.ReadFirstOrDefault<HomRequestCardReg>();
                    if (cards != null)
                    {
                        cards.Card = result.ReadFirstOrDefault<HomCardVehiclePar>();
                        cards.CardVehicle = result.ReadFirstOrDefault<HomCardRegVehicle>();
                    }
                    return cards;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomRequestCardLost GetRequestCardLost(int requestId)
        {
            const string storedProcedure = "sp_Hom_Get_RequestCard_Lost_ById";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@userId", userId);
                    param.Add("@requestId", requestId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var cards = result.ReadFirstOrDefault<HomRequestCardLost>();

                    return cards;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public PageHome GetPageHome(string userId)
        {
            const string storedProcedure = "sp_Hom_Get_Page_Home_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    var homePage = new PageHome();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    homePage.Profile = result.ReadFirstOrDefault<HomFamilyProfile>();
                    if (homePage.Profile != null)
                    {
                        //homePage.wallet = result.ReadFirstOrDefault<Wallet>();
                        //if (homePage.wallet != null)
                        //{
                        //    homePage.wallet.TranferLink = result.ReadFirstOrDefault<WalBankLink>();
                        //    if (homePage.wallet.TranferLink == null)
                        //        homePage.wallet.TranferLink = new WalBankLink();
                        //}
                    }
                    return homePage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        public List<ProjectApp> GetProjects(string userId)
        {
            const string storedProcedure = "sp_Hom_Project_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.Query<ProjectApp>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<HomBuilding> GetBuildings(string projectCd)
        {
            const string storedProcedure = "sp_Hom_Building_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@userId", userId);
                    param.Add("@projectCd", projectCd);
                    return connection.Query<HomBuilding>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<HomFloor> GetFloorList(string buildingCd)
        {
            const string storedProcedure = "sp_Hom_Floor_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@userId", userId);
                    param.Add("@buildingCd", buildingCd);
                    return connection.Query<HomFloor>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<HomRoom> GetRooms(string buildingCd, string floorNo)
        {
            const string storedProcedure = "sp_Hom_Room_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@userId", userId);
                    param.Add("@buildingCd", buildingCd);
                    param.Add("@floorNo", floorNo);
                    return connection.Query<HomRoom>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #region elevator-reg
        
        public async Task SetAccessFloor(BaseCtrlClient clt, HomAccessFloor floor)
        {
            const string storedProcedure = "sp_Hom_ELE_Access_Floor";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", clt.UserId);
                    param.Add("@floorName", floor.FloorName);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public HomAccessGet GetAccessFloors(string userId, int mode)
        {
            const string storedProcedure = "sp_Hom_ELE_Access_Last_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@mode", mode);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var access = new HomAccessGet();
                    if (access != null)
                    {
                        access.floor_lasts = result.Read<HomAccessFloorLast>().ToList();
                    }
                    return access;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion elevator-reg

        public List<CommonValue> GetBaseStatus(string userId, string baseKey)
        {
            const string storedProcedure = "sp_Home_Status_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@statusKey", baseKey);
                    var result = connection.Query<CommonValue>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public Wallet GetWallet(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var wal = result.ReadFirstOrDefault<Wallet>();
                    if (wal != null)
                    {
                        wal.TranferLink = result.ReadFirstOrDefault<WalBankLink>();
                        if (wal.TranferLink == null)
                            wal.TranferLink = new WalBankLink();
                    }

                    return wal;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PointHistory_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@FilterType", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<WalPointTran>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<WalPointTran>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalPointTran GetPointTransDetail(string userId, string transNo)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PointHistory_ByNo";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@transNo", transNo);
                    return connection.QueryFirstOrDefault<WalPointTran>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }
}

using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// AppManagerRepository
    /// </summary>
    /// Author: 
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="AppManagerRepository" />
    public class AppManagerRepository : IAppManagerRepository
    {
        private readonly string _connectionString;
        private readonly IFirebaseRepository _fbRepository;
        public AppManagerRepository(
            IConfiguration configuration,
            IFirebaseRepository notifyRepository)
        {
            _connectionString = configuration.GetConnectionString("AppManagerConnection");
            _fbRepository = notifyRepository;
        }

        #region message-reg

        public async Task<int> TakeMessage(BaseCtrlClient clt, MessageBase mess)
        {
            const string storedProcedure = "sp_Message_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    if (clt != null)
                    {
                        param.Add("@userId", clt.UserId);
                        param.Add("@clientId", clt.ClientId);
                        param.Add("@ClientIp", clt.ClientIp);
                    }
                    param.Add("@phone", mess.phone);
                    param.Add("@custName", mess.custName);
                    param.Add("@message", mess.message);
                    param.Add("@scheduleAt", mess.scheduleAt);
                    param.Add("@brandName", mess.brandName);
                    param.Add("@isSent", mess.isSent);
                    param.Add("@custId", mess.custId);
                    param.Add("@sourceId", mess.sourceId);
                    param.Add("@partner", mess.partner);
                    param.Add("@remart", mess.remart);

                    return await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion message-reg

        #region email-reg

        #endregion email-reg

        #region token-reg
        public string GetUserToken(BaseCtrlClient clt, int tokenType, int mode = 0)
        {
            const string storedProcedure = "sp_User_Token_Gen";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", clt.UserId);
                    param.Add("@tokenType", tokenType);
                    param.Add("@mode", mode);
                    param.Add("@client_userid", clt.UserId);
                    param.Add("@Client_id", clt.ClientId);
                    param.Add("@Client_ip", clt.ClientIp);
                    var result = connection.QueryFirstOrDefault<string>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public userTokenMode GetUserByToken(string token, int tokenType)
        {
            const string storedProcedure = "sp_User_Token_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@token", token);
                    param.Add("@tokenType", tokenType);
                    var result = connection.QueryFirstOrDefault<userTokenMode>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public OtpMessageGet TakeOTP1(BaseCtrlClient clt, WalUserGrant registed)
        {
            const string storedProcedure = "sp_user_token_otp";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@client_userid", clt.UserId);
                    param.Add("@client_id", clt.ClientId);
                    param.Add("@client_ip", clt.ClientIp);
                    param.Add("@userId", registed.UserId);
                    param.Add("@phone", registed.Phone);
                    param.Add("@Email", registed.Email);
                    param.Add("@tokenType", registed.tokenType);
                    param.Add("@sendName", registed.sendName);
                    param.Add("@brandName", registed.brandName);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var otp = result.ReadFirstOrDefault<OtpMessageGet>();
                    if (otp != null && otp.valid)
                    {
                        if (registed.tokenType == 0 || registed.tokenType == 10000)
                        {
                            otp.optmessage = result.ReadFirstOrDefault<MessageBase>();
                        }
                        else
                        {
                            otp.otpemail = result.ReadFirstOrDefault<EmailBase>();
                        }
                    }
                    return otp;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<ResponseCode> SetVerificationCode1(string userId, userVerification code)
        {
            const string storedProcedure = "sp_user_token_verified";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@clt_userId", userId);
                    param.Add("@userId", code.userId);
                    param.Add("@code", code.verificationCode);
                    param.Add("@tokenType", code.tokenType);
                    var result = await connection.QueryFirstOrDefaultAsync<ResponseCode>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public BaseValidate SetOtpStatus(string userId, userOtpStatus status)
        {
            const string storedProcedure = "sp_user_token_status";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@clt_userId", userId);
                    param.Add("@userId", status.loginName);
                    param.Add("@status", status.status);
                    var result = connection.QueryFirstOrDefault<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        #endregion token-reg

        #region common-reg
        public async Task<int> InsetSmartDeviceProfile(SmartDeviceSet deviceprofile)
        {
            const string storedProcedure = "sp_SmartDevice_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@DeviceCd", deviceprofile.DeviceCd);
                    param.Add("@DeviceType", deviceprofile.DeviceType);
                    param.Add("@UserId", deviceprofile.UserId);
                    param.Add("@GuestId", deviceprofile.GuestId);
                    param.Add("@AppId", deviceprofile.aId);
                    param.Add("@playerId", deviceprofile.playerId);
                    var result = await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        #endregion common-reg

        #region thread-reg
        
        public async Task<fbThread> SetThreadFetch(string userId, fbThreadSet thread)
        {
            const string storedProcedure = "sp_Thread_Info_Fetch";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    param.Add("@sub_prod_cd", thread.sub_prod_cd);
                    param.Add("@project_cd", thread.project_cd);
                    param.Add("@role_cd", thread.role_cd);
                    param.Add("@cust_userid", thread.cust_userid);
                    param.Add("@room_code", thread.room_code);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.ReadFirstOrDefault<fbThread>();
                    if (data != null)
                    {
                        data.Users = result.Read<fbThreadUser>().ToList();
                        data.Customer = result.ReadFirstOrDefault<fbThreadCust>();
                        data.Saler = data.Users.Where(u => u.userId == data.saler_userId).FirstOrDefault();
                        data.Supporter = data.Users.Where(u => u.userId == data.supporter_userId).FirstOrDefault();
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //public async Task<fbThread> SetThreadInfo(string userId, fbThread thread)
        //{
        //    const string storedProcedure = "sp_Thread_Info_Set";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", userId);
        //            param.Add("@id", thread.id);
        //            param.Add("@region_id", thread.region_id);
        //            param.Add("@thread_name", thread.thread_name);
        //            param.Add("@thread_type", thread.thread_type);
        //            param.Add("@project_cd", thread.project_cd);
        //            param.Add("@project_name", thread.project_name);
        //            param.Add("@room_code", thread.room_code);
        //            param.Add("@sub_prod_cd", thread.sub_prod_cd);
        //            param.Add("@cust_userid", thread.cust_userId);
        //            param.Add("@saler_userId", thread.saler_userId);
        //            param.Add("@role_cd", thread.role_cd);
        //            param.AddTable("@users", "thread_user_type", thread.Users);
        //            var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = result.ReadFirst<fbThread>();
        //            if (data != null)
        //            {
        //                data.Users = result.Read<fbThreadUser>().ToList();
        //                data.Customer = result.ReadFirstOrDefault<fbThreadCust>();
        //                data.Saler = data.Users.Where(u => u.userId == data.saler_userId).FirstOrDefault();
        //                data.Supporter = data.Users.Where(u => u.userId == data.supporter_userId).FirstOrDefault();
        //                await _fbRepository.SetThreadCreate(data);
        //            }
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public fbThread GetThread(string userId, Guid id)
        //{
        //    const string storedProcedure = "sp_Thread_Info_Get";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserId", userId);
        //            param.Add("@id", id);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = result.ReadFirstOrDefault<fbThread>();
        //            if (data != null)
        //            {
        //                data.Users = result.Read<fbThreadUser>().ToList();
        //                data.Customer = result.ReadFirstOrDefault<fbThreadCust>();
        //                data.Saler = data.Users.Where(u => u.userId == data.saler_userId).FirstOrDefault();
        //                data.Supporter = data.Users.Where(u => u.userId == data.supporter_userId).FirstOrDefault();
        //            }
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public async Task<BaseValidate> SetThreadInvite(string userId, Guid? id, string role, List<fbThreadUser> users)
        //{
        //    const string storedProcedure = "sp_Thread_Invite_Set";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", userId);
        //            param.Add("@thread_id", id);
        //            param.Add("@role", role);
        //            param.AddTable("@users", "thread_user_type", users);
        //            var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var reponse = result.ReadFirst<BaseValidate>();
        //            if (reponse.valid)
        //            {
        //                AppNotifyTake1 take = result.ReadFirstOrDefault<AppNotifyTake1>();
        //                if (take != null)
        //                {
        //                    take.appUsers = result.Read<PushNotifyUser>().ToList();
        //                    await _fbRepository.SetNotifyPush(take);
        //                }
        //                else
        //                {
        //                    return new BaseValidate { valid = false, messages = "Không tìm thấy thông tin" };
        //                }
        //            }
        //            return reponse;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<BaseValidate> DelThreadInvite(Guid? thread_id, string userId)
        //{
        //    const string storedProcedure = "sp_Thread_Invite_Del";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", userId);
        //            param.Add("@thread_id", thread_id);
        //            var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            return result;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        public async Task<BaseValidate> SetThreadUser(string userId, fbThreadUserAdd id, fbThreadUser user)
        {
            const string storedProcedure = "sp_Thread_User_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@thread_id", id.thread_id);
                    param.Add("@role", id.role);
                    param.Add("@set_userId", user.userId);
                    param.Add("@custId", user.custId);
                    param.Add("@phone", user.phone);
                    param.Add("@email", user.email);
                    param.Add("@fullname", user.fullName);
                    param.Add("@avatar", user.avatar);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var reponse = result.ReadFirst<BaseValidate>();
                    if (reponse.valid)
                    {
                        await _fbRepository.SetThreadUser(id, user, reponse.code);
                        AppNotifyTake1 take = result.ReadFirstOrDefault<AppNotifyTake1>();
                        if (take != null)
                        {
                            take.appUsers = result.Read<PushNotifyUser>().ToList();
                            await _fbRepository.SetNotifyPush(take);
                        }
                    }
                    return reponse;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public fbThreadUser GetUserApp(string userId)
        {
            const string storedProcedure = "sp_COR_User_Profile_App_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.QueryFirstOrDefault<fbThreadUser>(storedProcedure, param, commandType: CommandType.StoredProcedure);

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<BaseValidate> DelThreadUser(string userId, fbThreadUserAdd user)
        {
            const string storedProcedure = "sp_Thread_User_Del";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@thread_id", user.thread_id);
                    param.Add("@role", user.role);
                    param.Add("@del_userId", user.userId);
                    var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    await _fbRepository.DelThreadUser(user);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion thread-reg
    }
}

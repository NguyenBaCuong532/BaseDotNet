using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Core;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.UserConfig;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// User Repository
    /// </summary>
    /// Author: taint
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="IUserRepository" />
    public class UserAppRepository1 : IUserAppRepository1
    {
        private readonly string _connectionString;

        public UserAppRepository1(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("SHomeConnection");
        }
        public UserProfileFull GetProfileById(string userId, string loginName)
        {
            const string storedProcedure = "sp_COR_User_Profile_Get_byUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    param.Add("@loginName", loginName);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var prof = result.ReadFirstOrDefault<UserProfileFull>();
                    if (prof != null)
                    {
                        prof.point = result.ReadFirstOrDefault<corePoint>();
                        prof.fields = result.Read<viewField>().ToList();
                        prof.metas = result.Read<coreUserProfileMeta>().ToList();
                        if (prof.metas == null)
                            prof.metas = new List<coreUserProfileMeta>();
                    }
                    return prof;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public async Task LockUser(string userId, bool isLock)
        {
            const string storedProcedure = "sp_User_Update_UserLoked";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@isLock", isLock);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
       
        public userProfileBase SetUserProfile(userProfileSet ureg)
        {
            const string storedProcedure = "sp_User_Insert_Register";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userLogin", ureg.userLogin);
                    param.Add("@phone", ureg.phone);
                    param.Add("@loginType", ureg.loginType);
                    param.Add("@fullName", ureg.fullName);
                    param.Add("@loginId", ureg.loginId);

                    param.Add("@custId", ureg.custId);
                    param.Add("@userId", ureg.userId);
                    param.Add("@email", ureg.email);
                    param.Add("@isVerify", ureg.isVerify);
                    param.Add("@loginSecret", null);
                    param.Add("@avatarUrl", ureg.avatarUrl);
                    param.Add("@userType", ureg.userType);
                    var result = connection.QueryFirstOrDefault<userProfileBase>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg, int user_type)
        {
            const string storedProcedure = "sp_COR_User_Login_RegNew";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.AddDynamicParams(reg);
                    param.Add("@userType", user_type);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var rlt = result.ReadFirstOrDefault<coreUserLoginResponse>();
                    return rlt;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public userProfileBase SetLoginUserId(string loginName, string userId, string loginSecret)
        {
            const string storedProcedure = "sp_User_Login_userId_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userLogin", loginName);
                    param.Add("@userId", userId);
                    param.Add("@loginSecret", loginSecret);
                    var result = connection.QueryFirstOrDefault<userProfileBase>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public userProfileSet SetVerificated(string userLogin, int tokenType)
        {
            const string storedProcedure = "sp_User_Update_Verificated";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserLogin", userLogin);
                    param.Add("@tokenType", tokenType);
                    var result = connection.QueryFirstOrDefault<userProfileSet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public userProfileSet GetUserProfile(string userLogin)
        {
            const string storedProcedure = "sp_User_Get_UserProfile";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userLogin", userLogin);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var profile = result.ReadFirstOrDefault<userProfileSet>();
                    return profile;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public List<ProjectApp> GetProjectList(string userId)
        {
            const string storedProcedure = "sp_user_project_byUser";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    var result = connection.Query<ProjectApp>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public async Task SetUserForegetPassword(userBasePhone foreget, string preFix)
        {
            const string storedProcedure = "sp_User_Update_ForegetPassword";
            try
            {
                string loginName = preFix + "_" + foreget.phone;
                if (foreget.loginName != null)
                    loginName = foreget.loginName;
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@UserLogin", loginName);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetUserAgreedTerm(userAgeedTerm term)
        {
            const string storedProcedure = "sp_User_Update_AgreedTerm";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@loginName", term.loginName);
                    param.Add("@is_Agreed_Term", term.is_Agreed_Term);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        
        public coreUserLoginResponse GetUserRegisted(string reg_id)
        {
            const string storedProcedure = "sp_COR_User_Login_RegGet";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@reg_id", reg_id);
                    var result = connection.QueryFirstOrDefault<coreUserLoginResponse>(storedProcedure, param, commandType: CommandType.StoredProcedure);

                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public userForegetResponse GetUserForgetPassword(string clientId, string loginName, string udid)
        {
            const string storedProcedure = "sp_COR_User_Login_Forget_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@clientId", clientId);
                    param.Add("@loginName", loginName);
                    param.Add("@udid", udid);
                    var result = connection.QueryFirstOrDefault<userForegetResponse>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<coreUserLoginResponse> SetUserForgetPassword(string clientId, userForegetSet forget)
        {
            const string storedProcedure = "sp_COR_User_Login_Forget_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@clientId", clientId);
                    param.Add("@loginName", forget.loginName);
                    param.Add("@phone", forget.phone);
                    param.Add("@birthday", forget.birthday);
                    param.Add("@verifyType", forget.verifyType);
                    param.Add("@udid", forget.udid);
                    var result = await connection.QueryFirstAsync<coreUserLoginResponse>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetUserForgetVerificated(coreVerify code, int user_type)
        {
            const string storedProcedure = "sp_COR_User_Login_Forget_Verify";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@reg_id", code.reg_id);
                    param.Add("@user_type", user_type);
                    var result = await connection.QueryFirstAsync<coreUserLoginResponse>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<userLoginRefesh> SetVerificated(coreVerify code, string userId)
        {
            const string storedProcedure = "sp_COR_User_Login_RegSet";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@reg_id", code.reg_id);
                    param.Add("@userId", userId);
                    param.Add("@code", code.code);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = await result.ReadFirstAsync<userLoginRefesh>();
                    if (data != null)
                    {
                        AppNotifyTake take = result.ReadFirstOrDefault<AppNotifyTake>();
                        if (take != null)
                        {
                            take.appUsers = result.Read<PushNotifyUser>().ToList();
                            //await _appRepository.TakeNotification(clt, take);
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
        public async Task<coreUserLoginResponse> SetResendCode(string reg_id)
        {
            const string storedProcedure = "sp_COR_User_Login_RegResend";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.AddDynamicParams(reg);
                    param.Add("@reg_id", reg_id);
                    var result = await connection.QueryFirstOrDefaultAsync<coreUserLoginResponse>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        #region supper app
        public List<viewField> GetProfileFields(string userId, string loginName)
        {
            const string storedProcedure = "sp_COR_User_Profile_Fields";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ProfileType", 0);
                    param.Add("@loginName", loginName);
                    var result = connection.Query<viewField>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<coreUserProfileMeta> GetProfileMetas(string userId, string loginName)
        {
            const string storedProcedure = "sp_COR_User_Profile_Meta_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    //param.Add("@ProfileType", 0);
                    param.Add("@loginName", loginName);
                    var result = connection.Query<coreUserProfileMeta>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetProfileFields(string userId, coreUserFields fields)
        {
            const string storedProcedure = "sp_COR_User_Profile_Field_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    foreach (var f in fields.fields)
                    {
                        var param = new DynamicParameters();
                        param.Add("@userId", userId);
                        param.Add("@FieldName", f.field_name);
                        param.Add("@ColumnType", f.data_type);
                        param.Add("@FieldValue", f);
                        param.Add("@loginName", fields.loginName);
                        await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    }
                }
            }
            catch (Exception ex)
            {
                //_logger.LogError($"{ex}-param:{fields}");
                throw ex;
            }
        }
        public async Task DelProfileMeta(string userId, Guid metaId)
        {
            const string storedProcedure = "sp_COR_User_Profile_Meta_Del";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@Id", metaId);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public int SetProfileMetas(string userId, coreUserMetas metas)
        {
            foreach (var met in metas.Metas)
            {
                this.SetProfileMeta(userId, met, metas.loginName, metas.meta_code);
            }
            return 1;
        }
        public int SetProfileMeta(string userId, coreUserProfileMeta met, string loginName, string meta_code)
        {
            const string storedProcedure = "sp_COR_User_Profile_Meta_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();

                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@meta_code", meta_code);
                    param.Add("@loginName", loginName);
                    param.Add("@meta_Url", met.metaUrl);
                    param.Add("@meta_Name", met.metaName);
                    param.Add("@meta_Note", met.metaNote);
                    param.Add("@doc_Type", met.doc_type);
                    param.Add("@doc_sub_type", met.doc_sub_type);
                    param.Add("@meta_type", met.metatype);
                    connection.Execute(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return 1;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetProfileIdcardAdd(string userId, coreUserIdcardSet profile)
        {
            const string storedProcedure = "sp_COR_User_Profile_Idcard_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@idcard_type", profile.idcard_type);
                    param.Add("@idcard_No", profile.idcard_No);
                    param.Add("@idcard_Issue_Dt", profile.idcard_Issue_Dt);
                    param.Add("@idcard_Issue_Plc", profile.idcard_Issue_Plc);
                    param.Add("@idcard_Expire_Dt", profile.idcard_Expire_Dt);
                    param.Add("@res_Cntry", profile.res_Cntry);
                    param.Add("@res_add", profile.origin_add);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #region invited
        public async Task<BaseValidate> SetUserInvitedBy(string userId, userInvite invite)
        {
            const string storedProcedure = "sp_COR_User_Profile_Invite_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    param.Add("@referralCd", invite.referralCd);
                    param.Add("@invited_by", invite.userId);
                    var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public userInviteGet GetUserInvited(string userId)
        {
            const string storedProcedure = "sp_COR_User_Profile_Invite_Get";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.QueryFirstOrDefault<userInviteGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        #endregion invited
        public async Task SetProfileLinkFacebook(string userId, fbUserProfile profile)
        {
            const string storedProcedure = "sp_COR_User_Profile_Link_Facebook";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@id", profile.id);
                    param.Add("@name", profile.name);
                    param.Add("@email", profile.email);
                    param.Add("@gender", profile.gender);
                    param.Add("@birthday", profile.birthday);
                    param.Add("@token", profile.token);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<corePointTrans>> GetPointTransactions(FilterBase filter)
        {
            const string storedProcedure = "sp_COR_User_Link_Point_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@dbcr_flg", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);
                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var result = connection.Query<corePointTrans>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<corePointTrans>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion 

    }
}

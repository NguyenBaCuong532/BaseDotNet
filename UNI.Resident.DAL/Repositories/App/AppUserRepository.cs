using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.Core;
using UNI.Resident.DAL.Interfaces.App;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// User Repository
    /// </summary>
    /// Author: taint
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="IUserRepository" />
    public class AppUserRepository : UniBaseRepository, IAppUserRepository
    {
        //private readonly string _connectionString;

        public AppUserRepository(IConfiguration configuration, IUniCommonBaseRepository commonRequestInfo) : base(commonRequestInfo)
        {
            //_connectionString = configuration.GetConnectionString("NobleConnection");
        }
        public Task<coreUserLoginResponse> SetUserRegister(coreUserLoginReg reg)
        {
            const string storedProcedure = "sp_app_user_login_regnew";
            return base.GetFirstOrDefaultAsync<coreUserLoginResponse>(storedProcedure, reg);
        }
        public async Task<coreUserLoginResponse> GetUserRegisted(string reg_id)
        {
            const string storedProcedure = "sp_app_user_login_reg_get";
            return await base.GetFirstOrDefaultAsync<coreUserLoginResponse>(storedProcedure, new { reg_id = reg_id });
        }
        public async Task<UserProfileFull> GetProfileFull(string loginName)
        {
            const string storedProcedure = "sp_app_user_profile_byName";
            var rs = await base.GetMultipleAsync(storedProcedure, new { loginName }, result =>
            {
                var data = result.ReadFirstOrDefault<UserProfileFull>();
                if (data != null)
                {
                    data.point = result.ReadFirstOrDefault<corePoint>();
                    data.fields = result.Read<viewField>().ToList();
                    data.metas = result.Read<coreUserProfileMeta>().ToList();
                    if (data.metas == null) data.metas = new List<coreUserProfileMeta>();
                }
                return Task.FromResult(data);
            });
            return rs;
        }
        public Task<BaseValidate> SetUserProfile(string userId, UserProfileSet ureg)
        {
            const string storedProcedure = "sp_app_user_profile_set";
            return base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, ureg);
        }
        //public Task<userProfileBase> SetLoginUserId(string loginName, string userId, string loginSecret)
        //{
        //    const string storedProcedure = "sp_app_user_login_userId_set";
        //    return base.GetFirstOrDefaultAsync<userProfileBase>(storedProcedure, new { loginName = loginName, userId = userId, loginSecret = loginSecret });
        //}
        public async Task<userLoginRefesh> SetVerificated(coreVerify code, string userId)
        {
            const string storedProcedure = "sp_app_user_login_reg_set";
            return await base.GetFirstOrDefaultAsync<userLoginRefesh>(storedProcedure, new { code.reg_id,  code.code, code.secret_cd, userId_set = userId });
        }

        public async Task<userProfileSet> GetUserProfile(string loginName)
        {
            const string storedProcedure = "sp_app_profile_byName";
            return await base.GetFirstOrDefaultAsync<userProfileSet>(storedProcedure, new { loginName = loginName });

        }

        //public List<CommonValue> GetUserAgreed(string userId)
        //{
        //    const string storedProcedure = "sp_app_user_agreed_get";
        //    return base.GetList<CommonValue>(storedProcedure, userId).ToList();
        //}
        //public async Task SetUserAgreedTerm(BaseCtrlClient client, userAgeedTerm term)
        //{
        //    const string storedProcedure = "sp_app_user_agreed_set";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            var param = new DynamicParameters();
        //            param.Add("@loginName", term.loginName);
        //            param.Add("@is_Agreed_Term", term.is_Agreed_Term);
        //            await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            return;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        public async Task<userForegetResponse> GetUserForgetPassword(string loginName, string udid)
        {
            const string storedProcedure = "sp_app_user_login_forget_get";
            return await base.GetFirstOrDefaultAsync<userForegetResponse>(storedProcedure, new { clientId = base.CommonInfo.ClientId, loginName = loginName, udid = udid });
        }
        public async Task<coreUserLoginResponse> SetUserForgetPassword(userForegetSet forget)
        {
            const string storedProcedure = "sp_app_user_login_forget_set";
            return await base.GetFirstOrDefaultAsync<coreUserLoginResponse>(storedProcedure, new
            {
                clientId = base.CommonInfo.ClientId,
                loginName = forget.loginName,
                phone = forget.phone,
                birthday = forget.birthday,
                verifyType = forget.verifyType,
                udid = forget.udid
            });
            
        }
        public async Task<coreUserLoginResponse> SetUserForgetVerificated(coreVerify code, int user_type)
        {
            const string storedProcedure = "sp_app_user_login_forget_verify";
            return await base.GetFirstOrDefaultAsync<coreUserLoginResponse>(storedProcedure, new { reg_id = code.reg_id, user_type = user_type });
        }
        
        public async Task<coreUserLoginResponse> SetResendCode(string reg_id)
        {
            const string storedProcedure = "sp_app_user_login_reg_resend";
            return await base.GetFirstOrDefaultAsync<coreUserLoginResponse>(storedProcedure, new { reg_id = reg_id});            
        }

        #region  app
        public async Task<List<viewField>> GetProfileFields(string userId, string loginName)
        {
            const string storedProcedure = "sp_app_user_profile_field_get";
            return await base.GetListAsync<viewField>(storedProcedure, new {loginName = loginName });            
        }
        public async Task SetProfileFields(string userId, viewField f)
        {
            const string storedProcedure = "sp_app_user_profile_field_set";
            await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, 
                new { FieldName = f.field_name, ColumnType = f.data_type , FieldValue = f.columnValue });
            return;
        }
        
        public Task LockUser(string userId, bool isLock)
        {
            throw new NotImplementedException();
        }

        #endregion

        #region device
        public Task<BaseValidate> SetSmartDevice(userSmartDevice device)
        {
            const string storedProcedure = "sp_app_user_device_set";
            return base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new { base.CommonInfo.ClientId, base.CommonInfo.ClientIp, device.udid, device.deviceName, device.deviceProvider, device.deviceVersion, device.playerId, device.otp });
        }
        public async Task<BaseValidate> DeleteSmartDevice(string udid)
        {
            const string storedProcedure = "sp_app_user_device_del";
            return await base.DeleteAsync(storedProcedure, new { udid, base.CommonInfo.ClientId });
        }
        public async Task<userSmartDevicePage> GetSmartDevices(FilterBase flt)
        {
            const string storedProcedure = "sp_app_user_device_page";
            var rs = await base.GetMultipleAsync(storedProcedure,
            new { clientId = flt.clientId, flt.offSet, flt.pageSize },
            async result =>
            {
                var data = await result.ReadFirstOrDefaultAsync<userSmartDevicePage>();
                if (data != null)
                {
                    data.content = result.Read<userSmartDeviceView>().ToList();
                }
                return data;
            });
            return rs;
        }
        public Task<userOtpResponse> SetSmartDeviceConfirm(userSmartDeviceConfirm confirm)
        {
            const string storedProcedure = "sp_app_user_device_confirm";
            return base.GetFirstOrDefaultAsync<userOtpResponse>(storedProcedure, new { base.CommonInfo.ClientId, confirm.udid, confirm.verifyType });
        }
        public Task<userOtpResponse> GetSmartDeviceVerify(userSmartDeviceVerify verify)
        {
            const string storedProcedure = "sp_app_user_device_verify_get";
            return base.GetFirstOrDefaultAsync<userOtpResponse>(storedProcedure, new { base.CommonInfo.ClientId, verify.udid });
        }
        public Task<BaseValidate> SetSmartDeviceVerificated(userSmartDeviceVerify verify, int status)
        {
            const string storedProcedure = "sp_app_user_device_verificated";
            return base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new { base.CommonInfo.ClientId, verify.udid, verify.otp, status });
        }

        #endregion device
    }
}

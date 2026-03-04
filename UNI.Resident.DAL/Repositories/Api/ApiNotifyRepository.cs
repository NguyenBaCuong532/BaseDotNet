using Dapper;
using DapperParameters;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RestSharp;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Api;
using UNI.Resident.Model.UserConfig;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using UNI.Common.Extensions;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Model.Core;

namespace UNI.Resident.DAL.Repositories.Api
{
    /// <summary>
    /// AppManagerRepository
    /// </summary>
    /// Author: 
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="ApiNotifyRepository" />
    public class ApiNotifyRepository : IApiNotifyRepository
    {
        private readonly string _connectionString;
        private readonly ILogger<ApiNotifyRepository> _logger;
        private readonly string _uniBaseUrl;
        private readonly string _uniApiKey;
        private readonly string _coreBaseUrl;
        private readonly string _coreApiKey;
        private readonly IFirebaseRepository _fbRepository;
        private readonly IApiSenderRepository _senderRepository;
        public ApiNotifyRepository(
            IFirebaseRepository fbRepository,
            IApiSenderRepository senderRepository,
            ILogger<ApiNotifyRepository> logger,
            IConfiguration configuration
            )
        {
            _connectionString = configuration.GetConnectionString("SHrmConnection");
            _fbRepository = fbRepository;
            _logger = logger;
            this._uniBaseUrl = configuration["Clients:Notify:BaseUrl"];
            this._uniApiKey = configuration["Clients:Notify:ApiKey"];
            this._coreBaseUrl = configuration["Clients:ApiCore:BaseUrl"];
            this._coreApiKey = configuration["Clients:ApiCore:ApiKey"];
        }
        private RestClient GetClient()
        {
            Uri baseUri = new Uri(_coreBaseUrl);
            var client = new RestClient(baseUri);
            return client;
        }
        
        #region notify-push-reg

        
        public async Task<OtpMessageGet> TakeOTP(string userId, WalUserGrant registed)
        {
            //api core
            try
            {
                var client = GetClient();
                var request = new RestRequest($"{_coreBaseUrl}/api/v1/coreTokenOTP/TakeTokenOTP1");
                request.AddHeader("x-api-key", _coreApiKey);
                request.AddQueryParameter("userId", userId);
                request.AddJsonBody(registed);
                var result = await client.PostApiAsync<BaseResponse<OtpMessageGet>>(request);
                OtpMessageGet otp = result.Data.Data;
                return otp;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                //throw;
                return new OtpMessageGet { valid = false, messages = "Lỗi kết nối tạo OTP" };
            }
        }
        
        public async Task<BaseValidate> SetOtpStatus(string userId, userOtpStatus status)
        {
            try
            {
                var client = GetClient();
                var request = new RestRequest($"{_coreBaseUrl}/api/v1/coreTokenOTP/SetOtpStatus1");
                request.AddHeader("x-api-key", _coreApiKey);
                request.AddQueryParameter("userId", userId);
                request.AddJsonBody(status);
                var result = await client.PostApiAsync<BaseResponse<BaseValidate>>(request);
                return result.Data.Data;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw ex;
            }
        }
        public async Task<ResponseCode> SetVerifyCode(string userId, userVerification code)
        {
            //api core
            try
            {
                var client = GetClient();
                var request = new RestRequest($"{_coreBaseUrl}/api/v1/coreTokenOTP/VerifyTokenOTP1");
                request.AddHeader("x-api-key", _coreApiKey);
                request.AddQueryParameter("userId", userId);
                request.AddJsonBody(code);
                var result = await client.PostApiAsync<BaseResponse<ResponseCode>>(request);
                if (result.Data.Data == null)
                    return new ResponseCode { StatusCode = result.Data.StatusCode, StatusMessage = result.Data.Message, Status = result.Data.StatusCode };
                else
                    return result.Data.Data;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task<string> GetUserToken(string userId, int tokenType, int mode = 0)
        {
            try
            {
                var client = GetClient();
                var utoken = new UNI.Model.Core.coreUserToken { tokenType = tokenType, mode = mode, client = new BaseCtrlClient { UserId = userId } };
                var request = new RestRequest($"{_coreBaseUrl}/api/v1/coreTokenOTP/TakeUserToken");
                request.AddHeader("x-api-key", _coreApiKey);
                request.AddJsonBody(utoken);
                var result = await client.PostApiAsync<BaseResponse<string>>(request);
                return result.Data.Data;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        //public async Task<BaseValidate> TakeNotification(AppNotifyTake1 take)
        //{
        //    try
        //    {
        //        int push_count = 0;
        //        int sms_count = 0;
        //        int email_count = 0;
                
        //        if (take.action_list.Contains("push"))
        //        {
        //            push_count = 1;
        //            await _fbRepository.SetNotifyPush(take);
        //        }

        //        //if (take.action_list.Contains("sms"))
        //        //{
        //        //    sms_count = 1;
        //        //    foreach (var m in take.apMessage())
        //        //        await _senderRepository.SendSmsAs(m);
        //        //}
        //        //if (take.action_list.Contains("sms") || take.action_list.Contains("email"))
        //        //{
        //        //    email_count = 1;
        //        //    foreach (var m in take.apEmail())
        //        //        await _senderRepository.SendMailgunEmail(m);
        //        //}

        //        var noti = await this.TakeNotify(clt, take, push_count, sms_count, email_count);
        //        return noti;
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError($"{ex}");
        //        throw;
        //    }
        //}
        //public async Task<BaseValidate> TakeNotify(AppNotifyTake1 take, int push_count, int sms_count, int email_count)
        //{
        //    const string storedProcedure = "sp_hrm_app_notify_push_take";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserID", clt.UserId);
        //            param.Add("@notiType", take.notiType);
        //            param.Add("@subject", take.subject);
        //            param.Add("@action_list", take.action_list);
        //            param.Add("@content_notify", take.content_notify);
        //            param.Add("@content_sms", take.content_sms);
        //            param.Add("@contentType", take.contentType);
        //            param.Add("@content_markdown", take.content_markdown);
        //            param.Add("@content_email", take.content_email);
        //            param.Add("@bodytype", take.bodytype);
        //            param.Add("@external_param", take.external_param);
        //            param.Add("@external_event", take.external_event);
        //            param.Add("@source_key", take.source_key);
        //            param.Add("@push_count", push_count);
        //            param.Add("@sms_count", sms_count);
        //            param.Add("@email_count", email_count);
        //            if (take.attachs != null && take.attachs.Count > 0 && !string.IsNullOrEmpty(take.attachs.FirstOrDefault().attach_url))
        //                param.AddTable("@attachs", "user_notify_attach", take.attachs);
        //            else
        //                param.AddTable("@attachs", "user_notify_attach", new List<AppNotifyAttach1>());
        //            param.AddTable("@notiusers", "user_notify_type", take.appUsers);
        //            var result = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);

        //            return result;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        #endregion notify-push-reg

        #region private function
        private string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
        private async Task<string> getB64fromUrl(string link_url)
        {
            var client = new HttpClient();
            var request = new HttpRequestMessage(HttpMethod.Get, link_url);
            var response = await client.SendAsync(request);
            var contentStream = await response.Content.ReadAsStreamAsync();
            return ConvertToBase64(contentStream);
        }
        private string ConvertToBase64(Stream stream)
        {
            byte[] bytes;
            using (var memoryStream = new MemoryStream())
            {
                stream.CopyTo(memoryStream);
                bytes = memoryStream.ToArray();
            }
            string base64 = Convert.ToBase64String(bytes);
            return base64;
        }
        #endregion private
    }
}

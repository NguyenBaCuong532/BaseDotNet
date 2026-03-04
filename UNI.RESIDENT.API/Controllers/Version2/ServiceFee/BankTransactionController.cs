using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Serilog;
using UNI.Resident.BLL.BusinessInterfaces.Transaction;
using UNI.Resident.Model.Common;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.Bank.KLBank;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.ServiceFee
{
    /// <summary>
    /// Investment Api for web
    /// </summary>
    /// Author: ThanhMT
    /// CreatedDate: 2020-04-20 9:31 AM
    /// <seealso cref="UniController" />
    [Route("api/v1/banktrans/[action]")]
    [ApiController]
    public class BankTransactionController : UniController
    {
        private readonly ITransactionService _tranService;
        private readonly IApiBankService _apiBankService;
        public BankTransactionController(ITransactionService tranService, IApiBankService apiBankService)
        {
            _tranService = tranService;
            _apiBankService = apiBankService;
        }

        #region klb-pay
        /// <summary>
        /// inquiryChecking - API kiểm tra tài khoản ảo
        /// </summary>
        /// <param name="headers"></param>
        /// <param name="request"></param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpPost]
        public async Task<klbResponseBase> inquiryChecking([FromHeader] klbHeaderBase headers, [FromBody] klbRequestBase request)
        {
            //headers = new klbHeaderBase
            //{
            //    ApiClient = "fe893f05-2fd0-42fe-8a2d-0447d9e07025",
            //    ApiTime = 123456,
            //    ApiValidate = "c84a3cd6601164d64d5020f5ac136616f54cb8765f9852b8ee191ad237d67129"
            //};
            //request.data = @"2LbS8FFbbBRRvT2z/Azpxm8gpfn8T+iyIuimVL5W5HoKRHJacIPUYUYSJewf2JEM";

            var result = new klbResponseBase();
            Log.Information("inquiryChecking header request : " + DateTime.Now.ToString() + ":" + JsonConvert.SerializeObject(headers));
            Log.Information("inquiryChecking request : " + DateTime.Now.ToString() + ":" + JsonConvert.SerializeObject(request.data));

            var log = new LogTransactionBank
            {
                Type = "Inquiry",
                HeaderRequest = JsonConvert.SerializeObject(headers),
                Request = JsonConvert.SerializeObject(request.data),
                CreatedAt = DateTime.Now
            };

            await _tranService.SetLogTransactionInfo(log);


            if (string.IsNullOrEmpty(headers.ApiClient) || string.IsNullOrEmpty(headers.ApiValidate) || headers.ApiTime == 0)
                return new klbResponseBase() { code = 1, message = "Invalid ApiClient or ApiValidate or ApiTime", data = null };

            if (request == null || string.IsNullOrEmpty(request.data))
                return new klbResponseBase() { code = 1, message = "Invalid Data", data = null };

            var requestData = new EncryptedBodyRequest
            {
                ClientId = headers.ApiClient,
                Timestamp = headers.ApiTime,
                Data = request.data,
                Signature = headers.ApiValidate
            };
            try
            {
                var requestAuthenticate = _apiBankService.PaygateAuthenticate<klbInquiryCheckingRequest>(requestData);
                result = await _tranService.InquiryChecking(requestAuthenticate);
                return result;
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.TRANSACTION_EXPIRED)
            {
                // Xử lý lỗi giao dịch hết hạn
                Log.Information("Transaction expired. Please try again.");
                result.code = 1;
                result.message = "Transaction expired. Please try again.";
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.INVALID_CLIENT_ID)
            {
                // Xử lý lỗi Client ID không hợp lệ
                Log.Information("Invalid client ID. Please check your credentials.");
                result.code = 1;
                result.message = "Invalid client ID. Please check your credentials.";
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.INVALID_CERTIFICATE)
            {
                // Xử lý lỗi chữ ký hoặc chứng chỉ không hợp lệ
                Log.Information("Invalid certificate or signature. Authentication failed.");
                result.code = 1;
                result.message = "Invalid certificate or signature. Authentication failed.";
            }
            return result;

        }
        /// <summary>
        /// depositChecking - API kiểm tra trước khi gọi hạch toán
        /// </summary>
        /// <param name="headers"></param>
        /// <param name="request"></param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpPost]
        public async Task<klbResponseBase> depositChecking(
             [FromHeader] klbHeaderBase headers, [FromBody] klbRequestBase request)
        {
            klbResponseBase result = new klbResponseBase();
            Log.Information("depositChecking header request : " + DateTime.Now.ToString() + ":" + JsonConvert.SerializeObject(headers));
            Log.Information("depositChecking request : " + DateTime.Now.ToString() + ":" + JsonConvert.SerializeObject(request.data));

            var log = new LogTransactionBank
            {
                Type = "Deposit",
                HeaderRequest = JsonConvert.SerializeObject(headers),
                Request = JsonConvert.SerializeObject(request.data),
                CreatedAt = DateTime.Now
            };

            await _tranService.SetLogTransactionInfo(log);


            // Validate headers (x-api-client, x-api-validate, x-api-time)
            if (string.IsNullOrEmpty(headers.ApiClient) || string.IsNullOrEmpty(headers.ApiValidate) || headers.ApiTime == 0)
            {
                return new klbResponseBase() { code = 1, message = "Invalid ApiClient or ApiValidate or ApiTime", data = null };
            }
            // Process the "data" field in the request body
            if (request == null || string.IsNullOrEmpty(request.data))
            {
                return new klbResponseBase() { code = 1, message = "Invalid Data", data = null };
            }

            var requestData = new EncryptedBodyRequest
            {
                ClientId = headers.ApiClient,
                Timestamp = headers.ApiTime,
                Data = request.data,
                Signature = headers.ApiValidate
            };

            try
            {
                var requestAuthenticate = _apiBankService.PaygateAuthenticate<klbDepositCheckingRequest>(requestData);

                result = await _tranService.DepositChecking(requestAuthenticate);
                return result;
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.TRANSACTION_EXPIRED)
            {
                // Xử lý lỗi giao dịch hết hạn
                Log.Information("Transaction expired. Please try again.");
                result.code = 1;
                result.message = "Transaction expired. Please try again.";
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.INVALID_CLIENT_ID)
            {
                // Xử lý lỗi Client ID không hợp lệ
                Log.Information("Invalid client ID. Please check your credentials.");
                result.code = 1;
                result.message = "Invalid client ID. Please check your credentials.";
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.INVALID_CERTIFICATE)
            {
                // Xử lý lỗi chữ ký hoặc chứng chỉ không hợp lệ
                Log.Information("Invalid certificate or signature. Authentication failed.");
                result.code = 1;
                result.message = "Invalid certificate or signature. Authentication failed.";
            }
            return result;


        }
        /// <summary>
        /// notifyTransaction - API cập nhật trạng thái giao dịch
        /// </summary>
        /// <param name="headers"></param>
        /// <param name="request"></param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpPost]
        public async Task<klbResponseBase> notifyTransaction([FromHeader] klbHeaderBase headers, [FromBody] klbRequestBase request)
        {
            klbResponseBase result = new klbResponseBase();
            Log.Information("NotifyTransaction header request : " + DateTime.Now.ToString() + ":" + JsonConvert.SerializeObject(headers));
            Log.Information("NotifyTransaction request : " + DateTime.Now.ToString() + ":" + JsonConvert.SerializeObject(request.data));

            var log = new LogTransactionBank
            {
                Type = "Notify",
                HeaderRequest = JsonConvert.SerializeObject(headers),
                Request = JsonConvert.SerializeObject(request.data),
                CreatedAt = DateTime.Now
            };

            await _tranService.SetLogTransactionInfo(log);

            // Validate headers (x-api-client, x-api-validate, x-api-time)
            if (string.IsNullOrEmpty(headers.ApiClient) || string.IsNullOrEmpty(headers.ApiValidate) || headers.ApiTime == 0)
            {
                return new klbResponseBase() { code = 1, message = "Invalid ApiClient or ApiValidate or ApiTime", data = null };
            }
            // Process the "data" field in the request body
            if (request == null || string.IsNullOrEmpty(request.data))
            {
                return new klbResponseBase() { code = 1, message = "Invalid Data", data = null };
            }

            var requestData = new EncryptedBodyRequest
            {
                ClientId = headers.ApiClient,
                Timestamp = headers.ApiTime,
                Data = request.data,
                Signature = headers.ApiValidate
            };

            try
            {

                var requestAuthenticate = _apiBankService.PaygateAuthenticate<klbNotifyTransactionEnscrypt>(requestData);
                // You could add any business logic for processing `request.data` here.
                result = await _tranService.SetPaymentCallBack(requestAuthenticate);
                return result;
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.TRANSACTION_EXPIRED)
            {
                // Xử lý lỗi giao dịch hết hạn
                Log.Information("Transaction expired. Please try again.");
                result.code = 1;
                result.message = "Transaction expired. Please try again.";
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.INVALID_CLIENT_ID)
            {
                // Xử lý lỗi Client ID không hợp lệ
                Log.Information("Invalid client ID. Please check your credentials.");
                result.code = 1;
                result.message = "Invalid client ID. Please check your credentials.";
            }
            catch (InternalException ex) when (ex.Code == ResponseCode.INVALID_CERTIFICATE)
            {
                // Xử lý lỗi chữ ký hoặc chứng chỉ không hợp lệ
                Log.Information("Invalid certificate or signature. Authentication failed.");
                result.code = 1;
                result.message = "Invalid certificate or signature. Authentication failed.";
            }
            return result;


        }
        #endregion klb-pay
        /// <summary>
        /// GetTransBankFilter - Bộ lọc thu tiền
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetTransBankFilter()
        {
            var result = await _tranService.GetTransBankFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetTransBankPage - Danh sách thu tiền
        /// </summary>
        /// <param name="param"></param>        
        /// <returns></returns>
        /// 
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetTransBankPage([FromQuery] FilterTransInput param)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<CommonDataPage>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            param.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _tranService.GetTransBankPage(param);
            return GetResponse(ApiResult.Success, result);
        }
    }
}
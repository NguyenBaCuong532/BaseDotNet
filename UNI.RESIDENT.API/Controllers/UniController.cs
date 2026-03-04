using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Utils;

namespace UNI.Resident.API.Controllers
{
    /// <summary>
    /// 
    /// </summary>
    /// <author>ThienTH</author>
    /// <createdDate>2/2/2016</createdDate>
    /// <seealso>
    ///     <cref>System.Web.Http.ApiController</cref>
    /// </seealso>
    public class UniController : ControllerBase
    {
        /// <summary>
        /// logger
        /// </summary>
        protected readonly ILogger _logger;
        /// <summary>
        /// AppSettings
        /// </summary>
        protected readonly AppSettings _appSettings;
        /// <summary>
        /// StorageService
        /// </summary>
        protected readonly IApiStorageService _storageService;
        /// <summary>
        /// Contructor
        /// </summary>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public UniController(IOptions<AppSettings> appSettings, ILoggerFactory logger)
        {
            _appSettings = appSettings.Value;
            _logger = logger.CreateLogger(GetType().Name);
        }
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="storageService"></param>
        public UniController(IOptions<AppSettings> appSettings, ILoggerFactory logger,
            IApiStorageService storageService)
        {
            _appSettings = appSettings.Value;
            _logger = logger.CreateLogger(GetType().Name);
            _storageService = storageService;
        }
        /// <summary>
        /// Contructor
        /// </summary>
        public UniController()
        {
            
        }
        /// <summary>
        /// Gets the user identifier.
        /// </summary>
        /// <value>
        /// The user identifier.
        /// </value>
        /// Author: taint
        /// CreatedDate: 16/01/2017 1:34 PM
        protected string UserId
        {
            get
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    userId = User.Claims.Where(c => c.Type == "sub").Select(c1 => c1.Value).FirstOrDefault();
                }
                return userId;
            }
        }
        /// <summary>
        /// User Name
        /// </summary>
        protected string UserName => User.Claims.Where(c => c.Type == "name").Select(c1 => c1.Value).FirstOrDefault();
        /// <summary>
        /// Gets the client identifier.
        /// </summary>
        /// <value>
        /// The client identifier.
        /// </value>
        /// Author: taint
        /// CreatedDate: 16/01/2017 1:34 PM
        protected string ClientId => User.Claims.Where(c => c.Type == "client_id").Select(c1 => c1.Value).FirstOrDefault();
        /// <summary>
        /// AcceptLanguage
        /// </summary>
        protected string AcceptLanguage => Request.Headers["Accept-Language"].ToString().Split(";").FirstOrDefault()?.Split(",").FirstOrDefault();
        /// <summary>
        /// Get Errors
        /// </summary>
        protected List<string> Errors
        {
            get
            {
                try
                {
                    var lstError = new List<string>();

                    foreach (var key in ModelState.Keys)
                    {
                        foreach (var error in ModelState[key].Errors)
                        {
                            lstError.Add($"{key} {error.ErrorMessage}");
                        }
                    }

                    return lstError;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.StackTrace);
                    throw;
                }
            }
        }

        /// <summary>
        /// Ctrl Client
        /// </summary>
        public BaseCtrlClient CtrlClient
        {
            get
            {
                return new BaseCtrlClient
                {
                    ClientId = User.Claims.Where(c => c.Type == "client_id").Select(c1 => c1.Value).FirstOrDefault(),
                    ClientIp = Request.HttpContext.Connection.RemoteIpAddress.ToString(),
                    hostUrl = HttpContext.Request.Scheme + "://" + HttpContext.Request.Host.Value,
                    UserId = this.UserId
                };
            }
        }
        /// <summary>
        /// GetClaim
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        protected string GetClaim(string key)
        {
            var principal = HttpContext.User.Claims;
            return principal.Single(c => c.Type == key).Value;
        }
        /// <summary>
        /// ServiceHandler
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <typeparam name="TX"></typeparam>
        /// <param name="records"></param>
        /// <returns></returns>
        protected delegate Task<ImportListPage> ServiceHandler<T, in TX>(TX records) where TX : BaseImportSet<T>;
        /// <summary>
        /// DoImportFile
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <typeparam name="TX"></typeparam>
        /// <param name="file"></param>
        /// <param name="fromRow"></param>
        /// <param name="serviceHandler"></param>
        /// <returns></returns>
        protected async Task<BaseResponse<ImportListPage>> DoImportFile<T, TX>(IFormFile file, int fromRow,
            ServiceHandler<T, TX> serviceHandler) where T : new() where TX : BaseImportSet<T>, new()
        {
            var result = new BaseResponse<ImportListPage>();
            if (file == null || file.Length <= 0)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");
            }

            if (!Path.GetExtension(file.FileName)!.Equals(".xlsx", StringComparison.OrdinalIgnoreCase) &&
                !Path.GetExtension(file.FileName)!.Equals(".xls", StringComparison.OrdinalIgnoreCase))
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2,
                    "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx hoặc .xls");
            }
            //DoCheckImportFile<T>(file,3);
            try
            {
                var workRecords = new TX();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    workRecords.imports = FlexcellUtils.ReadToObject<T>(fs.ToArray(), fromRow);
                }

                // var fileUpload = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_hrm");
                var fileUpload = await _storageService.UploadFile(file);
                workRecords.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = fileUpload.Url
                    // fileUrl = fileUpload.FilePath
                };
                var rs = await serviceHandler(workRecords);
                //return GetResponse(ApiResult.Success, rs);
                if (rs.valid == false)
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
                }
                else
                {
                    return GetResponse<ImportListPage>(ApiResult.Success, rs);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return result;
            }
        }
        /// <summary>
        /// GetResponse
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="status"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        protected static BaseResponse<T> GetResponse<T>(ApiResult status, T data = default)
        {
            return new BaseResponse<T>(status, data);
        }
        /// <summary>
        /// Get Response
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="status"></param>
        /// <param name="data"></param>
        /// <param name="message"></param>
        /// <returns></returns>
        protected static BaseResponse<T> GetResponse<T>(ApiResult status, T data, string message)
        {
            var respense = new BaseResponse<T>(status, data);
            respense.SetStatus(status, message);
            return respense;
        }
        /// <summary>
        /// Response
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        protected static BaseResponse<BaseValidate> GetResponse(BaseValidate data)
        {
            var status = data.valid ? ApiResult.Success : ApiResult.Error;
            var respense = new BaseResponse<BaseValidate>(status, data);
            respense.SetStatus(status, data.messages);
            return respense;
        }
        /// <summary>
        /// GetErrorResponse
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="result"></param>
        /// <param name="code"></param>
        /// <param name="message"></param>
        /// <returns></returns>
        protected BaseResponse<T> GetErrorResponse<T>(ApiResult result, int code, string message)
        {
            // trả mã lỗi
            var response = new BaseResponse<T>();

            // thêm lỗi
            response.AddError(message);
            response.SetStatus(result, message);
            response.SetStatus(code, message);

            return response;
        }

    }
}
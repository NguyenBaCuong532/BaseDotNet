using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Model;
using UNI.Model.Api;
using System;
using System.Collections.Generic;
using System.Linq;

namespace SSG.SupApp.API.Controllers
{
    /// <summary>
    /// 
    /// </summary>
    /// <author>ThienTH</author>
    /// <createdDate>2/2/2016</createdDate>
    /// <seealso>
    ///     <cref>System.Web.Http.ApiController</cref>
    /// </seealso>
    public class SSGController : ControllerBase
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
       /// Contructor
       /// </summary>
       /// <param name="appSettings"></param>
       /// <param name="logger"></param>
        public SSGController(IOptions<AppSettings> appSettings, ILoggerFactory logger)
        {
            _appSettings = appSettings.Value;
            _logger = logger.CreateLogger(GetType().Name);
        }
        /// <summary>
        /// Contructor
        /// </summary>
        public SSGController()
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
        protected string UserId => User.Claims.Where(c => c.Type == "sub").Select(c1 => c1.Value).FirstOrDefault();
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
                            lstError.Add(error.ErrorMessage);
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
                    UserId = User.Claims.Where(c => c.Type == "sub").Select(c1 => c1.Value).FirstOrDefault()
                };
            }
        }
        /// <summary>
        /// Accept-Language
        /// </summary>
        protected string AcceptLanguage => Request.Headers["Accept-Language"].ToString().Split(";").FirstOrDefault()?.Split(",").FirstOrDefault(); //Request.Headers["Accept-Language"].ToString();
        
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
        /// GetResponse
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="status"></param>
        /// <returns></returns>
        protected static BaseResponse<T> GetResponse<T>(ApiResult status)
        {
            return new BaseResponse<T>(status);
        }

        /// <summary>
        /// GetResponse
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="status"></param>
        /// <param name="error"></param>
        /// <returns></returns>
        protected static BaseResponse<T> GetResponse<T>(ApiResult status, string error = null)
        {
            return new BaseResponse<T>(status, error);
        }

        /// <summary>
        /// Get Response
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="status"></param>
        /// <param name="data"></param>
        /// <param name="error"></param>
        /// <returns></returns>
        protected static BaseResponse<T> GetResponse<T>(ApiResult status, T data, string error = null)
        {
            return new BaseResponse<T>(status, data, error);
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
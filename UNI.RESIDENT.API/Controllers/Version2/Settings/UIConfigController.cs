using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.API.Controllers;
using UNI.Resident.BLL.BusinessService;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.Api;
using UNI.Utils;
using UNI.Resident.BLL.BusinessInterfaces.Settings;

namespace UNI.Resident.API.Controllers.Version2.Settings
{
    /// <summary>
    /// UInvConfigController
    /// </summary>
    //[Authorize]
    [Route("api/v2/config/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class UIConfigController : UniController
    {
        private readonly IUIConfigService _cfgService;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="logger"></param>
        /// <param name="appSettings"></param>
        /// <param name="service"></param>
        public UIConfigController(ILoggerFactory logger,
            IOptions<AppSettings> appSettings,
            IUIConfigService service) : base(appSettings, logger)
        {
            _cfgService = service;
        }

        #region Configs
        /// <summary>
        /// Get Config Table view Page
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        /// 
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetFormViewPage(
            [FromQuery] FilterInpTableKey flt)
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _cfgService.GetFormViewPage(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Set Configuration for field view
        /// </summary>
        /// <param name="para"></param>
        /// <returns></returns>
        /// 
        [HttpPost]
        public async Task<BaseResponse<string>> SetFormViewInfo([FromBody] ConfigField para)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _cfgService.SetFormViewInfo(para);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// Delete Config Fields
        /// </summary>
        /// <param name="fieldId"></param>
        /// <returns></returns>
        /// 
        [HttpDelete]
        public async Task<BaseResponse<string>> DelFormViewInfo([FromQuery] long fieldId)
        {
            var result = await _cfgService.DelFormViewInfo(fieldId);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// Get Config Grid Page
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        /// 
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetGridViewPage(
            [FromQuery] FilterInpGridKey flt)
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _cfgService.GetGridViewPage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Configuration for Grid
        /// </summary>
        /// <param name="para"></param>
        /// <returns></returns>
        /// 
        [HttpPost]
        public async Task<BaseResponse<string>> SetGridViewInfo([FromBody] ConfigColumn para)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _cfgService.SetGridViewInfo(para);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// Delete Config Grid
        /// </summary>
        /// <param name="gridId"></param>
        /// <returns></returns>
        /// 
        [HttpDelete]
        public async Task<BaseResponse<string>> DelGridViewInfo([FromQuery] long gridId)
        {
            var result = await _cfgService.DelGridViewInfo(gridId);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        #endregion Configs

        /// <summary>
        /// Get Group Info
        /// </summary>
        /// <param name="group_key"></param>
        /// <param name="group_cd"></param>
        /// <returns></returns>
        /// 
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetGroupInfo(
            [FromQuery] string group_key,
            [FromQuery] string group_cd)
        {
            var result = await _cfgService.GetGroupInfo(group_key, group_cd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Group Info
        /// </summary>
        /// <param name="para"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetGroupInfo([FromBody] CommonViewInfo para)
        {
            var result = await _cfgService.SetGroupInfo(para);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// GetGrid
        /// </summary>
        /// <param name="gridKey"></param>
        /// <returns></returns>
        [HttpGet("{gridKey}")]
        [ProducesDefaultResponseType(typeof(BaseResponse<IEnumerable<viewGridFlex>>))]
        public async Task<IActionResult> GetGrid(string gridKey)
        {
            var grid = await _cfgService.GetGridAsync(gridKey);
            var rp = GetResponse(ApiResult.Success, grid);
            return Ok(rp);
        }
    }
}

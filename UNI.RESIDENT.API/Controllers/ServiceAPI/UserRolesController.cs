using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Common;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.API.Attributes;
using UNI.Utils;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace UNI.Resident.API.Controllers.ServiceAPI
{
    /// <summary>
    /// UserRolesController
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 07/02/2017 9:31 AM
    /// <seealso cref="UserRolesController" />
    [Route("api/v2/userrole/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class UserRolesController : UniController
    {
        private readonly IUserConfigService _prodService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="UserRolesController"/> class.
        /// </summary>
        /// <param name="appSettings">The application settings.</param>
        /// <param name="logger">The logger.</param>
        /// <param name="mapper">The mapper.</param>
        /// <param name="roleService"></param>
        /// Author: duongpx
        /// CreatedDate: 07/02/2017 9:32 AM
        public UserRolesController(
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IUserConfigService roleService) : base(appSettings, logger)
        {
            _mapper = mapper;
            _prodService = roleService;
        }

        #region async role
        ///// <summary>
        ///// GetProjectList - Lấy ds dự án
        ///// </summary>
        ///// <param name="isAll">Có lấy thêm giá trị tất cả ngoài tên dự án thực tế ?</param>
        ///// <returns></returns>
        //[HttpGet]
        //[AllowAnonymous]
        //[ApiKey]
        //public BaseResponse<List<CommonValue>> GetProjectListForOutSide(bool? isAll)
        //{
        //    var result = _prodService.GetOrganizeses(this.UserId, isAll);
        //    return GetResponse(ApiResult.Success, result);
        //}
        /// <summary>
        /// GetOrganizeses - Tổ chức
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<CommonValue>>> GetOrganizeses(bool? isAll)
        {
            var result = await _prodService.GetOrganizeses(isAll);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetCompanies
        /// </summary>
        /// <param name="orgId"></param>
        /// <returns></returns>
        //[ServiceFilter(typeof(ApiKeyAttribute))]
        [AllowAnonymous]
        [HttpGet]
        [ApiKey]
        public async Task<BaseResponse<List<CommonValue>>> GetWorkplaces([FromQuery] Guid? orgId)
        {
            var result = await _prodService.GetWorkplaces(orgId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetCategosies
        /// </summary>
        /// <param name="orgId"></param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpGet]
        [ApiKey]
        public async Task<BaseResponse<List<TreeNodeSingle>>> GetCategosies([FromQuery] Guid? orgId)
        {
            var result = await _prodService.GetCategosies(orgId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// setUserProdAsync 
        /// </summary>
        /// <param name="profile"></param>
        /// <returns></returns>
        //[ServiceFilter(typeof(ApiKeyAttribute))]
        [AllowAnonymous]
        [HttpPost]
        [ApiKey]
        public async Task<BaseResponse<string>> setUserProdAsync([FromBody] UserProdCms profile)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _prodService.setUserProdAsync(profile);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        #endregion async role
    }
}
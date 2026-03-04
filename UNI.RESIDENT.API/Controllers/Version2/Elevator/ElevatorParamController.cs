using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;

namespace UNI.Resident.API.Controllers.Version2.Elevator
{

    /// <summary>
    /// ElevatorController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/elevatorParam/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ElevatorParamController : UniController
    {

        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IElevatorParamService _homeService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ElevatorController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ElevatorParamController(IElevatorParamService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
        }

        /// <summary>
        /// GetCardRolePage - 
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetCardRolePage([FromQuery] string filter, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBase(clientid: ClientId, userid: UserId, offset: offSet, pagesize: pageSize, filter: filter);
            var result = await _homeService.GetCardRolePage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Elevator Card Role
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetCardRoleInfo([FromQuery] string cardRoleId)
        {
            var result = await _homeService.GetCardRoleInfo(cardRoleId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Elevator Floor
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetCardRoleInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetCardRoleInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// Set Elevator Card Role
        /// </summary>
        /// <param name="cardRoleId"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelCardRole([FromQuery] string cardRoleId)
        {
            var result = await _homeService.DelCardRole(cardRoleId);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }
        /// <summary>
        /// Get List Elevator Card Role
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetCardRoles()
        {
            var result = await _homeService.GetCardRoles(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        
        /// <summary>
        /// Get ElevatorBankShafts
        /// </summary>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetBankShafts([FromQuery] string projectCd)
        {
            var result = await _homeService.GetBankShafts(projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetBankShaftPage
        /// </summary>
        /// <param name="buildingCd"></param>
        /// <param name="projectCd"></param>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBankShaftPage([FromQuery] string buildingCd, [FromQuery] string projectCd, [FromQuery] string filter, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterInputBuilding() { buildingCd = buildingCd, projectCd = projectCd, offSet = offSet, pageSize = pageSize, filter = filter };
            var result = await _homeService.GetBankShaftPage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Elevator Card Role
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBankShaftInfo([FromQuery] string id, [FromQuery] string projectCd)
        {
            var result = await _homeService.GetBankShaftInfo(id, projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Elevator Floor
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBankShaftInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetBankShaftInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// Set Elevator Card Role
        /// </summary>
        /// <param name="id"></param>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelBankShaft([FromQuery] string id, [FromQuery] string projectCd)
        {
            var result = await _homeService.DelBankShaft(projectCd, id);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// Get FloorType ByBuildCd
        /// </summary>
        /// <param name="areaCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetFloorTypeList([FromQuery] string areaCd)
        {
            var result = await _homeService.GetFloorTypeList(areaCd);
            return GetResponse(ApiResult.Success, result);
        }
    }
}

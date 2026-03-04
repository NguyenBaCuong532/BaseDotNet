using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;

namespace UNI.Resident.API.Controllers.Version2.Elevator
{

    /// <summary>
    /// ElevatorController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/elevatorBuilding/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ElevatorBuildingController : UniController
    {

        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IElevatorBuildingService _homeService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ElevatorController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ElevatorBuildingController(IElevatorBuildingService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
        }


        /// <summary>
        /// Set Elevator projectCd
        /// </summary>
        /// <param name="buildingCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetBuildAreaList([FromQuery] string buildingCd)
        {
            var result = await _homeService.GetBuildAreaList(buildingCd);
            return GetResponse<List<CommonValue>>(ApiResult.Success, result);
        }
        /// <summary>
        /// GetBuildAreaPage 
        /// </summary>
        /// <param name="buildingCd"></param>
        /// <param name="projectCd"></param>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBuildAreaPage([FromQuery] string buildingCd, [FromQuery] string projectCd, [FromQuery] string filter, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterInputBuilding() { buildingCd = buildingCd, projectCd = projectCd, offSet = offSet,pageSize = pageSize ,filter = filter };
            var result = await _homeService.GetBuildAreaPage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetBuildAreaInfo
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<BuildAreaInfo>> GetBuildAreaInfo([FromQuery] string projectCd, [FromQuery] string buildingCd, [FromQuery] string id)
        {
            var result = await _homeService.GetBuildAreaInfo(projectCd, buildingCd, id);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetBuildAreaInfo
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBuildAreaInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetBuildAreaInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// DelBuildArea
        /// </summary>
        /// <param name="buildingCd"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelBuildArea([FromQuery] string buildingCd, [FromQuery] string id)
        {
            var result = await _homeService.DelBuildArea(buildingCd, id);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// Get BuildCd By ProjectCd
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="areaCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBuildZonePage(
            [FromQuery] string filter, [FromQuery] int? offSet, [FromQuery] int? pageSize, [FromQuery] string projectCd, [FromQuery] string areaCd)
        {
            var flt = new FilterElevatorZone(clientid: ClientId, userid: UserId, offset: offSet, pagesize: pageSize, filter: filter, projectCd: projectCd, areaCd: areaCd); ;
            var result = await _homeService.GetBuildZonePage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Elevator Card Role
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBuildZoneInfo([FromQuery] string areaCd, [FromQuery] string id, [FromQuery] string projectCd)
        {
            var result = await _homeService.GetBuildZoneInfo(areaCd, id, projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Elevator Floor
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBuildZoneInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetBuildZoneInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// DelBuildZone
        /// </summary>
        /// <param name="areaCd"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelBuildZone([FromQuery] string areaCd, string id)
        {
            var result = await _homeService.DelBuildZone(areaCd, id);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }
        /// <summary>
        /// Get BuildZone By BuildCd
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="areaCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetBuildZoneList([FromQuery] string projectCd, [FromQuery] string areaCd)
        {
            var result = await _homeService.GetBuildZoneList(projectCd, areaCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get ElevatorFloor Page
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="areaCd"></param>
        /// <param name="buildZone"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBuildFloorPage([FromQuery] string filter, [FromQuery] int? offSet, [FromQuery] int? pageSize, 
            [FromQuery] string projectCd, [FromQuery] string areaCd, [FromQuery] string buildZone, [FromQuery] Guid? buildingOid = null)
        {
            var flt = new FilterElevatorFloor(clientid: ClientId, userid: UserId, offset: offSet, pagesize: pageSize, filter: filter, projectCd: projectCd, areaCd: areaCd, buildZone: buildZone, buildingOid: buildingOid);
            var result = await _homeService.GetBuildFloorPage(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get Elevator Card Role
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBuildFloorInfo([FromQuery] string buildZone, string id)
        {
            var result = await _homeService.GetBuildFloorInfo(buildZone, id);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Elevator Floor
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBuildFloorInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetBuildFloorInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// Set Elevator Card Role
        /// </summary>
        /// <param name="buildZone"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelBuildFloor([FromQuery] string buildZone, string id)
        {
            var result = await _homeService.DelBuildFloor(buildZone, id);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }
        /// <summary>
        /// Get BuildFloorBy ProjectCdBuildCd
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd"></param>
        /// <param name="buildZone"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetBuildFloorList([FromQuery] string projectCd,
             [FromQuery] string buildingCd, [FromQuery] string buildZone, [FromQuery] Guid? buildingOid = null)
        {
            var result = await _homeService.GetBuildFloorList(projectCd, buildingCd, buildZone, buildingOid);
            return GetResponse(ApiResult.Success, result);
        }
        
             
    }
}

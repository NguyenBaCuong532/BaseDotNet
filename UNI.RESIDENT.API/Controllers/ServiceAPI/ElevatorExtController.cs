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
using UNI.Resident.API.Attributes;
using UNI.Resident.API.Controllers.Version2.Elevator;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.ServiceAPI
{

    /// <summary>
    /// ElevatorExtController 
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/elevatorext/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ElevatorExtController : UniController
    {

        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IElevatorService _homeService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ElevatorController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ElevatorExtController(
            IElevatorService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
        }


        /// <summary>
        /// Set Access Floor - Dung để chọn 1 tầng trước
        /// </summary>
        /// <param name="floor"></param>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetAccessFloor([FromBody] HomAccessFloor floor)
        {
            //var clt = CtrlClient;
            //clt.UserId = floor.id;
            await _homeService.SetAccessFloorAsync(floor);
            //var token = _appService.GetUserToken(this.CtrlClient, 5, 1);
            return GetResponse<string>(ApiResult.Success, null);
        }

        /// <summary>
        /// Get Access Floors  dùng api để nó list ra các tầng và QRCode
        /// </summary>
        /// <param name="id"></param>
        /// <param name="mode_sel">với mode_sel 0: gọi chọn tầng, 1: chọn một tầng</param>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<HomAccessGet>> GetAccessFloors([FromQuery] string id, [FromQuery] int mode_sel)
        {
            var result = await _homeService.GetAccessFloorsAsync(id, mode_sel);
            //result.token = _appService.GetUserToken(this.CtrlClient, 5, mode_sel);
            return GetResponse(ApiResult.Success, result);
        }


        /// <summary>
        /// Get ElevatorFloor Page
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        //[ApiKey]
        public async Task<ResponseList<List<CardInfo>>> GetMasElevatorCards(
            [FromQuery] FilterInputBuilding flt
            )
        {
            var result = await _homeService.GetMasElevatorCardsAsync(flt);
            return result;
        }

        /// <summary>
        /// Get ElevatorFloor Page
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="buildCd"></param>
        /// <param name="buildZone"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<CommonDataPage>> GetElevatorFloorPage([FromQuery] string filter,
                                                                               [FromQuery] int? offSet,
                                                                               [FromQuery] int? pageSize,
                                                                               [FromQuery] string projectCd,
                                                                               [FromQuery] string buildCd,
                                                                               [FromQuery] string buildZone)
        {
            var flt = new FilterElevatorFloor(ClientId, UserId, offSet, pageSize, filter, projectCd, buildCd, buildZone);
            var result = await _homeService.GetMasElevatorFloorPageAsync(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get BuildFloorBy ProjectCdBuildCd
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="buildCd"></param>
        /// <param name="buildZone"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        public async Task<BaseResponse<List<ElevatorFloor>>> GetBuildFloorByProjectCdBuildCd([FromQuery] string projectCd,
             [FromQuery] string buildCd, [FromQuery] string buildZone)
        {
            var result = await _homeService.GetBuildFloorByProjectCdBuildCdAsync(projectCd, buildCd, buildZone);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get FloorType ByBuildCd
        /// </summary>
        /// <param name="buildCd"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<ElevatorFloorType>>> GetFloorTypeByBuildCd([FromQuery] string buildCd)
        {
            var result = await _homeService.GetFloorTypeByBuildCdAsync(buildCd);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get ElevatorDevice Page
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="buildCd"></param>
        /// <param name="buildZone"></param>
        /// <param name="floorNumber"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<CommonDataPage>> GetElevatorDevicePage([FromQuery] string filter,
                                                                               [FromQuery] int? offSet,
                                                                               [FromQuery] int? pageSize,
                                                                               [FromQuery] string projectCd,
                                                                               [FromQuery] string buildCd,
                                                                               [FromQuery] string buildZone,
                                                                                [FromQuery] int floorNumber)
        {
            var flt = new FilterElevatorDevice(ClientId, UserId, offSet, pageSize, filter, projectCd, buildCd, buildZone, floorNumber, "");
            var result = await _homeService.GetMasElevatorDevicePageAsync(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get card type list
        /// </summary> 
        /// <returns></returns>
        /// 
        //[ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        //[ApiKey]
        public async Task<ResponseList<List<HomCardTypeGet>>> GetCardTypeList()
        {
            var result = await _homeService.GetCardTypeListAsync();
            return result;
        }
        /// <summary>
        /// Get Project
        /// </summary>
        /// <returns></returns>

        //[ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<ProjectApp>>> GetProjects()
        {
            var result = await _homeService.GetProjectsAsync(UserId);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get BuildCd By ProjectCd
        /// </summary>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<ElevatorBuilding>>> GetBuildCdByProjectCd([FromQuery] string projectCd)
        {
            var result = await _homeService.GetBuildCdByProjectCdAsync(projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get List Elevator Floor
        /// </summary>
        /// <param name="buildCd"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<ElevatorFloor>>> GetElevatorFloors([FromQuery] string buildCd, [FromQuery] string projectCd = null)
        {
            var result = await _homeService.GetElevatorFloorsAsync(buildCd, projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set MasElevatorCard
        /// </summary>
        /// <param name="mas_elevator_card"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<MAS_Elevator_Card>> SetMasElevatorCard([FromBody] MAS_Elevator_Card mas_elevator_card)
        {
            var result = await _homeService.SetMAS_Elevator_CardAsync(mas_elevator_card);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetCardCustomers
        /// </summary>
        /// <param name="cardCd"></param>
        /// <returns></returns>
        //[ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        //[ApiKey]
        public async Task<BaseResponse<List<CardCustomer>>> GetCardCustomers([FromQuery] string cardCd)
        {
            var result = await _homeService.GetCardCustomersAsync(cardCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set MasElevatorDevice
        /// </summary>
        /// <param name="mas_elevator_device"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetMasElevatorDevice([FromBody] MAS_Elevator_Device mas_elevator_device)
        {
            await _homeService.SetMAS_Elevator_DeviceAsync(mas_elevator_device);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Mas ElevatorFloor
        /// </summary>
        /// <param name="mas_evalator_floor"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetMasElevatorFloor([FromBody] MAS_Elevator_Floor mas_evalator_floor)
        {
            await _homeService.SetMAS_Elevator_FloorAsync(mas_evalator_floor);
            return GetResponse<string>(ApiResult.Success, null);
        }

        /// <summary>
        /// Get FoorInfo Go
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<FloorInfoGo>>> GetFoorInfoGo([FromQuery] FilterElevatorFloor flt
            )
        {
            var result = await _homeService.GetFoorInfoGoAsync(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get BuildZone By BuildCd
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="buildCd"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<ElevatorBuildZone>>> GetBuildZoneByBuildCd([FromQuery] string projectCd, [FromQuery] string buildCd)
        {
            var result = await _homeService.GetBuildZoneByBuildCdAsync(projectCd, buildCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="MasECid"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpDelete]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> DeleteMasElevatorCard([FromQuery] string ids)
        {
            await _homeService.DeleteMasElevatorCardAsync(ids);
            return GetResponse<string>(ApiResult.Success, null);
        }
    }
}

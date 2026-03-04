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
using UNI.Resident.Model.Elevator;

namespace UNI.Resident.API.Controllers.Version2.Elevator
{
    /// <summary>
    /// ElevatorController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/elevatorcard/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ElevatorCardController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IElevatorCardService _homeService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ElevatorController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ElevatorCardController(
            IElevatorCardService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _mapper = mapper;
            _homeService = homeService;
        }
        /// <summary>
        /// GetElevatorCards thông tin thẻ
        /// </summary>
        /// <param name="cardId"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetElevatorCards([FromQuery] string cardId, [FromQuery] string filter)
        {
            var result = await _homeService.GetElevatorCards(cardId, filter);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetElevatorCardsInfo - thông tin chi tiết thẻ
        /// </summary>
        /// <param name="cardId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ElevatorCardInfo>> GetElevatorCardsInfo([FromQuery] string cardId)
        {
            var result = await _homeService.GetElevatorCardsInfo(cardId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetElevatorCardsDraft - Lấy dữ liệu filter cho thiết bị thang máy
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ElevatorCardInfo>> GetElevatorCardsDraft([FromBody] ElevatorCardInfo draft)
        {
            var result = await _homeService.GetElevatorCardsDraft(draft);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetElevatorCardFilter - Lấy dữ liệu filter cho thiết bị thang máy
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetElevatorCardFilter()
        {
            var result = await _homeService.GetElevatorCardFilter();
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get ElevatorCard Page - Xem danh sách thiết bị thang máy
        /// </summary>
        /// <param name="cardId"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd"></param>
        /// <param name="buildZone"></param>
        /// <param name="floorNumber"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetElevatorCardPage([FromQuery] string cardId, [FromQuery] string filter,
            [FromQuery] int? offSet, [FromQuery] int? pageSize, 
            [FromQuery] string projectCd, [FromQuery] string buildingCd, [FromQuery] string buildZone, [FromQuery] int floorNumber)
        {
            var flt = new FilterElevatorDevice(ClientId, UserId, offSet, pageSize, filter, projectCd, buildingCd, buildZone, floorNumber, cardId);
            var result = await _homeService.GetElevatorCardPage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set GetElevatorDeviceInfo - Thêm/Sửa thiết bị thang máy
        /// </summary>
        /// <param name="Oid"></param>
        /// <param name="cardId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewIdInfo>> GetElevatorCardInfo(string Oid, [FromQuery] string cardId)
        {
            var result = await _homeService.GetElevatorCardInfo(Oid, cardId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set MasElevatorCard - Thêm/Sửa thiết bị thang máy
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<CommonViewIdInfo>> SetElevatorCardDraft([FromBody] CommonViewIdInfo info)
        {
            var result = await _homeService.SetElevatorCardDraft(info);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set MasElevatorCard - Thêm/Sửa thiết bị thang máy
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetElevatorCardInfo([FromBody] CommonViewIdInfo info)
        {
            var result = await _homeService.SetElevatorCardInfo(info);
            return GetResponse<string>(ApiResult.Success, result.messages);
        }

        /// <summary>
        /// Delete ElevatorCard - Xóa thiết bị thang máy
        /// </summary>
        /// <param name="Oid"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelElevatorCardInfo([FromBody] IEnumerable<Guid> oids)
        {
            var result = await _homeService.DelElevatorCardInfo(oids);
            return GetResponse<string>(ApiResult.Success, result.messages);
        }
    }
}

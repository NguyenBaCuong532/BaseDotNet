using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Card
{

    /// <summary>
    /// Card Controller
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/carddaily/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardDailyController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly ICardDailyService _cardService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CardController"/> class.
        /// </summary>
        /// <param name="cardService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        /// <param name="importManagerService"></param>
        public CardDailyController(ICardDailyService cardService,
            //IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IMetaImportService importManagerService) : base(appSettings, logger)
        {
            _cardService = cardService;
        }
        #endregion instance-reg

        /// <summary>
        /// GetVehicleCardDailyFilter - Bộ lọc thẻ lượt
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetVehicleCardDailyFilter()
        {
            var result = _cardService.GetVehicleCardDailyFilter();
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetVehicleCardDailyPage - Danh sách thẻ lượt
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehicleCardDailyPage([FromQuery] VehicleCardDailyRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _cardService.GetVehicleCardDailyPage(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetVehicleHistoryChange - lấy lịch sử chi tiết thẻ xe
        /// </summary>
        /// <param name="query"> id thẻ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehicleHistoryChange([FromQuery] VehicleHistoryChange query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _cardService.GetVehicleHistoryChange(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }
    }
}

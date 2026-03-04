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
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.Model;

namespace UNI.Resident.API.Controllers.Version2.Elevator
{

    /// <summary>
    /// ElevatorController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/elevator/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ElevatorController : UniController
    {

        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IElevatorService _homeService;
        private readonly IAppManagerService _appService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ElevatorController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ElevatorController(IElevatorService homeService,
            IAppManagerService appService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
            _appService = appService;
        }

        /// <summary>
        /// Get Card By Controle
        /// </summary>
        /// <param name="card_code">decimal card code or qrcode</param>
        /// <param name="card_type">1:NFC; 2: WG; 3: FACE; 4: VTO; 5: QR</param>
        /// <param name="reader_id">hardware id</param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpGet]
        [AllowAnonymous]
        public async Task<BaseResponse<HomCardAccess>> GetAccessCard([FromQuery] string card_code, [FromQuery] int card_type, [FromQuery] string reader_id)
        {
            if (card_type == 5)
            {
                var tken = _appService.GetUserByToken(card_code, card_type);
                if (tken != null)
                {
                    var access = await _homeService.GetCardEvevateAsync(tken.userId, card_code, card_type, reader_id, tken.mode);
                    if (access != null)
                        return GetResponse(ApiResult.Success, access);
                    else
                        return GetResponse(ApiResult.Invalid, access);
                }
                else
                {
                    return GetResponse<HomCardAccess>(ApiResult.Invalid, null);
                }
            }
            else
            {
                var result = await _homeService.GetCardEvevateAsync(UserId, card_code, card_type, reader_id, 0);
                if (result != null)
                    return GetResponse(ApiResult.Success, result);
                else
                    return GetResponse(ApiResult.Invalid, result);
            }
        }


        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetElevatorUsageHistoryPage([FromQuery] FilterBase query)
        {
            try
            {
                var projectCd = Request.Headers["projectcode"].ToString();
                var rs = await _homeService.GetElevatorUsageHistoryPage(query, projectCd);
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

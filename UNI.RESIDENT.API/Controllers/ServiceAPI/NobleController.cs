using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.API.Attributes;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM;

namespace UNI.Resident.API.Controllers.ServiceAPI
{
    /// <summary>
    /// NobleController 
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class NobleController : UniController
    {
        private readonly INobleService _nobleService;

        /// <summary>
        /// Initializes a new instance of the <see cref="UserRolesController"/> class.
        /// </summary>
        /// <param name="appSettings">The application settings.</param>
        /// <param name="logger">The logger.</param>
        /// <param name="mapper">The mapper.</param>
        /// <param name="nobleService"></param>
        /// Author: duongpx
        /// CreatedDate: 07/02/2017 9:32 AM
        public NobleController(
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            INobleService nobleService) : base(appSettings, logger)
        {
            _nobleService = nobleService;
        }

        /// <summary>
        /// Get Apartmnet Owner By PhoneNumber
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<ApartmentOwner>> GetApartmnetOwnerByPhoneNumber([FromQuery] string phone)
        {
            var result = await _nobleService.GetApartmnetOwnerByPhoneNumber(phone);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetApartmentByPhone - 
        /// </summary>
        /// <param name="phone"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetApartmentByPhone([FromQuery] string phone)
        {
            var result = await _nobleService.GetApartmentByPhone(phone);
            return Ok(new BaseResponse<List<ApartmentInfo>>
            {
                Data = result
            });
        }

    }
}

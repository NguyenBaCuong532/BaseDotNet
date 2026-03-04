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
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Aparment
{

    /// <summary>
    /// Apartment Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/household/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class HouseholdController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IHouseholdService _householdService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="HouseholdController"/> class.
        /// </summary>
        /// <param name="householdService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public HouseholdController(IHouseholdService householdService,
            IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _householdService = householdService;
            //_userService = userService;
            _mapper = mapper;
        }

        #region Household

        /// <summary>
        /// GetApartmentHouseholdFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetHouseholdFilter()
        {
            var result = await _householdService.GetHouseholdFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        
        /// <summary>
        /// GetHouseholdPageAsync - Danh sách hộ khẩu
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetHouseholdPage([FromQuery] HouseholdRequestModel1 query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _householdService.GetHouseholdPage(query);
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
        /// GetApartmentHouseholdPageAsync - Danh sách hộ khẩu theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetHouseholdPageByApartment([FromQuery] HouseholdRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _householdService.GetHouseholdPageByApartment(query);
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
        /// GetApartmentHouseholdInfoAsync - Thêm/sửa thông tin hộ khẩu
        /// </summary>
        /// <param name="CustId">Mã khách hàng</param>
        /// <param name="ApartmentId">ID căn hộ (int) - backward compatible</param>
        /// <param name="apartOid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <param name="Oid">Mã định danh hộ khẩu (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<HouseholdInfo>> GetHouseholdInfo([FromQuery] string CustId, [FromQuery] int? ApartmentId, [FromQuery] Guid? apartOid, [FromQuery] Guid? Oid)
        {
            try
            {
                var rs = await _householdService.GetHouseholdInfo(CustId, ApartmentId, apartOid, Oid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<HouseholdInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetApartmentHouseholdInfoAsync - Thêm/sửa thông tin hộ khẩu
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetHouseholdInfo([FromBody] HouseholdInfo info)
        {
            try
            {
                var rs = await _householdService.SetHouseholdInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        #endregion

    }
}

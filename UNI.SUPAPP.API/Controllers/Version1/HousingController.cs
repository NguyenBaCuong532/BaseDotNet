using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SSG.BLL.BusinessServiceInterfaces;
using UNI.Model;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// SSME Api for app mobile 
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="Microsoft.AspNetCore.Mvc.ControllerBase" />
    [Route("api/v1/housing/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class HousingController : SSGController
    {

        /// <summary>
        /// The housing controller
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/03/2020 2:11 PM
        //private readonly ISHousingService _houService;
        private readonly IAppManagerService _appService;
        private readonly IUserService _userService;
        private readonly IMapper _mapper;
        private IWebHostEnvironment _hostingEnvironment;
        /// <summary>
        /// Initializes a new instance of the <see cref="HousingController"/> class.
        /// </summary>
        /// <param name="houService"></param>
        /// <param name="globalService"></param>
        /// <param name="appService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        /// <param name="environment"></param>
        public HousingController(
            //ISHousingService houService,
            IAppManagerService appService,
            IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IWebHostEnvironment environment) : base(appSettings, logger)
        {
            //_houService = houService;
            _mapper = mapper;
            _appService = appService;
            _userService = userService;
            _hostingEnvironment = environment;
        }

        #region Saler Visit
        ///// <summary>
        ///// Lấy danh sách ngân hàng
        ///// </summary>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<List<Bank>> GetBanks()
        //{
        //    var result = _houService.GetBanks();
        //    //result.SetStatus(ApiResult.Success);
        //    return GetResponse(ApiResult.Success, result);
        //}
        
        
        ///// <summary>
        ///// Lấy danh sách các sự kiện và căn hộ mẫu
        ///// </summary>
        ///// <param name="filter"></param>
        ///// <param name="offSet"></param>
        ///// <param name="pageSize"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public ResponseList<List<EventAndSample>> GetEventAndSamples([FromQuery] string filter, [FromQuery] int offSet, [FromQuery] int pageSize)
        //{
        //    var flt = new FilterBase(this.ClientId, this.UserId, offSet, pageSize, filter);
        //    var result = _houService.GetEventAndSamples(flt);
        //    result.SetStatus(ApiResult.Success);
        //    return result;
        //}

        ///// <summary>
        ///// Xóa cuộc hẹn
        ///// </summary>
        ///// <param name="id"></param>
        ///// <returns></returns>
        //[HttpDelete]
        //public async Task<BaseResponse<string>> DeleteAppointment([FromQuery] int id)
        //{
        //    await _houService.DeleteAppointment(this.UserId, id);
        //    return GetResponse<string>(ApiResult.Success, null);
        //}

        ///// <summary>
        ///// Phê duyệt cuộc hẹn
        ///// </summary>
        ///// <param name="id"></param>
        ///// <returns></returns>
        //[HttpPut]
        //public async Task<BaseResponse<string>> ApproveAppointment([FromQuery] int id)
        //{
        //    await _houService.ApproveAppointment(this.UserId, id);
        //    return GetResponse<string>(ApiResult.Success, null);
        //}

        ///// <summary>
        ///// Thêm cuộc hẹn thăm nhà mẫu
        ///// </summary>
        ///// <param name="appointment"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public BaseResponse<AppointmentGetNew> SetAppointment([FromBody] AppointmentNew appointment)
        //{
        //    var result = _houService.SetAppointment(this.UserId, appointment);
        //    return GetResponse<AppointmentGetNew>(ApiResult.Success, result);
        //}

        ///// <summary>
        ///// Lấy danh sách các cuộc hẹn
        ///// </summary>
        ///// <param name="id"></param>
        ///// <param name="aporoveStatus"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<List<AppointmentGetNew>> GetAppointmens([FromQuery] int? id, [FromQuery] int? aporoveStatus)
        //{

        //    var result = _houService.GetAppointmens(this.UserId, id, aporoveStatus);
        //    return GetResponse<List<AppointmentGetNew>>(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// Tính lãi suất ngân hàng
        ///// </summary>
        ///// <param name="houseInterest"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<HouseInterestGet> GetInterest([FromQuery] HouseInterest houseInterest)
        //{

        //    var result = _houService.GetInterest(this.UserId, houseInterest);
        //    return GetResponse<HouseInterestGet>(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// Lấy thông tin tính lãi suất theo dự án
        ///// </summary>
        ///// <param name="projectCd"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<HouseInterest> GetInterestInfoByProject([FromQuery] string projectCd)
        //{

        //    var result = _houService.GetInterestInfoByProject(projectCd);
        //    return GetResponse<HouseInterest>(ApiResult.Success, result);
        //}


        ///// <summary>
        ///// Get Admin Daily ByTime
        ///// </summary>
        ///// <param name="dateSelect"></param>
        ///// <param name="numberDate"></param>
        ///// <param name="projectType"></param>
        ///// <param name="projectCd"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<SreAdmDailyByTime> GetAdmDailyByTime([FromQuery] string dateSelect, [FromQuery] int numberDate,
        //    [FromQuery] int projectType, [FromQuery] string projectCd)
        //{
        //    var result = _shousingService.GetAdmDailyByTime(dateSelect, numberDate, projectType, projectCd);
        //    return GetResponse(ApiResult.Success, result);
        //}

        #endregion saler visit
    }
}

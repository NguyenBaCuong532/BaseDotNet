using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SSG.BLL.BusinessServiceInterfaces;
using SSG.Common;
using SSG.Model;
using SSG.Model.Api;
using SSG.Model.KSHome;
using SSG.Model.SHousing;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SSG.API.SupApp.Controllers.Version1
{

    /// <summary>
    /// SSME Api for app mobile 
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="Microsoft.AspNetCore.Mvc.ControllerBase" />
    [Route("api/v1/housing/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class KSHomeController : SSGController
    {

        /// <summary>
        /// KSHome Controller
        /// </summary>
        /// Author: hoanpv
        /// CreatedDate: 12/03/2020 2:11 PM
        private readonly IKSHomeService _kSHomeService;
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
        public KSHomeController(
            IKSHomeService kSHomeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IWebHostEnvironment environment) : base(appSettings, logger)
        {
            _kSHomeService = kSHomeService;
            _mapper = mapper;
            _hostingEnvironment = environment;
        }

        #region KSHome-Manager-App

        #endregion
        #region KSHome-App
        /// <summary>
        /// GetRoomOpenSaleList - Lấy danh sách căn hộ - Home - Apartment More screen
        /// </summary>
        /// <param name="isFeature">Nổi bật : isFeature = true, isFavorite =false, isBuyed=false</param>
        /// <param name="isFavorite">Yêu thích : isFeature = false, isFavorite =true, isBuyed=false</param>
        /// <param name="isBuyed">Đã mua : isFeature = false, isFavorite =false, isBuyed=true</param>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd"></param>
        /// <param name="styleNum"></param>
        /// <param name="positionId"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ResponseList<List<ksHroomOpen>>> GetRoomOpenSaleList([FromQuery] bool isFeature=true,
                                                       [FromQuery] bool isFavorite=false,
                                                       [FromQuery] bool isBuyed=false,
                                                       [FromQuery] string projectCd="05",
                                                       [FromQuery] string buildingCd="0501",
                                                       [FromQuery] int styleNum=3,
                                                       [FromQuery] int positionId=2,
                                                       [FromQuery] int offSet=1,
                                                       [FromQuery] int pageSize=100)
        {
            var flt = new roomopenSalesFilter(this.UserId,
                                              this.ClientId,
                                              null,
                                              offSet,
                                              pageSize,
                                              isFeature,
                                              isFavorite,
                                              isBuyed,
                                              projectCd,
                                              buildingCd,
                                              styleNum,
                                              positionId);
            var result = await _kSHomeService.GetRoomOpenSaleList(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }
       
        /// <summary>
        /// GetFilterApartment - lấy dữ liệu filter theo dự án - ApartmentFilter screen
        /// </summary>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ksHFilterAparment>> GetFilterApartment( [FromQuery] string projectCd)
        {

            var result = await _kSHomeService.GetFilterApartment(this.UserId, projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetRoomDetail - lấy dữ liệu chi tiết căn hộ - ApartmentDetail screen
        /// </summary>
        /// <param name="roomCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ksHroomOpenDetail>> GetKsRoomDetail([FromQuery] string roomCd)
        {

            var result = await _kSHomeService.GetRoomDetail(this.UserId, roomCd);
            return GetResponse(ApiResult.Success, result);
        }
        #endregion KSHome-App

    }
}

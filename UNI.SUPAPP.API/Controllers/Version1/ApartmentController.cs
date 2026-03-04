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
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// 
    /// </summary>
    /// Author: taint
    /// CreatedDate: 07/02/2017 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/apartment/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ApartmentController : SSGController
    {
        private const int APP_ID = 2;//"ssa_hom_serv"

        private readonly ISHomeService _homeService;
        //private readonly IUserAppService1 _userService;
        private readonly IAppManagerService _appService;
        //private readonly INotifyService _notiService;
        private readonly IMapper _mapper;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="userService"></param>
        /// <param name="appService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public ApartmentController(
            ISHomeService homeService,
            //IUserAppService1 userService,
            IAppManagerService appService,
            //INotifyService notiService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _homeService = homeService;
            //_userService = userService;
            //_notiService = notiService;
            _appService = appService;
        }
        #region App Home   
        /// <summary>
        /// GetPageHome
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<PageHome> GetPageHome()
        {
            var result = _homeService.GetPageHome(this.UserId);
            return GetResponse<PageHome>(ApiResult.Success, result);
        }

        /// <summary>
        /// Set Family mamber 
        /// </summary>
        /// <param name="reg"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentReg([FromBody] HomApartmentReg reg)
        {
            await _homeService.SetApartmentReg(this.CtrlClient, reg);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Get Apartment Rations
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<HomApartmentRelation>> GetApartmentRations()
        {
            var result = _homeService.GetApartmentRations(this.UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Project
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<ProjectApp>> GetProjectList()
        {
            var result = _homeService.GetProjects(this.UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Buildings
        /// </summary>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<HomBuilding>> GetBuildingList([FromQuery] string projectCd)
        {
            var result = _homeService.GetBuildings(projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Buildings
        /// </summary>
        /// <param name="buildingCd"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<HomFloor>> GetFloorList([FromQuery] string buildingCd)
        {
            var result = _homeService.GetFloorList(buildingCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Room List
        /// </summary>
        /// <param name="buildingCd"></param>
        /// <param name="floorNo"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<HomRoom>> GetRoomList([FromQuery] string buildingCd, string floorNo)
        {
            var result = _homeService.GetRooms(buildingCd, floorNo);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get apartment profile
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<HomApartmentPageHome> GetApartmentProfile()
        {
            var result = _homeService.GetApartmentPageHome(UserId, this.AcceptLanguage);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Apartment Page
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<homApartmentPage> GetApartmentPage()
        {
            var result = _homeService.GetApartmentList(this.UserId);
            return GetResponse(ApiResult.Success, result);
        }
        
        /// <summary>
        /// Set Apartment Main
        /// </summary>
        /// <param name="main"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentMain([FromBody] HomApartmentStatus main)
        {
            await _homeService.SetApartmentMain(this.UserId, main);
            return GetResponse<string>(ApiResult.Success, null);
        }
        
        /// <summary>
        /// Get Apartment by Cart
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<homApartmentCartPage> GetApartmentCarts()
        {
            var result = _homeService.GetApartmentCarts(this.UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Apartment by Cart
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<homApartmentCartDetail> GetApartmentCartDetail([FromQuery] string roomCd)
        {
            var result = _homeService.GetApartmentCartDetail(this.UserId, this.AcceptLanguage, roomCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Family profile or user profile
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<PageFamilyMember> GetMemberPage([FromQuery] int? apartmentId)
        {
            var result = _homeService.GetPageFamilyMember(this.UserId, apartmentId);
            return GetResponse(ApiResult.Success, result);
        }
        
        /// <summary>
        /// Set Member Profile
        /// </summary>
        /// <param name="profile"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<HomApartmentMemberGet>> SetMemberProfile([FromBody] HomMemberProfileSet profile)
        {
            var result = await _homeService.SetMemberProfile(this.UserId, profile);
            return GetResponse<HomApartmentMemberGet>(ApiResult.Success, result);
        }
        /// <summary>
        /// Delete family member
        /// </summary>
        /// <param name="custId"></param>
        /// <param name="apartmentId"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteMember([FromQuery] string custId, [FromQuery] int apartmentId)
        {
            var memb = _homeService.GetFamilyMember(this.UserId, custId, apartmentId);
            if (memb != null)
            {
                var result = await _homeService.DeleteFamilyMember(this.UserId, custId, apartmentId);
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetResponse<string>(ApiResult.DeleteFail, null);
            }
        }
        /// <summary>
        /// Set Auth Family Member
        /// </summary>
        /// <param name="customer"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetMemberApprove([FromBody] HomMemberBase customer)
        {
            await _homeService.SetFamilyMemberAuth(this.CtrlClient, customer);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Reject Family Member
        /// </summary>
        /// <param name="customer"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetMemberReject([FromBody] HomMemberBase customer)
        {
            await _homeService.SetFamilyMemberReject(this.CtrlClient, customer);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Get list of family cards 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<PageFamilyCard> GetCardPage([FromQuery] int? ApartmentId)
        {
            var result = _homeService.GetPageFamilyCard(this.UserId, ApartmentId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get the Card detail
        /// </summary>
        /// <param name="cardCd"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<HomCardService> GetCardDetail([FromQuery] string cardCd)
        {
            var result = _homeService.GetCardDetail(cardCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get CardTypes
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<IEnumerable<HomCardType>> GetCardTypes()
        {
            var result = _homeService.GetCardTypes();
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Register card 
        /// </summary>
        /// <param name="cardReg"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetCardRegister([FromBody] HomCardRegSet cardReg)
        {
            var result = await _homeService.SetCardRegister(this.UserId, cardReg);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Card Vehicle Service
        /// </summary>
        /// <param name="vehicle"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetCardVehicle([FromBody] HomServiceVehicleSet vehicle)
        {
            await _homeService.SetCardServiceVehicle(this.UserId, vehicle);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Card Lost
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetCardLost([FromBody] HomCardBase card)
        {
            var result = await _homeService.SetCardLost(this.UserId, card);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                var response = GetResponse<string>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        /// <summary>
        /// Get Vehicle Type List
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<IEnumerable<HomVehicleType>> GetVehicleTypes()
        {
            var result = _homeService.GetVehicleTypes();
            return GetResponse(ApiResult.Success, result);
        }
        
        #endregion

        #region App pay   

        /// <summary>
        /// Get Page Payment
        /// </summary>
        /// <param name="payType"></param>
        /// <param name="apartmentId"></param>
        /// <param name="month"></param>
        /// <param name="year"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<PagePayment> GetPagePayments([FromQuery] int? payType, [FromQuery] long apartmentId, 
            [FromQuery] int? month, [FromQuery] int? year, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBasePayment(this.ClientId, this.UserId, offSet, pageSize, apartmentId, month, year, payType);
            var result = _homeService.GetPagePayment(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Payment Detail
        /// </summary>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<HomPaymentGet> GetPaymentDetail([FromQuery] int receiveId)
        {
            var result = _homeService.GetPaymentDetail(this.UserId, receiveId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Payment Detail
        /// </summary>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<HomTransferInfo> GetTransferInfo([FromQuery] int receiveId)
        {
            var result = _homeService.GetTransferInfo(this.UserId, receiveId);
            return GetResponse(ApiResult.Success, result);
        }

        #endregion

        #region request-reg
        /// <summary>
        /// Get Request Type list  
        /// </summary>
        /// <param name="categoryType">value 1: Request repair or serice. value 2: utility sport, club</param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<HomRequestCategoryGet>> GetRequestCategotyList([FromQuery] int categoryType)
        {
            var result = _homeService.GetRequestCategoryList(this.UserId, categoryType, this.AcceptLanguage);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Request Statuses
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<CommonValue>> GetRequestStatuses()
        {
            var result = _homeService.GetBaseStatus(this.UserId, "Request");
            return GetResponse<List<CommonValue>>(ApiResult.Success, result);
        }
        /// <summary>
        /// create request
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetRequest([FromBody] HomRequestSet request)
        {
            await _homeService.SetRequest(this.UserId, request);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Get list Get Request 
        /// </summary>
        /// <param name="ApartmentId"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<PageRequestFix> GetPageRequest([FromQuery] int? ApartmentId, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBaseApartment(this.ClientId, this.UserId, offSet, pageSize, ApartmentId);
            var result = _homeService.GetPageRequest(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Request Confirm
        /// </summary>
        /// <param name="confirm"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetRequestConfirm([FromBody] HomRequestBase confirm)
        {
            await _homeService.SetRequestConfirm(this.UserId, confirm);
            var process = new HomRequestProcess { RequestId = confirm.requestId, Comment = "Xác nhận hoàn thành", attachs = null, Status = 4 };
            await _homeService.SetRequestProcess(this.UserId, process);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Request Voted
        /// </summary>
        /// <param name="request">
        /// - rating: đánh giá dang int từ 1-5
        /// - comment: nội dung đánh giá
        /// </param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetRequestVoted([FromBody] HomRequestVote request)
        {
            await _homeService.SetRequestVoted(this.UserId, request);
            var process = new HomRequestProcess { RequestId = request.requestId, Comment = request.Comment, attachs = request.attachs, Status = 4 };
            await _homeService.SetRequestProcess(this.UserId, process);
            return GetResponse<string>(ApiResult.Success, null);
        }
        
        /// <summary>
        /// create request
        /// </summary>
        /// <param name="requestId"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<HomRequest> GetRequest([FromQuery] long requestId)
        {
            var result = _homeService.GetRequest(this.UserId, requestId);
            return GetResponse<HomRequest>(ApiResult.Success, result);
        }
        #endregion request-reg

        #region feedback-reg
        ///// <summary>
        ///// Get FeedbackType list
        ///// </summary>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<IEnumerable<FeedbackType>> GetFeedbackType()
        //{
        //    var result = _userService.GetFeedbackType(this.CtrlClient);
        //    return GetResponse(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// Send feed back
        ///// </summary>
        ///// <param name="feedback"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<string>> SendFeedback([FromBody] Feedback feedback)
        //{
        //    await _userService.SendFeedback(this.CtrlClient, feedback);
        //    return GetResponse<string>(ApiResult.Success, null);
        //}

        #endregion feedback-reg

        #region Elevator-reg
        /// <summary>
        /// Get Access Code
        /// </summary>
        /// <param name="mode_sel">0: multi select; 1: single select</param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<string> GetAccessCode([FromQuery] int mode_sel)
        {
            var token = _appService.GetUserToken(this.CtrlClient, 5, mode_sel);
            return GetResponse(ApiResult.Success, token);
        }
        /// <summary>
        /// Set Access Floor - Dung để chọn 1 tầng trước
        /// </summary>
        /// <param name="floor"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetAccessFloor([FromBody] HomAccessFloor floor)
        {
            await _homeService.SetAccessFloor(this.CtrlClient, floor);
            var token = _appService.GetUserToken(this.CtrlClient, 5, 1);
            return GetResponse<string>(ApiResult.Success, token);
        }
        /// <summary>
        /// Get Access Floors  dùng api để nó list ra các tầng và QRCode
        /// </summary>
        /// <param name="mode_sel">với mode_sel 0: gọi chọn tầng, 1: chọn một tầng</param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<HomAccessGet> GetAccessFloors([FromQuery] int mode_sel)
        {
            var result = _homeService.GetAccessFloors(this.UserId, mode_sel);
            result.token = _appService.GetUserToken(this.CtrlClient, 5, mode_sel);
            return GetResponse<HomAccessGet>(ApiResult.Success, result);
        }

        #endregion Elevator-reg
    }
}

using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.Model;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Reports
{
    /// <summary>
    /// ReportController 
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/report/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ReportController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IReportService _homeService;
        private readonly IUserService _userService;
        private readonly IMapper _mapper;
        //private readonly IReportService _service;
        /// <summary>
        /// Initializes a new instance of the <see cref="MaterialController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        /// /// <param name="service"></param>
        public ReportController(
            IReportService homeService,
            IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _userService = userService;
            _mapper = mapper;
            //_service = homeService;
            //_appService = appService;
            //_custService = custService;
        }
        /// <summary>
        /// Get Dashboard
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<HomDashboard>> GetDashboard([FromQuery] string projectCd)
        {
            if (projectCd == null)
            {
                projectCd = await _userService.GetUserProject(UserId);
            }
            var result = await _homeService.GetHomeDashboard(projectCd);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get Payment List for Manager
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd"></param>
        /// <param name="floor"></param>
        /// <param name="roomCd"></param>
        /// <param name="month"></param>
        /// <param name="year"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        //[Authorize(Roles = UNIPolicy.SHOME_MAN)]
        public async Task<ResponseList<List<HomFollowDebit>>> GetFollowDebits([FromQuery] string projectCd,
            [FromQuery] string buildingCd,
            [FromQuery] string floor,
            [FromQuery] string roomCd,
            [FromQuery] int? month, [FromQuery] int? year, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            projectCd = await _userService.GetUserProject(UserId);
            var flt = new FilterBasePayments(ClientId, UserId, offSet, pageSize, projectCd, roomCd, buildingCd, floor, month, year);
            var result = await _homeService.GetPaymentList(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        /// <summary>
        /// ApartmentFeeReport
        /// </summary>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task ApartmentFeeReport([FromQuery] int receiveId)
        {
            await Task.Run(() => _homeService.SetServiceBillGoogleDriver(receiveId));
        }
        /// <summary>
        /// Report of service requesting 
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<HomRequestService>>> ServiceRequestReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate, 
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.ServiceRequestReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }
        /// <summary>
        /// Report stream of service requesting 
        /// </summary>
        /// <param name="type"></param>
        /// <param name="projectCd"></param>
        /// <param name="projectName"></param>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        //[HttpGet]
        //public IActionResult ServiceRequestFile([FromQuery] string type,
        //    [FromQuery] string projectCd, [FromQuery] string projectName,
        //    [FromQuery] string fromDate, [FromQuery] string toDate)
        //{
        //    Stream stream = _homeService.ServiceRequestFile(type, projectCd, projectName, fromDate, toDate);
        //    if (stream == null)
        //        return NotFound();
        //    return File(stream, "application/octet-stream");
        //}

        // (Báo cáo danh sách xe đã bị xóa khỏi hệ thống)
        /// <summary>
        /// Report of vehicles were removed from system
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<HomCardVehicleGet>>> VehicleRemovedReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate, 
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.VehicleRemovedReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }
        /// <summary>
        /// Report of vehicles were added for service
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<HomCardVehicleGet>>> VehicleAddedReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate,
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.VehicleAddedReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }
        /// <summary>
        /// Report of vehicles were locked from service
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<HomCardVehicleGet>>> VehicleLockedReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate, 
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.VehicleLockedReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }

        /// <summary>
        /// Report of vehicles were locked from service
        /// </summary>
        /// <param name="type"></param>
        /// <param name="projectCd"></param>
        /// <param name="projectName"></param>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        //[HttpGet]
        //public IActionResult VehiclesLockedFile([FromQuery] string type,
        //    [FromQuery] string projectCd, [FromQuery] string projectName,
        //    [FromQuery] string fromDate, [FromQuery] string toDate)
        //{
        //    Stream stream = _homeService.VehiclesLockedFile(UserId, type, projectCd, projectName, fromDate, toDate);
        //    if (stream == null)
        //        return NotFound();
        //    return File(stream, "application/octet-stream");
        //}

        // (Báo cáo, thống kê số lượng, chi tiết thông tin khách thuê nhà theo dự án,)
        /// <summary>
        /// Report of apartments renting
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<ApartmentReceived>>> HouseRentedReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate, 
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.HouseRentedReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }

        /// <summary>
        /// Report of apartments renting
        /// </summary>
        /// <param name="type"></param>
        /// <param name="projectCd"></param>
        /// <param name="projectName"></param>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        //[HttpGet]
        //public IActionResult HouseRentedFile([FromQuery] string type,
        //    [FromQuery] string projectCd, [FromQuery] string projectName,
        //    [FromQuery] string fromDate, [FromQuery] string toDate)
        //{
        //    Stream stream = _homeService.HouseRentedFile(UserId, type, projectCd, projectName, fromDate, toDate);
        //    if (stream == null)
        //        return NotFound();
        //    return File(stream, "application/octet-stream");
        //}

        /// (báo cáo số lượng cư dân về nhận nhà) 
        /// <summary>
        /// Report of apartments received
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<ApartmentReceived>>> HouseReceivedReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate, 
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.HouseReceivedReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }

        // (đăng ký app mới trong tháng )
        /// <summary>
        /// Report of apartments linked app
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<ApartmentELinked>>> HouseELinkedReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate, 
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.HouseELinkedReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }
        // (Danh sách cư dân chưa được duyệt)
        /// <summary>
        /// Report of apartments members pending card
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="fromDate">2017-01-01</param>
        /// <param name="toDate">2050-12-30</param>
        /// <param name="offset"></param>
        /// <param name="pageSize"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public Task<ResponseList<List<ApartmentMember>>> HouseCardsPendingReport(
            [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate,
            [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        {
            return _homeService.HouseCardsPendingReport(UserId, projectCd, fromDate,
                toDate, filter, offset, pageSize);
        }
        ///// <summary>
        ///// Report of actions tracking
        ///// </summary>
        ///// <param name="projectCd"></param>
        ///// <param name="fromDate">2017-01-01</param>
        ///// <param name="toDate">2050-12-30</param>
        ///// <param name="status">0|1</param>
        ///// <param name="offset"></param>
        ///// <param name="pageSize"></param>
        ///// <param name="filter"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public Task<ResponseList<List<EActionGet>>> ActionsReport(
        //    [FromQuery] string projectCd, [FromQuery] string fromDate, [FromQuery] string toDate,
        //    [FromQuery] int? status,
        //    [FromQuery] int offset, [FromQuery] int pageSize, [FromQuery] string filter)
        //{
        //    return _homeService.ActionsReport(UserId, projectCd, fromDate,
        //        toDate, filter, offset, pageSize, status);
        //}

        ///// <summary>
        ///// Actions Tracking add 
        ///// (lưu vết thêm 1 action)
        ///// </summary>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<string>> AddAction([FromBody] EAction action)
        //{
        //    var result = await _homeService.AddAction(UserId, action);
        //    if (result.valid)
        //    {
        //        return GetResponse<string>(ApiResult.Success, null);
        //    }
        //    else
        //    {
        //        var response = GetResponse<string>(ApiResult.Error, null);
        //        response.SetStatus(2, result.messages);
        //        return response;
        //    }
        //}


        //[HttpGet]
        //public BaseResponse<List<housReportConfig>> GetReportList([FromQuery] int report_type)
        //{
        //    var result = _homeService.GetReportList(this.UserId, report_type);
        //    return GetResponse<List<housReportConfig>>(ApiResult.Success, result);
        //}


        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetHouseRentedList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetHouseRentedList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }

        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetVehicleLockedList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetVehicleLockedList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }

        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetRequestCustomerList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetRequestCustomerList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }


        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetApartmentInforList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetApartmentInforList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }

        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetApartmentCardsPendingList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetApartmentCardsPendingList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }

        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetReportVehiclesAddedList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetReportVehiclesAddedList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }

        [HttpGet]
        public BaseResponse<ggDriverFileDownload> GetReportVehiclesRemovedList([FromQuery] string type, [FromQuery] string projectcd, [FromQuery] string sei_dt_begin, [FromQuery] string sei_dt_end)
        {
            var data = _homeService.GetReportVehiclesRemovedList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data != null)
            {
                return GetResponse(ApiResult.Success, data);
            }
            else
            {
                var response = GetResponse<ggDriverFileDownload>(ApiResult.Error, null);
                response.SetStatus(2, "Lỗi không sinh ra file");
                return response;
            }
        }

        /// <summary>
        /// Get Report List
        /// </summary>
        /// <param name="report_type"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<resReportConfig>> GetReportList([FromQuery] int report_type)
        {
            var result = _homeService.GetReportList(this.UserId, this.AcceptLanguage, report_type);
            return GetResponse<List<resReportConfig>>(ApiResult.Success, result);
        }

        /// <summary>
        /// BuildingNameList
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<resBuildingConfig>> BuildingNameList()
        {
            var result = _homeService.BuildingNameList(this.UserId, this.AcceptLanguage);
            return GetResponse<List<resBuildingConfig>>(ApiResult.Success, result);
        }

        /// <summary>
        /// RoomCodeList
        /// </summary>
        /// <param name="roomCode"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<resRoomConfig>> RoomCodeList([FromQuery] string roomCode)
        {
            var result = _homeService.RoomCodeList(this.UserId, this.AcceptLanguage, roomCode);
            return GetResponse<List<resRoomConfig>>(ApiResult.Success, result);
        }

        /// <summary>
        /// ProjectBuildingRoomList
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonListPage>> ProjectBuildingRoomList([FromQuery] ReportBuildingRoomFilter filter)
        {
            filter.ucInput(this.UserId, this.ClientId, this.AcceptLanguage);
            var result = await _homeService.ProjectBuildingRoomList(filter, this.UserId, this.AcceptLanguage);
            return GetResponse(ApiResult.Success, result);
 
        }


        #region tonghopcongno
        /// <summary>
        /// Get Tổng hợp công nợ của khu dân cư
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<FileStreamResult> ReportResidentReceivablePayableSummary([FromBody] ReportReceivablePayable query)
        {
            try
            {
                query.UserId = UserId;
                DateTime fromDate = query.GetFromDate();
                DateTime toDate = query.GetToDate();

                if (toDate.Subtract(fromDate).TotalDays + 1 > 32)
                {
                    throw new Exception("Thời gian chọn báo cáo phải nhỏ hơn 31 ngày");
                }
                else
                {
                    var rs = await _homeService.ReportResidentReceivablePayableSummary(query, AcceptLanguage);
                    string fileName = $"tong_hop_cong_no_ngay_{DateTime.Now:yyyy-MM-dd_hhmmss}.xlsx";
                    return File(rs.Data, "application/octet-stream", fileName);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Error: {Message}", e.Message);
                throw e;
            }
        }
        #endregion tonghopcongno

        #region ChiTietCongNo
        /// <summary>
        /// Báo cáo chi tiết công nợ của khu dân cư
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<FileStreamResult> ReportResidentReceivablePayableDetail([FromBody] ReportReceivablePayable query)
        {
            try
            {
                query.UserId = UserId;
                DateTime fromDate = query.GetFromDate();
                DateTime toDate = query.GetToDate();

                if (toDate.Subtract(fromDate).TotalDays + 1 > 32)
                {
                    throw new Exception("Thời gian chọn báo cáo phải nhỏ hơn 31 ngày");
                }
                else
                {
                    var rs = await _homeService.ReportResidentReceivablePayableDetail(query, AcceptLanguage);
                    string fileName = $"chi_tiet_cong_no_ngay_{DateTime.Now:yyyy-MM-dd_hhmmss}.xlsx";
                    return File(rs.Data, "application/octet-stream", fileName);
                }
                
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Error: {Message}", e.Message);
                throw e;
            }
        }
        #endregion ChiTietCongNo






    }
}

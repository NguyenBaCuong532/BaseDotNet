using AutoMapper;
using DocumentFormat.OpenXml.Office2010.ExcelAc;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.BLL.HelperService;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.ServiceFee
{

    /// <summary>
    /// FeeServiceController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/feeservice/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class FeeServiceController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IFeeServiceService _feeServiceService;
        private readonly IMapper _mapper;
        private readonly IServiceLivingMeterElectricWaterService _feeElectricWater;
        private readonly IMetaImportService _importManagerService;

        /// <summary>
        /// Initializes a new instance of the <see cref="FeeServiceController"/> class.
        /// </summary>
        /// <param name="feeServiceService"></param>
        /// <param name="appSettings"></param>
        /// <param name="importManagerService"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public FeeServiceController(
            IFeeServiceService feeServiceService,
           IServiceLivingMeterElectricWaterService feeElectricWater,
            IOptions<AppSettings> appSettings,
            IMetaImportService importManagerService,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _feeServiceService = feeServiceService;
            _feeElectricWater = feeElectricWater;
            _mapper = mapper;
            _importManagerService = importManagerService;
        }
        #endregion instance-reg
        /// <summary>
        /// GetApartmentFeeInfo - Lấy thông tin phí dịch vụ theo căn hộ 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ApartmentFeeInfo>> GetApartmentFeeInfo([FromQuery] string ApartmentId)
        {

            try
            {
                var rs = await _feeServiceService.GetApartmentFeeInfo(ApartmentId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ApartmentFeeInfo>(ApiResult.Error, e.Message);
                return rp;
            }

        }
        /// <summary>
        /// SetApartmentFeeInfo - Lấy thông tin phí dịch vụ theo căn hộ bản nháp truyền lên
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ApartmentFeeInfo>> SetApartmentFeeInfoDraft([FromBody] ApartmentFeeInfo info)
        {

            try
            {
                var rs = await _feeServiceService.SetApartmentFeeInfoDraft(info);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ApartmentFeeInfo>(ApiResult.Error, e.Message);
                return rp;
            }

        }
        /// <summary>
        /// SetApartmentFeeInfo - sửa thông tin phí dv
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentFeeInfo([FromBody] ApartmentFeeInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetApartmentFeeInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }

        /// <summary>
        /// GetServiceCutHistoryPage - Lịch sử cắt điện nước
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceCutHistoryPage([FromQuery] ServiceCutHistoryFilterModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceCutHistoryPage(query);
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
        /// GetServiceCutHistoryInfo - Lấy chi tiết lịch sử dịch vụ
        /// </summary>
        /// <param name="Id"></param>
        /// <param name="ApartmentId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceCutHistoryInfo>> GetServiceCutHistoryInfo([FromQuery] string Id, [FromQuery] string ApartmentId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceCutHistoryInfo(Id, ApartmentId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceCutHistoryInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceCutHistoryInfo - Thêm lịch sử điện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceCutHistoryInfo([FromBody] ServiceCutHistoryInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceCutHistoryInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// DeleteServiceCutHistory - Xóa lịch sử điện nước.
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteServiceCutHistory([FromQuery] string Id)
        {
            try
            {
                var rs = await _feeServiceService.DeleteServiceCutHistory(Id);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }



        /// <summary>
        /// GetServiceLivingPage - Lấy danh sách công tơ điện nước theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceLivingPage([FromQuery] ServiceLivingRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceLivingPage(query);
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
        /// GetServiceLivingInfo - lấy chi tiết công tơ điện nước 
        /// </summary>
        /// <param name="LivingId"> id dịch vụ công tơ điện nước</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingInfo>> GetServiceLivingInfo([FromQuery] int? LivingId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceLivingInfo(LivingId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceLivingInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceLivingInfo - sửa thông tin phí dv điện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingInfo([FromBody] ServiceLivingInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceLivingInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// DeleteServiceLiving - Xóa phí điện nước
        /// </summary>
        /// <param name="LivingId">id dịch vụ công tơ điện nước</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteServiceLiving([FromQuery] int? LivingId)
        {
            try
            {
                var rs = await _feeServiceService.DeleteServiceLiving(LivingId);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }
        /// <summary>
        /// GetServiceExtendPage - Lấy danh sách dịch vụ mở rộng theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceExtendPage([FromQuery] ServiceExtendRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExtendPage(query);
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
        /// GetServiceExtendInfo - lấy chi tiết  internet - truyền hình
        /// </summary>
        /// <param name="LivingId"> id dịch vụ  internet - truyền hìnhc</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExtendInfo>> GetServiceExtendInfo([FromQuery] int? ExtendId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExtendInfo(ExtendId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceExtendInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceExtendInfo - sửa thông tin phí dv internet - truyền hình
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceExtendInfo([FromBody] ServiceExtendInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceExtendInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// DeleteServiceExtend - Xóa phí  internet - truyền hình
        /// </summary>
        /// <param name="LivingId">id dịch vụ  internet - truyền hình</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteServiceExtend([FromQuery] int? ExtendId)
        {
            try
            {
                var rs = await _feeServiceService.DeleteServiceExtend(ExtendId);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }

        #region LivingMeterElectricWater
        /// <summary>
        /// GetServiceLivingMeterFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetServiceLivingMeterElectricWaterFilter()
        {
            var result = _feeServiceService.GetServiceLivingMeterFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetServiceLivingMeterPage - Lấy danh sách chỉ số công tơ điện nước
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceLivingMeterElectricWaterPage([FromQuery] ServiceLivingMeterRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;

                var rs = await _feeServiceService.GetServiceLivingMeterPage(query);
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
        /// GetServiceLivingMeterInfo - lấy chi tiết chỉ số công tơ diện nước
        /// </summary>
        /// <param name="LivingId"> id dịch vụ </param>
        /// <param name="TrackingId"> id công tơ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingMeterInfo>> GetServiceLivingMeterElectricWaterInfo(int LivingId, int TrackingId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceLivingMeterInfo(LivingId, TrackingId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceLivingMeterInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceLivingMeterInfo - sửa chỉ số công tơ diện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricWaterInfo([FromBody] ServiceLivingMeterInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceLivingMeterInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// DeleteServiceLivingMeter - Xóa chỉ số công tơ điện nước
        /// </summary>
        /// <param name="trackingId">id công tơ</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteServiceLivingElectricWaterMeter([FromQuery] int trackingId)
        {
            try
            {
                var rs = await _feeServiceService.DeleteServiceLivingMeter(trackingId);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }
        /// <summary>
        /// SetServiceLivingMeterCalculates - tính chỉ số công tơ điện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricCalculate([FromQuery] int trackingId, [FromQuery] string projectCd, [FromQuery] int LivingType, [FromQuery] int PeriodMonth, [FromQuery] int PeriodYear)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceLivingMeterCalculates(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// SetServiceLivingMeterCalculates2 - tính chỉ số công tơ điện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricCalculateAll([FromBody] ServiceLivingMeterCalculatorInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceLivingMeterCalculates2(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }

        /// <summary>
        /// SetServiceLivingMeterCalculates - tính chỉ số công tơ điện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterWaterCalculate([FromQuery] int trackingId, [FromQuery] string projectCd, [FromQuery] int LivingType, [FromQuery] int PeriodMonth, [FromQuery] int PeriodYear)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceLivingMeterCalculates(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// SetServiceLivingMeterCalculates2 - tính chỉ số công tơ điện nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterWaterCalculateAll([FromBody] ServiceLivingMeterCalculatorInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceLivingMeterCalculates3(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// GetServiceLivingMeterCalculatorInfo - lấy chi tiết form tính chỉ số công tơ điện nước
        /// </summary>
        /// <param name="TrackingId"> id công tơ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingMeterCalculatorInfo>> GetServiceLivingMeterElectricWaterCalculatorInfo(int TrackingId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceLivingMeterCalculatorInfo(TrackingId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceLivingMeterCalculatorInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }


        /// <summary>
        /// DelMultiServiceLivingMeter - chọn xóa nhiều chỉ số công tơ điện nước
        /// </summary>
        /// <param name="deleteMultiService"> Loại dịch vụ(id = 1 là điện. id = 2 là nước) </param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelMultiServiceLivingElectricWaterMeter([FromBody] DeleteMultiServiceLivingMeter deleteMultiService)
        {
            try
            {
                var rs = await _feeServiceService.DelMultiServiceLivingMeter(deleteMultiService);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }

        #endregion LivingMeterElectricWater


        /// <summary>
        /// GetServiceExpectedFilter - Bộ lọc dự thu
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetServiceExpectedFilter()
        {
            var result = _feeServiceService.GetServiceExpectedFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetServiceExpectedPage - Lấy danh sách dự thu dịch vụ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceExpectedPage([FromQuery] ServiceExpectedRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExpectedPage(query);
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
        /// GetServiceExpectedCalculatorInfo - lấy chi tiết form tính dự thu
        /// </summary>
        /// <param name="ApartmentId"> id căn hộ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedCalculatorInfo>> GetServiceExpectedCalculatorInfo(int? ApartmentId)
        {
            try
            {
                var projectCd = Request.Headers["projectcode"].ToString();
                var rs = await _feeServiceService.GetServiceExpectedCalculatorInfo(ApartmentId, projectCd);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceExpectedCalculatorInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceExpectedCalculatorInfo - tính dự thu
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceExpectedCalculatorInfo([FromBody] ServiceExpectedCalculatorInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceExpectedCalculatorInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// GetServiceExpectedDetailsInfo - lấy chi tiết dự thu
        /// </summary>
        /// <param name="receiveId"> id căn hộ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedDetailsInfo>> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExpectedDetailsInfo(receiveId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceExpectedDetailsInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetServiceExpectedFeePage - Lấy danh sách dự thu phí dịch vụ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceExpectedFeePage([FromQuery] ServiceExpectedFeeRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExpectedFeePage(query);
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
        /// GetServiceExpectedVehiclePage - Lấy danh sách dự thu gửi xe
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceExpectedVehiclePage([FromQuery] ServiceExpectedVehicleRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExpectedVehiclePage(query);
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
        /// GetServiceExpectedLivingPage - Danh sách dự thu điện/nước
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedLivingPage>> GetServiceExpectedLivingPage([FromQuery] ServiceExpectedLivingRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;

                var rs = await _feeServiceService.GetServiceExpectedLivingPage(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceExpectedLivingPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetServiceExpectedExtendPage - Lấy danh sách dự thu dịch vụ mở rộng
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceExpectedExtendPage([FromQuery] ServiceExpectedExtendRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExpectedExtendPage(query);
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
        /// DeleteServiceExpected - Xóa dự thu
        /// </summary>
        /// <param name="receivableId">id dịch vụ dự thu</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteServiceExpected([FromQuery] int receivableId)
        {
            try
            {
                var rs = await _feeServiceService.DeleteServiceExpected(receivableId);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }
        /// <summary>
        /// GetServiceExpectedReceivableExtendInfo - lấy form thêm phí dịch vụ khác 
        /// </summary>
        /// <param name="receiveId"> id dự thu</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedReceivableExtendInfo>> GetServiceExpectedReceivableExtendInfo(int receiveId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceExpectedReceivableExtendInfo(receiveId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceExpectedReceivableExtendInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceExpectedReceivableExtendInfo - thêm phí dịch vụ khác 
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceExpectedReceivableExtendInfo([FromBody] ServiceExpectedReceivableExtendInfo info)
        {
            try
            {
                var rs = await _feeServiceService.SetServiceExpectedReceivableExtendInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// GetServiceReceivableFilter - Bộ lọc ds hóa đơn
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetServiceReceivableFilter()
        {
            var result = _feeServiceService.GetServiceReceivableFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetServiceReceivablePage - Lấy danh sách hóa đơn dịch vụ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceReceivablePage([FromQuery] ServiceReceivableRequestModel query)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceReceivablePage(query);
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
        /// GetServiceReceivableInfo - Lấy chi tiết hóa đơn
        /// </summary>
        /// <param name="receiveId"> id dự thu</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceReceivableInfo>> GetServiceReceivableInfo(int? receiveId)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceReceivableInfo(receiveId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ServiceReceivableInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetServiceBill - Tạo hóa đơn
        /// </summary>
        /// <param name="bill"> Thông tin hóa đơn</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceBill([FromBody] ServiceReceivableBill bill)
        {
            bill.RunNewVersion = true;
            var result = bill.RunNewVersion
                ? await _feeServiceService.SetServiceReceivableBillNew(bill)
                : await _feeServiceService.SetServiceReceivableBill(bill);

            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// SetServiceBillNew - Tạo hóa đơn
        /// </summary>
        /// <param name="bill"> Thông tin hóa đơn</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceBillNew([FromBody] ServiceReceivableBill bill)
        {
            var result = await _feeServiceService.SetServiceReceivableBillNew(bill);
            return GetResponse(ApiResult.Success, result);
        }


        #region import-reg
        /// <summary>
        /// GetEmpWorkingImportTemp - Lấy danh sách template
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetLivingImportTemp([FromQuery] int livingTypeId)
        {
            try
            {
                var rs = await _feeServiceService.GetLivingImportTemp(livingTypeId);
                return File(rs.Data, "application/octet-stream", "import_living.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }
        /// <summary>
        /// SetLivingElectricImport - Kiểm tra file import chỉ số điện
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetLivingElectricImport(IFormFile file)
        {
            var result = new BaseResponse<ImportListPage>();
            if (file == null || file.Length <= 0)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");
            }

            if (!Path.GetExtension(file.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx");
            }

            try
            {
                var organizes = new LivingImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    organizes.imports = FlexcellUtils.ReadToObject<LivingImportItem>(fs.ToArray(), 1);
                    organizes.livingTypeId = 1;
                }
                organizes.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _feeServiceService.SetLivingImport(organizes, false);
                var sCode = rs.valid != false ? ApiResult.Success : ApiResult.Error;
                //return GetResponse(sCode, rs,rs.messages);
                if (rs.valid)
                {
                    return GetResponse(ApiResult.Success, rs);
                }
                else
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return result;
            }
        }
        /// <summary>
        /// SetLivingWaterImport - Kiểm tra file import chỉ số nước
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetLivingWaterImport(IFormFile file)
        {
            var result = new BaseResponse<ImportListPage>();
            if (file == null || file.Length <= 0)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");
            }

            if (!Path.GetExtension(file.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx");
            }

            try
            {
                var organizes = new LivingImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    organizes.imports = FlexcellUtils.ReadToObject<LivingImportItem>(fs.ToArray(), 1);
                    organizes.livingTypeId = 2;
                }
                organizes.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _feeServiceService.SetLivingImport(organizes, false);
                //var sCode = rs.valid != false ? ApiResult.Success : ApiResult.Error;
                //return GetResponse(sCode, rs,rs.messages);
                if (rs.valid)
                {
                    return GetResponse(ApiResult.Success, rs);
                }
                else
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return result;
            }
        }
        /// <summary>
        /// SetEmpWorkingAccept - Kiểm tra or chấp nhận import
        /// </summary>
        /// <param name="importSet"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetLivingAccept([FromBody] LivingImportSet importSet)
        {
            try
            {
                var rs = await _feeServiceService.SetLivingImport(importSet, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }
        /// <summary>
        /// GetLivingImportPageAsync - Lấy danh sách import dịch vụ điện nước
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="gridWidth"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetLivingImportPageAsync(
            //[FromQuery] Guid? reportTo = null,
            [FromQuery] string filter = "",
            [FromQuery] int? offSet = 0,
            [FromQuery] int? pageSize = 10,
            [FromQuery] int? gridWidth = 0
            )
        {
            var flt = new FilterBase(ClientId, UserId, offSet, pageSize, filter, gridWidth);
            var result = await _importManagerService.GetImportPageAsync(flt, "living_import");
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// DelEmployeeImport
        /// </summary>
        /// <param name="impId"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelLivingImport([FromQuery] Guid impId)
        {
            var result = await _importManagerService.DelImport(impId);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        /// <summary>
        /// GetDebitAmtImportTemp - Lấy template import nợ tồn cũ
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetDebitAmtImportTemp()
        {
            try
            {
                var rs = await _feeServiceService.GetDebitAmtImportTemp();
                return File(rs.Data, "application/octet-stream", "mau_ton_no_cu_import.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }

        /// <summary>
        /// SetLivingElectricImport - Kiểm tra file import
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetDebitAmtImport(IFormFile file)
        {
            var result = new BaseResponse<ImportListPage>();
            if (file == null || file.Length <= 0)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");
            }

            if (!Path.GetExtension(file.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx");
            }

            try
            {
                var debitAmtImport = new DebitAmtImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    debitAmtImport.imports = FlexcellUtils.ReadToObject<DebitAmtImportItem>(fs.ToArray(), 1);
                }
                debitAmtImport.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _feeServiceService.SetDebitAmtImport(debitAmtImport, false);
                var sCode = rs.valid != false ? ApiResult.Success : ApiResult.Error;
                //return GetResponse(sCode, rs,rs.messages);
                if (rs.valid)
                {
                    return GetResponse(ApiResult.Success, rs);
                }
                else
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return result;
            }
        }

        /// <summary>
        /// SetVehicleNumImportAccept - Kiểm tra or chấp nhận import
        /// </summary>
        /// <param name="debitAmtImport"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetDebitAmtImportAccept([FromBody] DebitAmtImportSet debitAmtImport)
        {
            try
            {
                var rs = await _feeServiceService.SetDebitAmtImport(debitAmtImport, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// GetPaymentImportTemp - Lấy template import lịch sử thanh toán
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetPaymentImportTemp()
        {
            try
            {
                var rs = await _feeServiceService.GetPaymentImportTemp();
                return File(rs.Data, "application/octet-stream", "payment_import_template.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }

        /// <summary>
        /// SetPaymentImport - Kiểm tra file import lịch sử thanh toán
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetPaymentImport(IFormFile file)
        {
            var result = new BaseResponse<ImportListPage>();
            if (file == null || file.Length <= 0)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");
            }

            if (!Path.GetExtension(file.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx");
            }

            try
            {
                var paymentImport = new PaymentImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    paymentImport.imports = FlexcellUtils.ReadToObject<PaymentImportItem>(fs.ToArray(), 1);
                }
                paymentImport.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _feeServiceService.SetPaymentImport(paymentImport, false);
                if (rs.valid)
                {
                    return GetResponse(ApiResult.Success, rs);
                }
                else
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return result;
            }
        }

        /// <summary>
        /// SetPaymentImportAccept - Chấp nhận file import lịch sử thanh toán
        /// </summary>
        /// <param name="paymentImport"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetPaymentImportAccept([FromBody] PaymentImportSet paymentImport)
        {
            try
            {
                var rs = await _feeServiceService.SetPaymentImport(paymentImport, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// GetDebitAmtImportTemp - Lấy template import tổng tiền trên hóa đơn
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetTotalAmtImportTemp()
        {
            try
            {
                var rs = await _feeServiceService.GetTotalAmtImportTemp();
                return File(rs.Data, "application/octet-stream", "mau_ton_no_cu_import.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }

        /// <summary>
        /// SetTotalAmtImport - Kiểm tra file import
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetTotalAmtImport(IFormFile file)
        {
            var result = new BaseResponse<ImportListPage>();
            if (file == null || file.Length <= 0)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");
            }

            if (!Path.GetExtension(file.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx");
            }

            try
            {
                var totalAmtImport = new TotalAmtImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    totalAmtImport.imports = FlexcellUtils.ReadToObject<TotalAmtImportItem>(fs.ToArray(), 1);
                }
                totalAmtImport.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _feeServiceService.SetTotalAmtImport(totalAmtImport, false);
                var sCode = rs.valid != false ? ApiResult.Success : ApiResult.Error;
                //return GetResponse(sCode, rs,rs.messages);
                if (rs.valid)
                {
                    return GetResponse(ApiResult.Success, rs);
                }
                else
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return result;
            }
        }

        /// <summary>
        /// SetVehicleNumImportAccept - Kiểm tra or chấp nhận import
        /// </summary>
        /// <param name="totalAmtImport"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetTotalAmtImportAccept([FromBody] TotalAmtImportSet totalAmtImport)
        {
            try
            {
                var rs = await _feeServiceService.SetTotalAmtImport(totalAmtImport, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        #endregion import-reg



        #region setting price

        /// <summary>
        /// GetServiceLivingPricePage - Lấy danh sách cài đặt giá dịch vụ điện nước
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceLivingPricePage([FromQuery] FilterProjectliving flt)
        {
            try
            {
                var rs = await _feeServiceService.GetServiceLivingPricePage(flt);
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



        #endregion setting price
    }
}

using AutoMapper;
using DocumentFormat.OpenXml.Office2010.ExcelAc;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.BLL.HelperService;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Utils;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.BLL.BusinessService.Invoice;
using UNI.Resident.BLL.BusinessInterfaces.Settings;

namespace UNI.Resident.API.Controllers.Version2.ServiceFee
{
    [Route("api/v2/FeeElectricWater/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class FeeElectricWaterController : UniController
    {

        #region instance-reg
        private readonly IMapper _mapper;
        private readonly IServiceLivingMeterElectricWaterService _feeElectricWater;
        private readonly IMetaImportService _importManagerService;

        /// <summary>
        /// Initializes a new instance of the <see cref="FeeElectricWaterController"/> class.
        /// </summary>
        /// <param name="feeElectricWater"></param>
        /// <param name="appSettings"></param>
        /// <param name="importManagerService"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public FeeElectricWaterController(
            IServiceLivingMeterElectricWaterService feeElectricWater,
            IOptions<AppSettings> appSettings,
            IMetaImportService importManagerService,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _feeElectricWater = feeElectricWater;
            _mapper = mapper;
            _importManagerService = importManagerService;
        }
        #endregion instance-reg

        #region electric-water  
        /// <summary>
        /// GetServiceLivingMeterElectricWaterFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetServiceLivingMeterElectricWaterFilter()
        {
            var result = _feeElectricWater.GetServiceLivingMeterElectricWaterFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetServiceLivingMeterElectricWaterPage - Lấy danh sách chỉ số công tơ điện - nước
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

                var rs = await _feeElectricWater.GetServiceLivingMeterElectricWaterPage(query);
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
        /// GetServiceLivingMeterElectricWaterInfo - lấy chi tiết chỉ số công tơ điện - nước
        /// </summary>
        /// <param name="LivingId"> id dịch vụ </param>
        /// <param name="TrackingId"> id công tơ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingMeterInfo>> GetServiceLivingMeterElectricWaterInfo(int LivingId, int TrackingId)
        {
            try
            {
                var rs = await _feeElectricWater.GetServiceLivingMeterElectricWaterInfo(LivingId, TrackingId);
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
        /// SetServiceLivingMeterElectricWaterInfo - sửa chỉ số công tơ điện - nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricWaterInfo([FromBody] ServiceLivingMeterInfo info)
        {
            try
            {
                var rs = await _feeElectricWater.SetServiceLivingMeterElectricWaterInfo(info);
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
        /// DeleteServiceLivingElectricWaterMeter - Xóa chỉ số công tơ điện - nước
        /// </summary>
        /// <param name="trackingId">id công tơ</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteServiceLivingElectricWaterMeter([FromQuery] int trackingId)
        {
            try
            {
                var rs = await _feeElectricWater.DeleteServiceLivingElectricWaterMeter(trackingId);
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
        /// SetServiceLivingMeterElectricCalculate - tính chỉ số công tơ điện của 1 bản ghi
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricCalculate([FromQuery] int trackingId, [FromQuery] string projectCd, [FromQuery] int LivingType, [FromQuery] int PeriodMonth, [FromQuery] int PeriodYear)
        {
            try
            {
                var rs = await _feeElectricWater.SetServiceLivingMeterElectricCalculate(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
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
        /// SetServiceLivingMeterElectricCalculateAll - tính tất cả chỉ số công tơ điện
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricCalculateAll([FromBody] ServiceLivingMeterCalculatorInfo info)
        {
            try
            {
                var rs = await _feeElectricWater.SetServiceLivingMeterElectricCalculateAll(info);
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
        /// SetServiceLivingMeterWaterCalculate - tính chỉ số công tơ nước của 1 bản ghi
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterWaterCalculate([FromQuery] int trackingId, [FromQuery] string projectCd, [FromQuery] int LivingType, [FromQuery] int PeriodMonth, [FromQuery] int PeriodYear)
        {
            try
            {
                var rs = await _feeElectricWater.SetServiceLivingMeterWaterCalculate(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
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
        /// SetServiceLivingMeterWaterCalculateAll - tính tất cả chỉ số công tơ nước
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterWaterCalculateAll([FromBody] ServiceLivingMeterCalculatorInfo info)
        {
            try
            {
                var rs = await _feeElectricWater.SetServiceLivingMeterWaterCalculateAll(info);
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
        /// GetServiceLivingMeterElectricWaterCalculatorInfo - lấy chi tiết form tính chỉ số công tơ điện
        /// </summary>
        /// <param name="TrackingId"> id công tơ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingMeterCalculatorInfo>> GetServiceLivingMeterElectricWaterCalculatorInfo(int TrackingId)
        {
            try
            {
                var rs = await _feeElectricWater.GetServiceLivingMeterElectricWaterCalculatorInfo(TrackingId);
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
        /// DelMultiServiceLivingElectricWaterMeter - chọn xóa nhiều chỉ số công tơ điện nước
        /// </summary>
        /// <param name="deleteMultiService"> Loại dịch vụ(id = 1 là điện. id = 2 là nước) </param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelMultiServiceLivingElectricWaterMeter([FromBody] DeleteMultiServiceLivingMeter deleteMultiService)
        {
            try
            {
                var rs = await _feeElectricWater.DelMultiServiceLivingElectricWaterMeter(deleteMultiService);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        #endregion electric-water

        #region expected
        /// <summary>
        /// GetServiceExpectedFilter - Bộ lọc dự thu
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetServiceExpectedFilter()
        {
            var result = _feeElectricWater.GetServiceExpectedFilter(UserId);
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
                var rs = await _feeElectricWater.GetServiceExpectedPage(query);
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
                var rs = await _feeElectricWater.GetServiceExpectedCalculatorInfo(ApartmentId, projectCd);
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
                var rs = await _feeElectricWater.SetServiceExpectedCalculatorInfo(info);
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
                var rs = await _feeElectricWater.GetServiceExpectedDetailsInfo(receiveId);
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
                var rs = await _feeElectricWater.GetServiceExpectedFeePage(query);
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
                var rs = await _feeElectricWater.GetServiceExpectedVehiclePage(query);
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

                var rs = await _feeElectricWater.GetServiceExpectedLivingPage(query);
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
                var rs = await _feeElectricWater.GetServiceExpectedExtendPage(query);
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
        /// Thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<viewBaseInfo>> GetServiceExpectedExtendFields([FromQuery] int receiveId)
        {
            try
            {
                var result = await _feeElectricWater.GetServiceExpectedExtendFields(receiveId);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new viewBaseInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetServiceExpectedExtendFields([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _feeElectricWater.SetServiceExpectedExtendFields(inputData);
                return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
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
                var rs = await _feeElectricWater.DeleteServiceExpected(receivableId);
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
                var rs = await _feeElectricWater.GetServiceExpectedReceivableExtendInfo(receiveId);
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
        /// GetServiceExpectedDebtPage - Lấy danh sách dự thu công nợ tồn 
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceExpectedDebtPage([FromQuery] ServiceExpectedExtendRequestModel query)
        {
            try
            {
                var rs = await _feeElectricWater.GetServiceExpectedDebtPage(query);
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
        #endregion
    }
}

using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Billing
{
    /// <summary>
    /// Kỳ thanh toán - Dự thu
    /// </summary>
    [Route("api/v2/BillingEstimates/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class BillingEstimatesController : UniController
    {
        private readonly IBillingEstimatesService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public BillingEstimatesController(IBillingEstimatesService service,
            IOptions<AppSettings> appSettings, ILoggerFactory logger) : base(appSettings, logger)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBillingEstimatesFilter()
        {
            try
            {
                var result = await _service.GetBillingEstimatesFilter();
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonViewInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBillingEstimatesPage([FromQuery] ServiceExpectedRequestModel query)
        {
            try
            {
                var result = await _service.GetBillingEstimatesPage(query);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonDataPage(), ex.Message);
            }
        }

        /// <summary>
        /// Thông tin thêm/sửa bản ghi
        /// </summary>
        /// <param name="periodsOid"></param>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<viewBaseInfo>> GetBillingEstimatesFields([FromQuery] Guid periodsOid, [FromQuery] int? receiveId)
        {
            try
            {
                var result = await _service.GetBillingEstimatesFields(receiveId);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new viewBaseInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingEstimates([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetBillingEstimates(inputData);
                return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Xóa một bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<BaseValidate>> SetBillingEstimatesDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetBillingEstimatesDelete(new List<Guid> { oid });
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Xóa nhiều bản ghi
        /// </summary>
        /// <param name="arrOid"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingEstimatesDeletes([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetBillingEstimatesDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// lấy chi tiết form tính dự thu
        /// </summary>
        /// <param name="periodsOid"> id kỳ thanh toán</param>
        /// <param name="apartmentId"> id căn hộ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedCalculatorInfo>> GetBillingEstimatesCalculatorFields(Guid periodsOid, int? apartmentId)
        {
            try
            {
                var rs = await _service.GetBillingEstimatesCalculatorFields(periodsOid, apartmentId);
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
        /// Tính dự thu nháp
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBillingEstimatesCalculatorFieldsDraft([FromBody] ServiceExpectedCalculatorInfo info)
        {
            try
            {
                var rs = await _service.SetBillingEstimatesCalculatorFields(info);
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
        /// tính dự thu
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBillingEstimatesCalculatorFields([FromBody] ServiceExpectedCalculatorInfo info)
        {
            try
            {
                var rs = await _service.SetBillingEstimatesCalculatorFields(info);
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
        /// Lấy danh sách dự thu phí dịch vụ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBillingEstimatesExpectedFeePage([FromQuery] ServiceExpectedFeeRequestModel query)
        {
            try
            {
                var rs = await _service.GetBillingEstimatesExpectedFeePage(query);
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
        /// Danh sách dự thu điện/nước
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedLivingPage>> GetBillingEstimatesExpectedLivingPage([FromQuery] ServiceExpectedLivingRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;

                var rs = await _service.GetBillingEstimatesExpectedLivingPage(query);
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
        /// Lấy danh sách dự thu gửi xe
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBillingEstimatesExpectedVehiclePage([FromQuery] ServiceExpectedVehicleRequestModel query)
        {
            try
            {
                var rs = await _service.GetBillingEstimatesExpectedVehiclePage(query);
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
        /// Lấy danh sách dự thu dịch vụ mở rộng
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBillingEstimatesExpectedExtendPage([FromQuery] ServiceExpectedExtendRequestModel query)
        {
            try
            {
                var rs = await _service.GetBillingEstimatesExpectedExtendPage(query);
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
        public async Task<BaseResponse<viewBaseInfo>> GetBillingEstimatesExpectedExtendFields([FromQuery] int receiveId)
        {
            try
            {
                var result = await _service.GetBillingEstimatesExpectedExtendFields(receiveId);
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
        public async Task<BaseResponse<BaseValidate>> SetBillingEstimatesExpectedExtendFields([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetBillingEstimatesExpectedExtendFields(inputData);
                return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Lấy danh sách dự thu công nợ tồn 
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBillingEstimatesExpectedDebtPage([FromQuery] ServiceExpectedExtendRequestModel query)
        {
            try
            {
                var rs = await _service.GetBillingEstimatesExpectedDebtPage(query);
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
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
    /// Dự thu các căn hộ trước khi xuất hóa đơn
    /// </summary>
    [Route("api/v2/RevenuePeriodsDetail/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class RevenuePeriodsDetailController : UniController
    {
        private readonly IRevenuePeriodsDetailService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public RevenuePeriodsDetailController(IRevenuePeriodsDetailService service,
            IOptions<AppSettings> appSettings, ILoggerFactory logger) : base(appSettings, logger)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetServiceReceivableFilter()
        {
            try
            {
                var result = await _service.GetServiceReceivableFilter();
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
        /// <param name="inputFilter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServiceReceivablePage([FromQuery] ServiceExpectedRequestModel inputFilter)
        {
            try
            {
                var result = await _service.GetServiceReceivablePage(inputFilter);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonDataPage(), ex.Message);
            }
        }

        /// <summary>
        /// Lấy chi tiết dự thu
        /// </summary>
        /// <param name="receiveId"> id căn hộ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedDetailsInfo>> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            try
            {
                var rs = await _service.GetServiceExpectedDetailsInfo(receiveId);
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
        /// Form tính dự thu
        /// </summary>
        /// <param name="revenuePeriodId">id kỳ dự thu</param>
        /// <param name="apartmentId">id căn hộ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceExpectedCalculatorInfo>> GetServiceExpectedCalculatorInfo(Guid revenuePeriodId, int? apartmentId)
        {
            try
            {
                var rs = await _service.GetServiceExpectedCalculatorInfo(apartmentId, revenuePeriodId);
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
        /// Form tính dự thu - Nháp
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ServiceExpectedCalculatorInfo>> SetServiceExpectedCalculatorInfoDraft([FromBody] ServiceExpectedCalculatorInfo info)
        {
            try
            {
                var rs = await _service.GetServiceExpectedCalculatorInfo(null, null, info);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, new ServiceExpectedCalculatorInfo(), e.Message);
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
                var rs = await _service.SetServiceExpectedCalculatorInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
    }
}
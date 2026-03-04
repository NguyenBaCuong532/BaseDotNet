using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.VehiclePayment;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.CardVehicle
{
    /// <summary>
    /// Vehicle Payment Controller
    /// </summary>
    /// Author: System
    /// <seealso cref="UniController" />
    [Route("api/v2/vehicle-payment/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class VehiclePaymentController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The vehicle payment service
        /// </summary>
        private readonly IVehiclePaymentService _vehiclePaymentService;

        /// <summary>
        /// Initializes a new instance of the <see cref="VehiclePaymentController"/> class.
        /// </summary>
        /// <param name="vehiclePaymentService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public VehiclePaymentController(
            IVehiclePaymentService vehiclePaymentService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _vehiclePaymentService = vehiclePaymentService;
        }
        #endregion

        #region Vehicle Payment Management

        /// <summary>
        /// Lấy danh sách thanh toán xe theo trang
        /// </summary>
        /// <param name="query">Tham số tìm kiếm và phân trang</param>
        /// <returns>Danh sách thanh toán xe đã phân trang</returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetPage([FromQuery] VehiclePaymentRequestModel query)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<CommonDataPage>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                var result = await _vehiclePaymentService.GetPageAsync(query);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy danh sách thanh toán xe");
                return GetErrorResponse<CommonDataPage>(ApiResult.Error, 500 , ex.Message);
            }
        }

        /// <summary>
        /// Lấy thông tin chi tiết thanh toán xe
        /// </summary>
        /// <param name="paymentId">ID thanh toán</param>
        /// <param name="cardVehicleId">ID thẻ xe. Bỏ qua nếu truyền cardVehicleOid.</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns>Thông tin thanh toán xe</returns>
        [HttpGet]
        public async Task<BaseResponse<VehiclePaymentInfo>> GetInfo([FromQuery] Guid? paymentId, [FromQuery] int? cardVehicleId = null, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                if (paymentId == null && cardVehicleId == null && cardVehicleOid == null)
                {
                    return GetErrorResponse<VehiclePaymentInfo>(ApiResult.Error, 500 , "Cần cung cấp PaymentId, CardVehicleId hoặc cardVehicleOid"); 
                }

                var result = await _vehiclePaymentService.GetInfoAsync(paymentId, cardVehicleId, cardVehicleOid);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi lấy thông tin thanh toán xe với PaymentId: {PaymentId}, CardVehicleId: {CardVehicleId}", paymentId, cardVehicleId);
                return GetErrorResponse<VehiclePaymentInfo>(ApiResult.Error, 500 , ex.Message);
            }
        }

        /// <summary>
        /// Tạo bản nháp thanh toán xe
        /// </summary>
        /// <param name="draft">Thông tin bản nháp</param>
        /// <returns>Kết quả tạo bản nháp</returns>
        [HttpPost]
        public async Task<BaseResponse<VehiclePaymentInfo>> SetDraft([FromBody] VehiclePaymentInfo draft)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<VehiclePaymentInfo>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }

                var result = await _vehiclePaymentService.SetDraftAsync(draft);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi tạo bản nháp thanh toán xe");
                return GetErrorResponse<VehiclePaymentInfo>(ApiResult.Error, 500 , ex.Message);
            }
        }

        /// <summary>
        /// Cập nhật thông tin thanh toán xe
        /// </summary>
        /// <param name="info">Thông tin thanh toán</param>
        /// <returns>Kết quả cập nhật</returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetInfo([FromBody] VehiclePaymentInfo info)
        {
            try
            {
                
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }

                var result = await _vehiclePaymentService.SetInfoAsync(info);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi cập nhật thông tin thanh toán xe");
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 500 , ex.Message);
            }
        }

        /// <summary>
        /// Xóa thanh toán xe
        /// </summary>
        /// <param name="paymentId">ID thanh toán</param>
        /// <returns>Kết quả xóa</returns>
        [HttpDelete]
        public async Task<BaseResponse<BaseValidate>> Delete([FromQuery] Guid paymentId)
        {
            try
            {
                var result = await _vehiclePaymentService.DeleteAsync(paymentId);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xóa thanh toán xe với ID: {PaymentId}", paymentId);
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 500 , ex.Message);
            }
        }

        /// <summary>
        /// Duyệt thanh toán xe
        /// </summary>
        /// <param name="approve">Thông tin duyệt</param>
        /// <returns>Kết quả duyệt</returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetApprove([FromBody] VehiclePaymentApproveModel approve)
        {
            try
            {

                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }

                var result = await _vehiclePaymentService.SetApproveAsync(approve);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi duyệt thanh toán xe");
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 500 , ex.Message);
            }
        }

        #endregion
    }
}

using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Billing
{
    /// <summary>
    /// Kỳ thanh toán nước
    /// </summary>
    [Route("api/v2/BillingPeriodsWater/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class BillingPeriodsWaterController : UniController
    {
        private readonly IBillingPeriodsWaterService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public BillingPeriodsWaterController(IBillingPeriodsWaterService service,
            IOptions<AppSettings> appSettings, ILoggerFactory logger) : base(appSettings, logger)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBillingPeriodsWaterFilter()
        {
            try
            {
                var result = await _service.GetBillingPeriodsWaterFilter();
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
        public async Task<BaseResponse<CommonDataPage>> GetBillingPeriodsWaterPage([FromQuery] ServiceLivingMeterRequestModel inputFilter)
        {
            try
            {
                var result = await _service.GetBillingPeriodsWaterPage(inputFilter);
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
        /// <param name="livingId"></param>
        /// <param name="trackingId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingMeterInfo>> GetBillingPeriodsWaterFields(Guid periodsOid, int livingId, int trackingId)
        {
            try
            {
                var result = await _service.GetBillingPeriodsWaterFields(periodsOid, livingId, trackingId);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new ServiceLivingMeterInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu nháp
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ServiceLivingMeterInfo>> SetBillingPeriodsWaterDraft([FromBody] ServiceLivingMeterInfo info)
        {
            try
            {
                var result = await _service.GetBillingPeriodsWaterFields(Guid.Empty, 0, 0, info);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new ServiceLivingMeterInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingPeriodsWater([FromBody] ServiceLivingMeterInfo inputData)
        {
            try
            {
                var result = await _service.SetBillingPeriodsWater(inputData);
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
        /// <param name="trackingId"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<BaseValidate>> SetBillingPeriodsWaterDelete([FromQuery] int trackingId)
        {
            try
            {
                var inputParam = new DeleteMultiServiceLivingMeter
                {
                    Ids = new List<int?> { trackingId }
                };
                var data = await _service.SetBillingPeriodsWaterDelete(inputParam);
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
        /// <param name="inputParam"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingPeriodsWaterDeletes([FromBody] DeleteMultiServiceLivingMeter inputParam)
        {
            try
            {
                var data = await _service.SetBillingPeriodsWaterDelete(inputParam);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// File mẫu import chỉ số nước
        /// </summary>
        /// <param name="livingTypeId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetBillingPeriodsWaterImportTemp([FromQuery] int livingTypeId)
        {
            try
            {
                var rs = await _service.GetBillingPeriodsWaterImportTemp(livingTypeId);
                return File(rs.Data, "application/octet-stream", "import_living.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }

        /// <summary>
        /// Thực hiện import chỉ số nước
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetBillingPeriodsWaterImport(IFormFile file)
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
                var rs = await _service.SetBillingPeriodsWaterImport(organizes, false);
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
        /// Kiểm tra và xác nhận thực hiện import
        /// </summary>
        /// <param name="importSet"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetBillingPeriodsWaterImportAccept([FromBody] LivingImportSet importSet)
        {
            try
            {
                var rs = await _service.SetBillingPeriodsWaterImport(importSet, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// Tính toán tiền nước từng căn hộ
        /// </summary>
        /// <param name="trackingId"></param>
        /// <param name="projectCd"></param>
        /// <param name="livingType"></param>
        /// <param name="periodMonth"></param>
        /// <param name="periodYear"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBillingPeriodsWaterCalculate([FromQuery] int trackingId, [FromQuery] string projectCd, [FromQuery] int livingType, [FromQuery] int periodMonth, [FromQuery] int periodYear)
        {
            try
            {
                var rs = await _service.SetBillingPeriodsWaterCalculate(trackingId, projectCd, livingType, periodMonth, periodYear);
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
        /// Tính toán tiền nước các căn hộ theo tham số
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBillingPeriodsWaterCalculateAll([FromBody] ServiceLivingMeterCalculatorInfo info)
        {
            try
            {
                var rs = await _service.SetBillingPeriodsWaterCalculateAll(info);
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
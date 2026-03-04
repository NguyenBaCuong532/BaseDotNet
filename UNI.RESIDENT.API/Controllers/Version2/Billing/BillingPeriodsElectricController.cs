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
using UNI.Resident.Model.Billing;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Billing
{
    /// <summary>
    /// Kỳ thanh toán điện
    /// </summary>
    [Route("api/v2/BillingPeriodsElectric/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class BillingPeriodsElectricController : UniController
    {
        private readonly IBillingPeriodsElectricService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public BillingPeriodsElectricController(IBillingPeriodsElectricService service,
            IOptions<AppSettings> appSettings, ILoggerFactory logger) : base(appSettings, logger)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBillingPeriodsElectricFilter()
        {
            try
            {
                var result = await _service.GetBillingPeriodsElectricFilter();
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
        public async Task<BaseResponse<CommonDataPage>> GetBillingPeriodsElectricPage([FromQuery] ServiceLivingMeterRequestModel inputFilter)
        {
            try
            {
                var result = await _service.GetBillingPeriodsElectricPage(inputFilter);
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
        public async Task<BaseResponse<viewBaseInfo>> GetBillingPeriodsElectricFields(
            [FromQuery] Guid periodsOid, [FromQuery] int livingId, [FromQuery] int trackingId)
        {
            try
            {
                var result = await _service.GetBillingPeriodsElectricFields(periodsOid, livingId, trackingId);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new viewBaseInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu nháp
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<viewBaseInfo>> SetBillingPeriodsElectricDraft([FromBody] ServiceLivingMeterInfo info)
        {
            try
            {
                var result = await _service.GetBillingPeriodsElectricFields(Guid.Empty, 0, 0, info);
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
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingPeriodsElectric([FromBody] ServiceLivingMeterInfo info)
        {
            try
            {
                var result = await _service.SetBillingPeriodsElectric(info);
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
        public async Task<BaseResponse<BaseValidate>> SetBillingPeriodsElectricDelete([FromQuery] int trackingId)
        {
            try
            {
                var inputParam = new DeleteMultiServiceLivingMeter
                {
                    Ids = new List<int?> { trackingId }
                };
                var data = await _service.SetBillingPeriodsElectricDelete(inputParam);
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
        public async Task<BaseResponse<BaseValidate>> SetBillingPeriodsElectricDeletes([FromBody] DeleteMultiServiceLivingMeter inputParam)
        {
            try
            {
                var data = await _service.SetBillingPeriodsElectricDelete(inputParam);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// File mẫu import chỉ số công tơ điện
        /// </summary>
        /// <param name="livingTypeId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetBillingPeriodsElectricImportTemp([FromQuery] int livingTypeId)
        {
            try
            {
                var rs = await _service.GetBillingPeriodsElectricImportTemp(livingTypeId);
                return File(rs.Data, "application/octet-stream", "import_living.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }

        /// <summary>
        /// Import chỉ số điện
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetBillingPeriodsElectricImport([FromForm] BillingPeriodsElectricImport inputData)
        {
            if (inputData.PeriodsOid == Guid.Empty)
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Không có thông tn kỳ thanh toán");

            if (inputData == null)
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Không nhận được thông tin dữ liệu");

            var result = new BaseResponse<ImportListPage>();
            if (inputData.File == null || inputData.File.Length <= 0)
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Chưa có tệp được chọn");

            if (!Path.GetExtension(inputData.File.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .xlsx");

            try
            {
                var organizes = new LivingImportSet();
                using (var fs = new MemoryStream())
                {
                    await inputData.File.CopyToAsync(fs);
                    organizes.imports = FlexcellUtils.ReadToObject<LivingImportItem>(fs.ToArray(), 1);
                    organizes.livingTypeId = 1;
                }
                organizes.importFile = new uImportFile
                {
                    fileName = inputData.File.FileName,
                    fileSize = inputData.File.Length,
                    fileType = Path.GetExtension(inputData.File.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(inputData.File.OpenReadStream(), inputData.File.FileName, app: "s_service")
                };

                organizes.PeriodsOid = inputData.PeriodsOid;
                var rs = await _service.SetBillingPeriodsElectricImport(organizes, false);
                var sCode = rs.valid != false ? ApiResult.Success : ApiResult.Error;
                if (rs.valid)
                    return GetResponse(ApiResult.Success, rs);
                else
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, rs.messages);
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
        /// Kiểm tra và xác nhận import
        /// </summary>
        /// <param name="importSet"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetBillingPeriodsElectricImportAccept([FromBody] LivingImportSet importSet)
        {
            try
            {
                var rs = await _service.SetBillingPeriodsElectricImport(importSet, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// Form thông tin tính toán tiền điện
        /// </summary>
        /// <param name="periodsOid"></param>
        /// <param name="trackingId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ServiceLivingMeterCalculatorInfo>> GetBillingPeriodsElectricCalculatorFields(Guid periodsOid, int trackingId)
        {
            try
            {
                var rs = await _service.GetBillingPeriodsElectricCalculatorFields(periodsOid, trackingId);
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
        /// Tính chỉ giá từng căn hộ
        /// </summary>
        /// <param name="trackingId"></param>
        /// <param name="projectCd"></param>
        /// <param name="LivingType"></param>
        /// <param name="periodMonth"></param>
        /// <param name="periodYear"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricCalculate([FromQuery] int trackingId, [FromQuery] string projectCd, [FromQuery] int LivingType, [FromQuery] int periodMonth, [FromQuery] int periodYear)
        {
            try
            {
                var rs = await _service.SetBillingPeriodsElectricCalculate(trackingId, projectCd, LivingType, periodMonth, periodYear);
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
        /// Tính chỉ giá các căn hộ theo bộ lọc
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetServiceLivingMeterElectricCalculateAll([FromBody] ServiceLivingMeterCalculatorInfo info)
        {
            try
            {
                var rs = await _service.SetBillingPeriodsElectricCalculateAll(info);
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
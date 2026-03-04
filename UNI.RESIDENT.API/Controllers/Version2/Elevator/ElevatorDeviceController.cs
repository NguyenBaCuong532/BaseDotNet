using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Elevator;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Elevator
{

    /// <summary>
    /// ElevatorController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/elevatordevice/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ElevatorDeviceController : UniController
    {

        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IElevatorDeviceService _homeService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ElevatorController"/> class.
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ElevatorDeviceController(IElevatorDeviceService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _homeService = homeService;
            _mapper = mapper;
        }

        /// <summary>
        /// GetElevatorDeviceFilter - Lấy dữ liệu filter cho thiết bị thang máy
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetElevatorDeviceFilter()
        {
            var result = await _homeService.GetElevatorDeviceFilter();
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get ElevatorDevice Page - Xem danh sách thiết bị thang máy
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd"></param>
        /// <param name="buildZone"></param>
        /// <param name="floorNumber"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetElevatorDevicePage(
            [FromQuery] string filter, 
            [FromQuery] int? offSet, [FromQuery] int? pageSize, 
            [FromQuery] string projectCd, [FromQuery] string buildingCd, 
            [FromQuery] string buildZone, [FromQuery] int floorNumber)
        {
            var flt = new FilterElevatorDevice(ClientId, UserId, offSet, pageSize, filter, projectCd, buildingCd, buildZone, floorNumber, "");
            var result = await _homeService.GetElevatorDevicePage(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Set GetElevatorDeviceInfo - Thêm/Sửa thiết bị thang máy
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetElevatorDeviceInfo([FromQuery] string id)
        {
            var result = await _homeService.GetElevatorDeviceInfo(id);
            return GetResponse<CommonViewInfo>(ApiResult.Success, result);
        }
        /// <summary>
        /// Set MasElevatorDevice - Thêm/Sửa thiết bị thang máy
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetElevatorDeviceInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetElevatorDeviceInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// Delete ElevatorDevice - Xóa thiết bị thang máy
        /// </summary>
        /// <param name="Oid"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelElevatorDevice([FromBody] string ids)
        {
            var result = await _homeService.DelElevatorDeviceInfo(ids);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// GetElevatorDeviceImportTemp 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetElevatorDeviceImportTemp()
        {
            var rs = await _homeService.GetElevatorDeviceImportTemp();
            return File(rs.Data, "application/octet-stream", "import_elevator_device.xlsx");
        }
        /// <summary>
        /// SetElevatorDeviceImport
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetElevatorDeviceImport(IFormFile file)
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
                var eleDevice = new ElevatorDeviceImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    var eleDevices = FlexcellUtils.ReadToObject<ElevatorDeviceImportItem>(fs.ToArray(), 4);
                    eleDevices.RemoveAll(
                        x => string.IsNullOrEmpty(x.ProjectCd)
                        && string.IsNullOrEmpty(x.BuildCd)
                        && string.IsNullOrEmpty(x.BuildZone));
                    eleDevice.imports = eleDevices;
                }
                eleDevice.importFile = new uImportFile
                {
                    impId = Guid.NewGuid(),
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _homeService.SetElevatorDeviceImport(eleDevice);
                return GetResponse(ApiResult.Success, rs);
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
        /// SetElevatorDeviceImportAccepted
        /// </summary>
        /// <param name="eleDevice"></param>
        /// <returns></returns>
        [HttpPost]
        [ProducesDefaultResponseType(typeof(BaseResponse<ImportListPage>))]
        public async Task<IActionResult> SetElevatorDeviceImportAccepted([FromBody] ElevatorDeviceImportSet eleDevice)
        {
            var result = new BaseResponse<ImportListPage>();
            try
            {
                eleDevice.accept = true;
                result.Data = await _homeService.SetElevatorDeviceImport(eleDevice);
                result.SetStatus(ApiResult.Success);
                return Ok(result);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                result.AddError(ApiResult.Error, e.Message);
                result.SetStatus(ApiResult.Error);
                return Ok(result);
            }
        }


        [HttpPost]
        public async Task<BaseResponse<CommonViewIdInfo>> SetElevatorDeviceDraft([FromBody] CommonViewIdInfo info)
        {
            var result = await _homeService.SetElevatorDeviceDraft(info);
            return GetResponse(ApiResult.Success, result);
        }



        // Danh mục thiết bị thang máy

        /// <summary>
        /// GetElevatorDeviceCategoryFilter - Lấy dữ liệu filter cho thiết bị thang máy
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetElevatorDeviceCategoryFilter()
        {
            var result = await _homeService.GetElevatorDeviceCategoryFilter();
            return GetResponse(ApiResult.Success, result);
        }


        /// <summary>
        /// GetElevatorDeviceCategoryPage - Xem danh sách danh mục thiết bị thang máy
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd"></param>
        /// <param name="buildZone"></param>
        /// <param name="floorNumber"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetElevatorDeviceCategoryPage(
            [FromQuery] string filter,
            [FromQuery] int? offSet, [FromQuery] int? pageSize,
            [FromQuery] string projectCd, [FromQuery] string buildingCd,
            [FromQuery] string buildZone, [FromQuery] int floorNumber
        )
        {
            var flt = new FilterElevatorDevice(ClientId, UserId, offSet, pageSize, filter, projectCd, buildingCd, buildZone, floorNumber, "");
            var result = await _homeService.GetElevatorDeviceCategoryPage(flt);
            return GetResponse(ApiResult.Success, result);
        }


        /// <summary>
        /// GetElevatorDeviceCategoryInfo - Thêm/Sửa danh mục thiết bị thang máy
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetElevatorDeviceCategoryInfo([FromQuery] string id)
        {
            var result = await _homeService.GetElevatorDeviceCategoryInfo(id);
            return GetResponse<CommonViewInfo>(ApiResult.Success, result);
        }


        /// <summary>
        /// SetElevatorDeviceCategoryInfo - Thêm/Sửa danh mục thiết bị thang máy
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetElevatorDeviceCategoryInfo([FromBody] CommonViewInfo info)
        {
            var result = await _homeService.SetElevatorDeviceCategoryInfo(info);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// DelElevatorDevice - Xóa danh mục thiết bị thang máy
        /// </summary>
        /// <param name="ids"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelElevatorDeviceCategoryInfo([FromBody] string ids)
        {
            var result = await _homeService.DelElevatorDeviceCategoryInfo(ids);
            return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, "", result.messages);
        }

        /// <summary>
        /// SetElevatorDeviceCategoryDraft: Draft danh mục thiết bị thang máy
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<CommonViewIdInfo>> SetElevatorDeviceCategoryDraft([FromBody] CommonViewIdInfo info)
        {
            var result = await _homeService.SetElevatorDeviceCategoryDraft(info);
            return GetResponse(ApiResult.Success, result);
        }

    }
}

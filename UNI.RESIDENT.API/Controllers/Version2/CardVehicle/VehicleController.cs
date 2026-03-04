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
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.CardVehicle
{

    /// <summary>
    /// Vehicle Controller
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/vehicle/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class VehicleController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IVehicleService _vehicleService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="VehicleController"/> class.
        /// </summary>
        /// <param name="vehicleService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public VehicleController(
            IVehicleService vehicleService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _vehicleService = vehicleService;
            //_userService = userService;
            _mapper = mapper;
            //_appService = appService;
            //_custService = custService;
        }
        #endregion instance-reg

        #region Vehicle-reg
        /// <summary>
        /// GetApartmentVehiclePageAsync - Danh sách phương tiện theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetApartmentVehiclePageAsync([FromQuery] VehicleRequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _vehicleService.GetApartmentVehiclePageAsync(query);
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
        /// GetApartmentVehicleInfo - Xem chi tiết phương tiện thuộc căn hộ
        /// </summary>
        /// <param name="cardVehicleId">Id thẻ xe. Bỏ qua nếu truyền cardVehicleOid.</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ApartmentVehicleInfo>> GetApartmentVehicleInfo([FromQuery] int? cardVehicleId = null, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var rs = await _vehicleService.GetApartmentVehicleInfo(UserId, cardVehicleId ?? 0, cardVehicleOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ApartmentVehicleInfo>(ApiResult.Error, e.Message);
                return rp;
            }

        }

        /// <summary>
        /// SetApartmentVehicleInfo - Chỉnh sửa thông tin phương tiện thuộc căn hộ
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentVehicleInfo([FromBody] viewBaseInfo info)
        {
            try
            {
                var rs = await _vehicleService.SetApartmentVehicleInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        #endregion card partner


        #region import-reg
        /// <summary>
        /// GetVehicleNumImportTemp - Lấy danh sách template
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetVehicleNumImportTemp()
        {
            try
            {
                var rs = await _vehicleService.GetVehicleNumImportTemp();
                return File(rs.Data, "application/octet-stream", "import_vehicle_num.xlsx");
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
        public async Task<BaseResponse<ImportListPage>> SetVehicleNumImport(IFormFile file)
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
                var vehicleNumImport = new VehicleNumImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    vehicleNumImport.imports = FlexcellUtils.ReadToObject<VehicleNumImportItem>(fs.ToArray(), 1);
                }
                vehicleNumImport.importFile = new uImportFile
                {
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _vehicleService.SetVehicleNumImport(UserId, vehicleNumImport, false);
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
        /// <param name="vehicleNumImport"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetVehicleNumImportAccept([FromBody] VehicleNumImportSet vehicleNumImport)
        {
            try
            {
                var rs = await _vehicleService.SetVehicleNumImport(UserId, vehicleNumImport, true);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }
        #endregion import-reg
    }
}

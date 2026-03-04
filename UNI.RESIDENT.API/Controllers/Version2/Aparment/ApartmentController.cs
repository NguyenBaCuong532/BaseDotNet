using AutoMapper;
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
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Aparment
{

    /// <summary>
    /// Apartment Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/apartment/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ApartmentController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IApartmentService _apartmentService;
        private readonly IUserService _userService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ApartmentController"/> class.
        /// </summary>
        /// <param name="apartmentService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ApartmentController(IApartmentService apartmentService,
            IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _apartmentService = apartmentService;
            _userService = userService;
            _mapper = mapper;
        }

        #region Apartment
        /// <summary>
        /// GetEmployeeStatus
        /// </summary>
        /// <param name="apartId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ApartmentStatus>> GetApartmentStatus([FromQuery] Guid apartId)
        {
            var result = await _apartmentService.GetApartmentStatus(apartId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetApartmentSearch - Tìm kiếm căn hộ
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="buildingCd">Mã tòa nhà (string) - backward compatible</param>
        /// <param name="filter"></param>
        /// <param name="buildingOid">Oid tòa nhà (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<HomApartment>>> GetApartmentSearchAsync([FromQuery] string projectCd, [FromQuery] string buildingCd, [FromQuery] string filter, [FromQuery] Guid? buildingOid = null)
        {
            var result = await _apartmentService.GetApartmentSearch(projectCd, buildingCd, filter, buildingOid);
            return GetResponse(ApiResult.Success, result);
        }        
        /// <summary>
        /// GetApartmentFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetApartmentFilter()
        {
            var result = await _apartmentService.GetApartmentFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Apartment Page
        /// </summary>
        /// <param name="query"></param>
        /// <param name="Debt">values -1: Tất car, 0: Không nợ, 1: Nợ, 2 Thừa tiền(được giảm)</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetApartmentPage([FromQuery] ApartmentRequestModel1 query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetApartmentPage(query);
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
        /// DeleteApartmentAsync - Xóa căn hộ
        /// </summary>
        /// <param name="apartmentId">Mã căn hộ (int) - backward compatible</param>
        /// <param name="Oid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteApartmentAsync([FromQuery] int? apartmentId, [FromQuery] Guid? Oid)
        {
            try
            {
                var rs = await _apartmentService.DeleteApartmentAsync(apartmentId, Oid);
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
        /// GetApartmentInfo - Xem chi tiết căn hộ
        /// </summary>
        /// <param name="apartmentId">Mã căn hộ (int) - backward compatible</param>
        /// <param name="Oid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ApartmentInfo>> GetApartmentInfo([FromQuery] int? apartmentId, [FromQuery] Guid? Oid)
        {

            try
            {
                var rs = await _apartmentService.GetApartmentInfo(apartmentId, Oid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ApartmentInfo>(ApiResult.Error, e.Message);
                return rp;
            }

        }
        /// <summary>
        /// SetApartmentInfo - Chỉnh sửa chi tiết căn hộ
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentInfo([FromBody] ApartmentInfo info)
        {

            try
            {
                var rs = await _apartmentService.SetApartmentInfo(info);
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
        /// GetApartmentChangeRoomCodeInfoAsync - lấy form đổi căn hộ
        /// </summary>
        /// <param name="Oid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <param name="roomCode">Mã phòng (string) - backward compatible</param>
        /// <param name="buildingCd">Mã tòa nhà (string) - backward compatible</param>
        /// <param name="buildingOid">Oid tòa nhà (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewOidInfo>> GetApartmentChangeRoomCodeInfoAsync([FromQuery] Guid? Oid, [FromQuery] string roomCode, [FromQuery] string buildingCd, [FromQuery] Guid? buildingOid = null)
        {
            try
            {
                var rs = await _apartmentService.GetApartmentChangeRoomCodeInfoAsync(Oid, roomCode, buildingCd, buildingOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonViewOidInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetApartmentChangeRoomCodeInfoAsync - Sửa thông tin đổi căn hộ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentChangeRoomCodeInfoAsync([FromBody] CommonViewOidInfo info)
        {
            try
            {
                var rs = await _apartmentService.SetApartmentChangeRoomCodeInfoAsync(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        ///// <summary>
        ///// GetApartmentAddInfo - lấy form thêm mới căn hộ
        ///// </summary>
        ///// <param name="ApartmentId"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<ApartmentInfo>> GetApartmentAddInfo([FromQuery] string ApartmentId)
        //{
        //    try
        //    {
        //        var rs = await _apartmentService.GetApartmentAddInfo(ApartmentId);
        //        var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
        //        var response = GetResponse(sCode, rs);
        //        return response;
        //    }
        //    catch (Exception e)
        //    {
        //        _logger.LogError($"{e}");
        //        var rp = new BaseResponse<ApartmentInfo>(ApiResult.Error, e.Message);
        //        return rp;
        //    }
        //}
        ///// <summary>
        ///// SetApartmentInfo - thêm mới căn hộ
        ///// </summary>
        ///// <param name="info"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<string>> SetApartmentAddInfo([FromBody] ApartmentInfo info)
        //{
        //    try
        //    {
        //        var rs = await _apartmentService.SetApartmentAddInfo(info);
        //        var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
        //        return rp;
        //    }
        //    catch (Exception e)
        //    {
        //        _logger.LogError(e.ToString());
        //        return GetResponse(ApiResult.Error, "", e.Message);
        //    }
        //}
        /// <summary>
        /// GetApartmentImportTemp - Template import căn hộ
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetApartmentImportTemp()
        {
            var rs = await _apartmentService.GetApartmentImportTemp(UserId);
            return File(rs.Data, "application/octet-stream", "import_apartment.xlsx");
        }
        /// <summary>
        /// Import apartment
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> ApartmentImport(IFormFile file)
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
                var card = new ApartmentImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    var cards = FlexcellUtils.ReadToObject<ApartmentImportItem>(fs.ToArray(), 5);
                    cards.RemoveAll(x => string.IsNullOrEmpty(x.ProjectCd) && string.IsNullOrEmpty(x.BuildingCd) && string.IsNullOrEmpty(x.FloorName) && string.IsNullOrEmpty(x.RoomCode));
                    card.imports = cards;
                }
                card.importFile = new uImportFile
                {
                    impId = Guid.NewGuid(),
                    fileName = file.FileName,
                    fileSize = file.Length,
                    fileType = Path.GetExtension(file.FileName),
                    fileUrl = await FireBaseServices.UploadFileCdn(file.OpenReadStream(), file.FileName, app: "s_service")
                };
                var rs = await _apartmentService.ImportApartmentAsync(card);
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
        /// ImportApartmentAccepted
        /// </summary>
        /// <param name="apartment"></param>
        /// <returns></returns>
        [HttpPost]
        [ProducesDefaultResponseType(typeof(BaseResponse<ImportListPage>))]
        public async Task<IActionResult> ImportApartmentAccepted([FromBody] ApartmentImportSet apartment)
        {
            var result = new BaseResponse<ImportListPage>();
            try
            {
                apartment.accept = true;
                result.Data = await _apartmentService.ImportApartmentAsync(apartment);
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
        #endregion

        #region ApartmentProfile
        /// <summary>
        /// DeleteApartmentProfile - Xóa hồ sơ căn hộ
        /// </summary>
        /// <param name="id">ID hồ sơ căn hộ</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteApartmentProfile([FromQuery] string id)
        {
            try
            {
                var rs = await _apartmentService.DeleteApartmentProfile(id);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// SetApartmentProfileInfo - Lưu thông tin hồ sơ căn hộ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetApartmentProfileInfo([FromBody] ApartmentProfileInfo info)
        {
            try
            {
                if (!this.ModelState.IsValid)
                {
                    return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                var rs = await _apartmentService.SetApartmentProfileInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// GetApartmentProfileInfo - Lấy thông tin hồ sơ căn hộ
        /// </summary>
        /// <param name="id">ID hồ sơ căn hộ</param>
        /// <param name="Oid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <param name="apartmentId">ID căn hộ (int) - backward compatible</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ApartmentProfileInfo>> GetApartmentProfileInfo([FromQuery] string id, [FromQuery] Guid? Oid, [FromQuery] int? apartmentId)
        {
            try
            {
                var rs = await _apartmentService.GetApartmentProfileInfo(id, Oid, apartmentId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<ApartmentProfileInfo>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// GetApartmentProfilePage - Lấy danh sách hồ sơ căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetApartmentProfilePage([FromQuery] ApartmentProfileRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetApartmentProfilePage(query);
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

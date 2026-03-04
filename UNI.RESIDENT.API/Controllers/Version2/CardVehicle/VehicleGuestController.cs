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
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.CardVehicle
{

    /// <summary>
    /// Card Controller
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/vehicleGuest/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class VehicleGuestController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IVehicleGuestService _cardService;
        private readonly IUserService _userService;
        private readonly IMetaImportService _importManagerService;

        /// <summary>
        /// Initializes a new instance of the <see cref="VehicleGuestController"/> class.
        /// </summary>
        /// <param name="cardService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        /// <param name="importManagerService"></param>
        public VehicleGuestController(IVehicleGuestService cardService,
            IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IMetaImportService importManagerService) : base(appSettings, logger)
        {
            _cardService = cardService;
            _userService = userService;
            _importManagerService = importManagerService;
        }
        #endregion instance-reg

        /// <summary>
        /// GetVehicleFilter - Bộ lọc thẻ lượt
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetVehicleFilter()
        {
            var result = await _cardService.GetVehicleFilter();
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetVehicleCardPageAsync - Danh sách thẻ xe theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehiclePage([FromQuery] VehicleGuestFilter query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _cardService.GetVehiclePage(query);
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
        /// GetVehicleCardInfoAsync - lấy chi tiết thẻ xe
        /// </summary>
        /// <param name="CardVehicleId">Id thẻ xe. Bỏ qua nếu truyền cardVehicleOid.</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<VehicleCardInfo>> GetVehicleInfo([FromQuery] int? CardVehicleId, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var rs = await _cardService.GetVehicleInfo(CardVehicleId, cardVehicleOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<VehicleCardInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetVehicleCardInfoAsync - Thêm mới/sửa thẻ xe
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetVehicleInfo([FromBody] VehicleCardInfo info)
        {
            try
            {
                var rs = await _cardService.SetVehicleInfo(info);
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
        /// SetVehicleLockedAsync - Mở/ khóa thẻ xe
        /// </summary>
        /// <param name="CardVehicleId">CardVehicleId. Bỏ qua nếu truyền cardVehicleOid.</param>
        /// <param name="Status">0: Mở thẻ, 1: Khóa thẻ</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetVehicleLocked([FromQuery] int CardVehicleId, [FromQuery] int Status, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var rs = await _cardService.SetVehicleLocked(CardVehicleId, Status, cardVehicleOid);
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
        ///// GetVehiclePaymentByDayInfoAsync - tính gia hạn thẻ
        ///// </summary>
        ///// <param name="info"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<VehicleCardInfo>> GetVehiclePaymentByDayInfoAsync([FromQuery] string CardVehicleId, [FromQuery] string StartDate, [FromQuery] string EndDate)
        //{
        //    try
        //    {
        //        var projectCd = await _userService.GetUserProject(UserId);
        //        var rs = await _cardService.GetVehiclePaymentByDayInfoAsync(CardVehicleId, StartDate, EndDate, projectCd);
        //        var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
        //        var response = GetResponse(sCode, rs);
        //        return response;
        //    }
        //    catch (Exception e)
        //    {
        //        _logger.LogError($"{e}");
        //        var rp = new BaseResponse<VehicleCardInfo>(ApiResult.Error, e.Message);
        //        return rp;
        //    }
        //}
        ///// <summary>
        ///// SetVehiclePaymentByDayInfoAsync - cập nhật gia hạn thẻ
        ///// </summary>
        ///// <param name="info"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<string>> SetVehiclePaymentByDayInfoAsync([FromBody] VehicleCardInfo info)
        //{
        //    try
        //    {
        //        var rs = await _cardService.SetVehiclePaymentByDayInfoAsync(info);
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
        /// DeleteVehicleCardAsync - Xóa thẻ xe
        /// </summary>
        /// <param name="cardVehicleId">Id thẻ xe. Bỏ qua nếu truyền cardVehicleOid.</param>
        /// <param name="cardVehicleOid">Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelVehicleInfo([FromQuery] int cardVehicleId, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var rs = await _cardService.DelVehicleInfo(cardVehicleId, cardVehicleOid);
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
        /// Lịch sử import
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="gridWidth"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetImportPage(
            [FromQuery] string filter = "",
            [FromQuery] int? offSet = 0,
            [FromQuery] int? pageSize = 10,
            [FromQuery] int? gridWidth = 0
            )
        {
            var flt = new FilterBase(ClientId, UserId, offSet, pageSize, filter, gridWidth);
            var result = await _importManagerService.GetImportPageAsync(flt, "cards");
            var rp = GetResponse(ApiResult.Success, result);
            return Ok(rp);
        }
        /// <summary>
        /// GetVehicleImportTemp
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetVehicleImportTemp()
        {
            var rs = await _cardService.GetVehicleImportTemp();
            return File(rs.Data, "application/octet-stream", "import_card.xlsx");
        }
        /// <summary>
        /// Import vehicle card - Nhập thẻ xe
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> VehicleCardImport(IFormFile file)
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
                var card = new CardVehicleImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    var cards = FlexcellUtils.ReadToObject<CardVehicleImportItem>(fs.ToArray(), 5);
                    cards.RemoveAll(x => string.IsNullOrEmpty(x.Code));
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
                var rs = await _cardService.ImportVehicleAsync(card);
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

    }
}

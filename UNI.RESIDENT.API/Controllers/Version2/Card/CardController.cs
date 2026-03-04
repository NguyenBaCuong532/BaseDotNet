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
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Card
{

    /// <summary>
    /// Card Controller
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/card/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly ICardService _cardService;
        private readonly IUserService _userService;
        //private readonly IMapper _mapper;
        private readonly IMetaImportService _importManagerService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CardController"/> class.
        /// </summary>
        /// <param name="cardService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        /// <param name="importManagerService"></param>
        public CardController(ICardService cardService,
            IUserService userService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper,
            IMetaImportService importManagerService) : base(appSettings, logger)
        {
            _cardService = cardService;
            _userService = userService;
            //_mapper = mapper;
            _importManagerService = importManagerService;
        }
        #endregion instance-reg

        ///// <summary>
        ///// GetCardBasePage - Danh sách thẻ căn hộ
        ///// </summary>
        ///// <param name="query"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<IActionResult> GetCardBasePage([FromQuery] FilterBase query)
        //{
        //    query.userId = UserId;
        //    query.clientId = ClientId;
        //    CommonDataPage rs = await _cardService.GetCardBasePageAsync(query);
        //    var rp = GetResponse(ApiResult.Success, rs);
        //    return Ok(rp);
        //}

        /// <summary>
        /// GetCardPageAsync - Danh sách thẻ theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetCardPage([FromQuery] FamilyCardRequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _cardService.GetCardPageAsync(query);
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
        /// Danh sách thẻ khác
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetGuestCardPage([FromQuery] CardGuestFilter query)
        {
            //query.UserId = UserId;
            //query.ClientId = ClientId;
            CommonDataPage rs = await _cardService.GetGuestCardPageAsync(query);
            var rp = GetResponse(ApiResult.Success, rs);
            return rp;
        }
        /// <summary>
        /// Get Chi tiết/Thêm/Sửa thông tin thẻ
        /// </summary>
        /// <param name="cardType">Loại thẻ: guest(thẻ khách)</param>
        /// <param name="cardCode">mã thẻ</param>
        /// <returns></returns>
        [HttpGet("{cardType}")]
        public async Task<BaseResponse<CommonViewInfo>> GetInfo(string cardType, string cardCode)
        {
            CommonViewInfo rs = await _cardService.GetInfoAsync(cardType, cardCode);
            var rp = GetResponse(ApiResult.Success, rs);
            return rp;
        }
        /// <summary>
        /// Thêm/sửa thẻ khách
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> SetGuestCardInfo([FromBody] CommonViewInfo info)
        {
            BaseValidate rs = await _cardService.SetGuestCardInfoAsync(info);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// GetCardInfoAsync - lấy chi tiết thẻ
        /// </summary>
        /// <param name="CardCd">Mã thẻ (CardCd) - backward compatible</param>
        /// <param name="cardOid">Oid thẻ (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<FamilyCardInfo>> GetCardInfo([FromQuery] string CardCd, [FromQuery] Guid? cardOid = null)
        {
            try
            {
                var rs = await _cardService.GetCardInfoAsync(CardCd, cardOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyCardInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }

        [HttpGet]
        public async Task<BaseResponse<FamilyCardInfo>> GetEditCardInfo([FromQuery] string CardCd, [FromQuery] Guid? cardOid = null)
        {
            try
            {
                var rs = await _cardService.GetEditCardInfoAsync(CardCd, cardOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyCardInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }

        //
        /// <summary>
        /// GetCardInfoAsync - lấy chi tiết thẻ
        /// </summary>
        /// <param name="CustId"> id khách hàng</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<FamilyCardInfo>> GetCardLockInfo([FromQuery] string CardCd, [FromQuery] Guid? cardOid = null)
        {
            try
            {
                var rs = await _cardService.GetCardLockInfoAsync(CardCd, cardOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyCardInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        //
        /// <summary>
        /// SetCardInfoAsync - sửa chủ thẻ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetCardInfoAsync([FromBody] FamilyCardInfo info)
        {
            try
            {
                var rs = await _cardService.SetCardInfoAsync(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        //
        /// <summary>
        /// SetCardInfoAsync - sửa chủ thẻ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetEditCardInfoAsync([FromBody] FamilyCardInfo info)
        {
            try
            {
                var rs = await _cardService.SetEditCardInfoAsync(info);
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
        /// DeleteCardAsync - Xóa thẻ căn hộ 
        /// </summary>
        /// <param name="CardCd"> mã thẻ</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteCardAsync(string CardCd)
        {
            try
            {
                var rs = await _cardService.DeleteCardAsync(CardCd);
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
        /// SetCardLocked - Mở/ khóa thẻ xe
        /// </summary>
        /// <param name="CardCd"> mã thẻ</param>
        /// <param name="Status">0: Mở thẻ, 1: Khóa thẻ</param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetCardLocked([FromBody] CardStatus cardStatus)
        {
            try
            {
                var rs = await _cardService.SetCardLockedAsync(cardStatus.CardCd, cardStatus.Status, cardStatus.Reason, cardStatus.IsHardLock);
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
        /// GetCardInfo - lấy form thêm thẻ: thẻ căn hộ,thẻ xe và thẻ tin dụng
        /// </summary>
        /// <param name="RoomCd"> Mã phòng</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CardInfoV2>> GetCardInfoV2([FromQuery] string RoomCd)
        {
            try
            {
                var rs = await _cardService.GetCardInfoV2(RoomCd);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CardInfoV2>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetCardInfoV2 - thêm thẻ: thẻ căn hộ,thẻ xe và thẻ tin dụng
        /// </summary>
        /// <param name="info">Trường @RoomCd bắt buộc truyền vào khi call api</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetCardInfoV2([FromBody] CardInfoV2 info)
        {
            try
            {
                var rs = await _cardService.SetCardInfoV2(info);
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
        /// GetVehicleCardPageAsync - Danh sách thẻ xe theo căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehicleCardPageAsync([FromQuery] VehicleCardRequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _cardService.GetVehicleCardPageAsync(query);
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
        public async Task<BaseResponse<VehicleCardInfo>> GetVehicleCardInfoAsync([FromQuery] int? CardVehicleId, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var rs = await _cardService.GetVehicleCardInfoAsync(CardVehicleId, cardVehicleOid);
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

        [HttpPost]
        public async Task<BaseResponse<VehicleCardInfo>> GetVehicleCardDraftAsync([FromBody] VehicleCardInfo? info)
        {
            try
            {
                var rs = await _cardService.GetVehicleCardDraftAsync(info);
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
        public async Task<BaseResponse<string>> SetVehicleCardInfoAsync([FromBody] VehicleCardInfo info)
        {
            try
            {
                var projectCd = HttpContext.Request.Headers["projectcode"].ToString();
                var rs = await _cardService.SetVehicleCardInfoAsync(info, projectCd);
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
                var rs = await _cardService.SetVehicleLockedAsync(CardVehicleId, Status, cardVehicleOid);
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
        /// SetVehicleLockedAsync - Mở/ khóa thẻ xe thêm tham số 
        /// </summary>
        /// <param name="CardVehicleId"> CardVehicleId</param>
        /// <param name="Status">0: Mở thẻ, 1: Khóa thẻ</param>
        /// <returns></returns>
        /// 
        /*[HttpPost]
        public async Task<BaseResponse<string>> SetVehicleLockedWithReason([FromQuery] int CardVehicleId, [FromQuery] int Status, string reason, bool isHardLock)
        {
            try
            {
                var rs = await _cardService.SetVehicleLockedWithReasonAsync(CardVehicleId, Status, reason, isHardLock);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }*/

        [HttpPost]
        public async Task<BaseResponse<string>> SetVehicleLockedWithReason([FromBody] VehicleLockRequest request)
        {
            try
            {
                var rs = await _cardService.SetVehicleLockedWithReasonAsync(
                    request.CardVehicleId,
                    request.Status,
                    request.Reason,
                    request.IsHardLock,
                    request.CardVehicleOid
                );

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
        /// Gửi yêu cầu đóng thẻ gửi xe
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public async Task<BaseResponse<string>> SetCardReturnRequest(CardVehicle_CardReturnRequest inputParam)
        {
            try
            {
                var rs = await _cardService.SetCardReturnRequest(inputParam);
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
        /// GetVehiclePaymentByDayInfoAsync - tính gia hạn thẻ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<VehicleCardInfo>> GetVehiclePaymentByDayInfoAsync([FromQuery] string CardVehicleId, [FromQuery] string StartDate, [FromQuery] string EndDate)
        {
            try
            {
                var projectCd = await _userService.GetUserProject(UserId);
                var rs = await _cardService.GetVehiclePaymentByDayInfoAsync(CardVehicleId, StartDate, EndDate, projectCd);
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
        /// SetVehiclePaymentByDayInfoAsync - cập nhật gia hạn thẻ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetVehiclePaymentByDayInfoAsync([FromBody] VehicleCardInfo info)
        {
            try
            {
                var rs = await _cardService.SetVehiclePaymentByDayInfoAsync(info);
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
        /// DeleteVehicleCardAsync - Xóa thẻ xe
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteVehicleCardAsync([FromQuery] int cardVehicleId, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var rs = await _cardService.DeleteVehicleCardAsync(cardVehicleId, cardVehicleOid);
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
        /// GetResidentVehicleFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetResidentVehicleFilter()
        {
            var result = _cardService.GetResidentVehicleFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetResidentVehiclePage - Danh sách xe cư dân
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetResidentVehiclePage([FromQuery] ResidentVehicleRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;

                var rs = await _cardService.GetResidentVehiclePage(query);
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
        /// GetResidentCardFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetResidentCardFilter()
        {
            var result = _cardService.GetResidentCardFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetResidentCardPage - Danh sách thẻ cư dân
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetResidentCardPage([FromQuery] FilterCardResident query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;

                var rs = await _cardService.GetResidentCardPage(query);
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

        //[HttpGet]
        //public async Task<FileStreamResult> GetImportTemplate()
        //{
        //    var rs = await _cardService.GetCardBaseImportTemp(UserId);
        //    return File(rs.Data, "application/octet-stream", "import_card.xlsx");
        //}
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
        /// Import card
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> Import(IFormFile file)
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
                var card = new CardImportSet();
                using (var fs = new MemoryStream())
                {
                    await file.CopyToAsync(fs);
                    var cards = FlexcellUtils.ReadToObject<CardImportItem>(fs.ToArray(), 5);
                    cards.RemoveAll(x => string.IsNullOrEmpty(x.Code) && string.IsNullOrEmpty(x.Serial) && string.IsNullOrEmpty(x.Hex));
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
                var rs = await _cardService.ImportAsync(card);
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
        [HttpPost]
        [ProducesDefaultResponseType(typeof(BaseResponse<ImportListPage>))]
        public async Task<IActionResult> ImportAccepted([FromBody] CardImportSet card)
        {
            var result = new BaseResponse<ImportListPage>();
            try
            {
                card.accept = true;
                result.Data = await _cardService.ImportAsync(card);
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
        [ProducesDefaultResponseType(typeof(BaseResponse<ImportListPage>))]
        public async Task<IActionResult> ImportVehicleCardBaseAccepted([FromBody] CardVehicleImportSet card)
        {
            var result = new BaseResponse<ImportListPage>();
            try
            {
                card.accept = true;
                result.Data = await _cardService.ImportVehicleAsync(card);
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

        //[HttpGet("{id}")]
        //public async Task<IActionResult> ClassifyInfo(string id)
        //{
        //    var rs = await _cardService.GetClassifyInfoAsync(id);
        //    var rp = GetResponse(ApiResult.Success, rs);
        //    return Ok(rp);
        //}
        ///// <summary>
        ///// Phân loại card
        ///// </summary>
        ///// <param name="info"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<IActionResult> Classify([FromBody] CardClassificationInfo info)
        //{
        //    BaseValidate rs = await _cardService.GetCardBaseAsync(info);
        //    var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
        //    return Ok(rp);
        //}
        ///// <summary>
        ///// DeleteCardBase - Xóa thẻ căn hộ
        ///// </summary>
        ///// <param name="id"></param>
        ///// <returns></returns>
        //[HttpDelete("{id}")]
        //public async Task<IActionResult> DeleteCardBase(string id)
        //{
        //    BaseValidate rs = await _cardService.DeleteCardBaseAsync(id);
        //    var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
        //    return Ok(rp);
        //}
        /// <summary>
        /// GetVehicleCardBaseImportTemp - Lấy mẫu thẻ xe để import
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetVehicleCardBaseImportTemp()
        {
            var rs = await _cardService.GetVehicleCardBaseImportTemp(UserId);
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
        /// <summary>
        /// GetVehicleCardDailyFilter - Bộ lọc thẻ lượt
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetVehicleCardDailyFilter()
        {
            var result = _cardService.GetVehicleCardDailyFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetVehicleCardDailyPage - Danh sách thẻ lượt
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehicleCardDailyPage([FromQuery] VehicleCardDailyRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;

                var rs = await _cardService.GetVehicleCardDailyPage(query);
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
        /// GetVehicleHistoryChange - lấy lịch sử chi tiết thẻ xe
        /// </summary>
        /// <param name="query"> id thẻ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehicleHistoryChange([FromQuery] VehicleHistoryChange query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _cardService.GetVehicleHistoryChange(query);
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
        /// SetCardVehicleServiceAuth - Authen Card Vehicle Service, chuyển từ api/v1/shome qua 
        /// </summary>
        /// <param name="query"> id thẻ</param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPut]
        public async Task<BaseResponse<string>> SetCardVehicleServiceAuth([FromBody] HomVehicleServiceAuth card)
        {
            await _cardService.SetCardVehicleServiceAuth(card);
            //await this.NotificationTakeAction(new NotificationAction(saler.UserId, saler.UserLogin, emNotiAction.SalerAuth, DateTime.Now));
            return GetResponse<string>(ApiResult.Success, null);

        }

        /// <summary>
        /// GetVehicleCardServicePageAsync 
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetVehicleCardServicePageAsync([FromQuery] VehicleCardRequestModel query)
        {
            try
            {
                query.userId = UserId;
                var rs = await _cardService.GetVehicleCardServicePageAsync(query);
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

        [HttpGet]
        public async Task<BaseResponse<VehiclePaymentLoadFormInfo>> GetVehiclePaymentLoadForm([FromQuery] int CardVehicleId, [FromQuery] Guid? PaymentId = null, [FromQuery] Guid? cardVehicleOid = null)
        {
            try
            {
                var projectCd = HttpContext.Request.Headers["projectcode"].ToString();
                var rs = await _cardService.GetVehiclePaymentLoadFormAsync(UserId, ClientId, projectCd, PaymentId, CardVehicleId, cardVehicleOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                return GetResponse(sCode, rs);
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                return new BaseResponse<VehiclePaymentLoadFormInfo>(ApiResult.Error, e.Message);
            }
        }

        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetVehiclePaymentSubmit([FromBody] VehiclePaymentSubmitRequest request)
        {
            try
            {
                if (request == null)
                    return new BaseResponse<BaseValidate>(ApiResult.Error, "Request body is required");

                var projectCd = HttpContext.Request.Headers["projectcode"].ToString();
                projectCd = string.IsNullOrWhiteSpace(projectCd) ? null : projectCd.Trim();

                var rs = await _cardService.SetVehiclePaymentSubmitAsync(UserId, ClientId, projectCd, request);

                var sCode = (rs != null && rs.valid) ? ApiResult.Success : ApiResult.Error;
                return GetResponse(sCode, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, "SetVehiclePaymentSubmit error");
                return new BaseResponse<BaseValidate>(ApiResult.Error, e.Message);
            }
        }





    }
}

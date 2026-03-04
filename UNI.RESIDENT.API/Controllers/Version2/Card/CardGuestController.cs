using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;

namespace UNI.Resident.API.Controllers.Version2.Card
{

    /// <summary>
    /// Card Guest Controller - Quản lý thẻ khách
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/cardguest/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardGuestController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly ICardGuestService _cardService;
        private readonly IUserService _userService;
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
        public CardGuestController(ICardGuestService cardService,
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
        /// GetCardFilter
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetCardFilter()
        {
            var result = await _cardService.GetCardFilter();
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Danh sách thẻ khác
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetCardGuestPage([FromQuery] CardGuestFilter query)
        {
            //query.UserId = UserId;
            //query.ClientId = ClientId;
            CommonDataPage rs = await _cardService.GetCardGuestPage(query);
            var rp = GetResponse(ApiResult.Success, rs);
            return rp;
        }
        /// <summary>
        /// Get Chi tiết/Thêm/Sửa thông tin thẻ khách
        /// </summary>
        /// <param name="cardId">Mã thẻ (CardCd). Bỏ qua nếu truyền cardOid.</param>
        /// <param name="partner_id">Mã đối tác</param>
        /// <param name="cardOid">Khóa logic thẻ (MAS_Cards.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetCardGuestInfo([FromQuery] string cardId, [FromQuery] string partner_id, [FromQuery] Guid? cardOid = null)
        {
            CommonViewInfo rs = await _cardService.GetCardGuestInfo(cardId, partner_id, cardOid);
            var rp = GetResponse(ApiResult.Success, rs);
            return rp;
        }
        /// <summary>
        /// SetGuestCardDraft
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<CommonViewInfo>> SetGuestCardDraft([FromBody] CommonViewInfo info)
        {
            var rs = await _cardService.SetGuestCardDraft(info);
            return GetResponse(ApiResult.Success, rs);
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
        /// DeleteCardAsync - Xóa thẻ khách
        /// </summary>
        /// <param name="cardId">Mã thẻ (CardCd). Bỏ qua nếu truyền cardOid.</param>
        /// <param name="cardOid">Khóa logic thẻ (MAS_Cards.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteCardAsync([FromQuery] string cardId, [FromQuery] Guid? cardOid = null)
        {
            try
            {
                var rs = await _cardService.DeleteCardAsync(cardId, cardOid);
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
        /// SetCardLocked - Mở/ khóa thẻ khách
        /// </summary>
        /// <param name="status">CardCd hoặc CardOid (ưu tiên), Status: 0 = Mở thẻ, 1 = Khóa thẻ</param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetCardLocked([FromBody] CardStatus status)
        {
            try
            {
                var rs = await _cardService.SetCardLockedAsync(status.CardCd, status.Status, status.CardOid);
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

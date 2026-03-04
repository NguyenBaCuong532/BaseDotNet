using AutoMapper;
using DocumentFormat.OpenXml.EMMA;
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
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Card
{

    /// <summary>
    /// Card Internal Controller - Quản lý nội bộ
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/cardinternal/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardInternalController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly ICardInternalService _cardService;
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
        public CardInternalController(ICardInternalService cardService,
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
        /// GetCardPage - Danh sách thẻ nội bộ
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetCardPage([FromQuery] string projectCd, [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBaseProject(ClientId, UserId, offSet, pageSize, projectCd);
            var rs = await _cardService.GetCardPage(flt);
            return GetResponse(ApiResult.Success, rs);
        }

        /// <summary>
        /// GetCardInfoAsync - lấy chi tiết thẻ
        /// </summary>
        /// <param name="cardId">Mã thẻ (CardCd). Bỏ qua nếu truyền cardOid.</param>
        /// <param name="cardOid">Khóa logic thẻ (MAS_Cards.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetCardInfo([FromQuery] string cardId, [FromQuery] Guid? cardOid = null)
        {
            var rs = await _cardService.GetCardInfo(cardId, cardOid);
            var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
            var response = GetResponse(sCode, rs);
            return response;
        }
        /// <summary>
        /// SetCardInfoAsync - sửa chủ thẻ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetCardInfo([FromBody] CommonViewInfo info)
        {
            try
            {
                var rs = await _cardService.SetCardInfo(info);
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
        /// DeleteCardAsync - Xóa thẻ nội bộ
        /// </summary>
        /// <param name="cardId">Mã thẻ (CardCd). Bỏ qua nếu truyền cardOid.</param>
        /// <param name="cardOid">Khóa logic thẻ (MAS_Cards.oid). Ưu tiên khi có.</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteCard([FromQuery] string cardId, [FromQuery] Guid? cardOid = null)
        {
            try
            {
                var rs = await _cardService.DeleteCard(cardId, cardOid);
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
        /// SetCardLocked - Mở/ khóa thẻ nội bộ
        /// </summary>
        /// <param name="card">CardCd hoặc CardOid (ưu tiên), Status: 0 = Mở thẻ, 1 = Khóa thẻ</param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetCardLocked([FromBody] CardStatus card)
        {
            try
            {
                var rs = await _cardService.SetCardLocked(card.CardCd, card.Status, card.CardOid);
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

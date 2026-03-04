using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using System;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Utils;
using Microsoft.AspNetCore.Http.HttpResults;
using UNI.Resident.BLL.BusinessInterfaces.Settings;

namespace UNI.Resident.API.Controllers.Version2.Card
{

    /// <summary>
    /// Card Resident Controller - Quản lý thẻ căn hộ
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/cardresident/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CardResidentController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly ICardResidentService _cardService;
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
        public CardResidentController(ICardResidentService cardService,
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
        /// GetResidentCardFilter - Bộ lọc
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetResidentCardFilter()
        {
            var result = await _cardService.GetResidentCardFilter();
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
            var result = await _cardService.GetResidentCardPage(query);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetCardInfoAsync - lấy chi tiết thẻ
        /// </summary>
        /// <param name="cardId">Mã thẻ (CardCd) - backward compatible</param>
        /// <param name="apartmentId">ID căn hộ (string) - backward compatible</param>
        /// <param name="apartOid">Oid căn hộ (Guid) - ưu tiên nếu có</param>
        /// <param name="cardOid">Oid thẻ (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetCardInfo([FromQuery] string cardId, [FromQuery] string apartmentId, [FromQuery] Guid? apartOid = null, [FromQuery] Guid? cardOid = null)
        {
            var result = await _cardService.GetCardInfoAsync(cardId, apartmentId, apartOid, cardOid);
            return GetResponse(ApiResult.Success, result);
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
        /// <summary>
        /// DeleteCardAsync - Xóa thẻ căn hộ 
        /// </summary>
        /// <param name="cardId"> mã thẻ</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteCard(string cardId)
        {
            try
            {
                var rs = await _cardService.DeleteCardAsync(cardId);
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
        /// <param name="cardStatus.CardCd"> mã thẻ</param>
        /// <param name="cardStatus">0: Mở thẻ, 1: Khóa thẻ</param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetCardLocked([FromBody] CardStatus cardStatus)
        {
            try
            {
                var rs = await _cardService.SetCardLockedAsync(cardStatus.CardCd, cardStatus.Status);
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

    }
}

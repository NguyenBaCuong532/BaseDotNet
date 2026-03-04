using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.Model.Common;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces.Card;

namespace UNI.Resident.API.Controllers.Version2.Visitor
{
    /// <summary>
    /// Thông tin đối tác thẻ
    /// </summary>
    [Route("api/v2/[controller]/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    [ApiController]
    public class PartnerController : UniController
    {
        private readonly ICardPartnerService _cardPartnerService;
        /// <summary>
        /// Khởi tạo đối tượng
        /// </summary>
        /// <param name="cardPartnerService"></param>
        public PartnerController(ICardPartnerService cardPartnerService)
        {
            _cardPartnerService = cardPartnerService;
        }
        /// <summary>
        /// Danh sách nhóm khách
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        [ProducesDefaultResponseType(typeof(BaseResponse<CommonDataPage>))]
        public async Task<IActionResult> GetPage([FromQuery] GridProjectFilter query)
        {
            query.userId = UserId;
            query.clientId = ClientId;
            var rs = await _cardPartnerService.GetPageAsync(query);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// Thông tin chi tiết
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetInfo([FromQuery] long? id)
        {
            CommonViewInfo rs = await _cardPartnerService.GetInfoAsync(id);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// GetList
        /// </summary>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetList([FromQuery] string projectCd)
        {
            IEnumerable<CommonValue> rs = await _cardPartnerService.GetListAsync(projectCd);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// Thêm/cập nhật
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> SetInfo([FromBody] CommonViewInfo info)
        {
            var rs = await _cardPartnerService.SetInfoAsync(info);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
            rp.Message = rs.messages;
            return Ok(rp);
        }
        /// <summary>
        /// Xoá nhóm khách
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<IActionResult> Delete(long? id)
        {
            BaseValidate rs = await _cardPartnerService.DeleteAsync(id);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
            rp.Message = rs.messages;
            return Ok(rp);
        }
    }
}

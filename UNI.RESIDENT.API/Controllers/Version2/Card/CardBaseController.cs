using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Card
{
    /// <summary>
    /// Kho thẻ
    /// </summary>
    [Route("api/v2/cardbase/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    [ApiController]
    public class CardBaseController : UniController
    {
        private readonly ICardBaseService _cardService;
        private readonly IMetaImportService _importManagerService;
        /// <summary>
        /// Khởi tạo CardBaseController
        /// </summary>
        /// <param name="cardTypeService"></param>
        /// <param name="importManagerService"></param>
        public CardBaseController(ICardBaseService cardTypeService, IMetaImportService importManagerService)
        {
            _cardService = cardTypeService;
            _importManagerService = importManagerService;
        }
        /// <summary>
        /// GetCardBases
        /// </summary>
        /// <param name="Oid"></param>
        /// <param name="projectCd"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetCardBaseList([FromQuery] string projectCd, [FromQuery] Guid? Oid,  [FromQuery] string filter)
        {
            var result = await _cardService.GetCardBaseList(projectCd, Oid, filter);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetCardBasePage - Danh sách thẻ căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetCardBasePage([FromQuery] FilterBase query, long startNum, long endNum, bool status)
        {
            query.userId = UserId;
            query.clientId = ClientId;
            CommonDataPage rs = await _cardService.GetCardBasePage(query, startNum, endNum, status);
            var msg = "";
            var apiResult = ApiResult.Success;
            if (startNum > endNum )
            {
                msg = "Lỗi: Yêu cầu nhập Số bắt đầu > Số kết thúc";
                apiResult = ApiResult.Warning;
            }
            if ((endNum - startNum)> 100000) 
            {
                msg = "Lỗi:Khoảng cách lọc quá lớn";
                apiResult = ApiResult.Warning;
            }

            return GetResponse(apiResult, rs, msg);

        }
        /// <summary>
        /// GetCardBasePage - Filter thẻ 
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<CommonViewInfo> GetCardBaseFilter()
        {
            var result = _cardService.GetCardBaseFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Phân loại card
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> SetBaseClassify([FromBody] CardClassificationInfo info)
        {
            BaseValidate rs = await _cardService.SetBaseClassify(info);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// ClassifyInfo
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        //[HttpGet("{id}")]
        //[HttpGet("GetClassifyInfo")]
        [HttpGet]
        /*public async Task<IActionResult> GetClassifyInfo(Guid? id)
        {
            var rs = await _cardService.GetClassifyInfo(id);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }*/
        public async Task<IActionResult> GetClassifyInfo([FromQuery] Guid? id)
        {
            var rs = await _cardService.GetClassifyInfo(id);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// DeleteCardBase - Xóa thẻ căn hộ
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCardBase(string id)
        {
            BaseValidate rs = await _cardService.DeleteCardBase(id);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// GetCardBaseImportTemp
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<FileStreamResult> GetCardBaseImportTemp()
        {
            var rs = await _cardService.GetCardBaseImportTemp();
            return File(rs.Data, "application/octet-stream", "import_card.xlsx");
        }
        /// <summary>
        /// Import card
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<ImportListPage>> SetCardBaseImport(IFormFile file)
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
                var rs = await _cardService.SetCardBaseImportAsync(card);
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
        /// SetCardBaseImportAccepted
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        [HttpPost]
        [ProducesDefaultResponseType(typeof(BaseResponse<ImportListPage>))]
        public async Task<IActionResult> SetCardBaseImportAccepted([FromBody] CardImportSet card)
        {
            var result = new BaseResponse<ImportListPage>();
            try
            {
                card.accept = true;
                result.Data = await _cardService.SetCardBaseImportAsync(card);
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

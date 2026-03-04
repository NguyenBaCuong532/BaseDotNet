using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Settings;

namespace UNI.Resident.API.Controllers.Version2.Settings
{
    [Route("api/v2/[controller]/[action]")]
    [ApiController]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ImportController : UniController
    {
        private readonly IMetaImportService _importManagerService;

        public ImportController(IMetaImportService importManagerService)
        {
            _importManagerService = importManagerService;
        }
        /// <summary>
        /// - Lấy dữ liệu trang import
        /// </summary>
        /// <param name="importType"></param>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="gridWidth"></param>
        /// <returns></returns>
        [HttpGet("{importType}")]
        public async Task<IActionResult> GetImportPage(
            [FromRoute] string importType,
            [FromQuery] string filter = "",
            [FromQuery] int? offSet = 0,
            [FromQuery] int? pageSize = 10,
            [FromQuery] int? gridWidth = 0
            )
        {
            var flt = new FilterBase(ClientId, UserId, offSet, pageSize, filter, gridWidth);
            var result = await _importManagerService.GetImportPageAsync(flt, importType);
            var rp = GetResponse(ApiResult.Success, result);
            return Ok(rp);
        }
        /// <summary>
        /// Xóa bản ghi import
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            var rs = await _importManagerService.DelImport(id);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
    }
}

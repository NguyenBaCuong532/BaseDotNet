using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2
{

    /// <summary>
    /// FileController
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 2024-09-30 9:31 AM
    /// <seealso cref="UniController" />
    [Route("api/v1/meta/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class MetaController : UniController
    {
        #region instance-reg
        private readonly IMetaService _metaService;
        private readonly IMapper _mapper;
        private readonly IWebHostEnvironment _env;

        /// <summary>
        /// Initializes a new instance of the <see cref="MetaController"/> class.
        /// </summary>
        /// <param name="FileService"></param>
        /// <param name="env"></param>
        /// <param name="mapper"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public MetaController(
            IMetaService FileService,
            IWebHostEnvironment env,
            IMapper mapper,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _env = env;
            _metaService = FileService;
            _mapper = mapper;
        }
        #endregion instance-reg

        #region File-reg
        ///// <summary>
        ///// Get Meta Filter
        ///// </summary>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<CommonViewInfo>> GetMetaFilter()
        //{
        //    var result = await _metaService.GetMetaFilter();
        //    return GetResponse(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// GetImageTrees
        ///// </summary>
        ///// <param name="source_type"></param>
        ///// <param name="parentOid"></param>
        ///// <param name="filter"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<List<nbMediaItem>> GetMetaTrees([FromQuery] string source_type, [FromQuery] Guid? parentOid, [FromQuery] string filter)
        //{
        //    var result = _metaService.GetMetaTrees(source_type, parentOid, filter);
        //    return GetResponse(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// GetDicTrees - Cây danh mục
        ///// </summary>
        ///// <param name="source_type"></param>
        ///// <param name="filter"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<List<nbMediaItemTree>>> GetMetaTreeNode([FromQuery] string source_type, [FromQuery] Guid? parentOid, [FromQuery] string filter)
        //{
        //    if (string.IsNullOrEmpty(source_type)) { source_type = string.Empty; }
        //    var result = await _metaService.GetMetaTreeNode(source_type, parentOid, filter);
        //    return GetResponse(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// GetFilePage - Danh sách File
        ///// </summary>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<CommonListPage>> GetMetaPage(
        //    [FromQuery] string filter, 
        //    [FromQuery] int offSet, 
        //    [FromQuery] int pageSize, 
        //    [FromQuery] Guid parentOid,
        //    [FromQuery] string source_type,
        //    [FromQuery] int? meta_type)
        //{
        //    var flt = new FilterBase(this.ClientId, this.UserId, offSet, pageSize, filter) {id = parentOid };
        //    var result = _metaService.GetMetaPage(flt, source_type, meta_type, this._appSettings.Server.baseUrl);
        //    return GetResponse<CommonListPage>(ApiResult.Success, result);
        //}

        ///// <summary>
        ///// SetFileInfo - Cập nhật File
        ///// </summary>
        ///// <param name="info"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<BaseValidate>> SetMetaInfo([FromBody] CommonViewOidInfo info)
        //{
        //    var result = await _metaService.SetMetaInfo(this.UserId, info);
        //    return GetResponse<BaseValidate>(ApiResult.Success, result);
        //}

        ///// <summary>
        ///// GetFileInfo - Lấy chi tiết File
        ///// </summary>
        ///// <param name="Oid"></param>
        ///// <param name="parentOid"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<CommonViewOidInfo> GetMetaInfo([FromQuery] Guid? Oid, [FromQuery] Guid? parentOid, [FromQuery] string source_type)
        //{
        //    var result = _metaService.GetMetaInfo(this.UserId, Oid, parentOid, source_type);
        //    return GetResponse<CommonViewOidInfo>(ApiResult.Success, result);
        //}
        /// <summary>
        /// DelFileInfo
        /// </summary>
        /// <param name="Oids"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelMetaInfo([FromQuery] string Oids)
        {
            await _metaService.DelMetaInfo(Oids);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// GetImageDetail
        /// </summary>
        /// <param name="Oid"></param>
        /// <param name="parentOid"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<FileStorageInfo>>> GetMetaDetail([FromQuery] Guid? Oid, [FromQuery] Guid? parentOid)
        {
            var result = await _metaService.GetMetaDetail(Oid, parentOid);
            return GetResponse<List<FileStorageInfo>>(ApiResult.Success, result);
        }
        /// <summary>
        /// SetImageUpload
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<FileStorageInfo>> SetMetaUpload([FromForm] MediaFile info)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<FileStorageInfo>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            if (info.formFile == null)
            {
                return GetErrorResponse<FileStorageInfo>(ApiResult.Invalid, 2, "Chưa chọn tệp");
            }
            if (!Path.GetExtension(info.formFile.FileName)!.Equals(".pdf", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".png", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".jpeg", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".jpg", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".gif", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".pjpeg", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".doc", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".xls", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".docx", StringComparison.OrdinalIgnoreCase)
                && !Path.GetExtension(info.formFile.FileName)!.Equals(".xlsx", StringComparison.OrdinalIgnoreCase)
                )
            {
                return GetErrorResponse<FileStorageInfo>(ApiResult.Error, 2, "Định dạng tệp không được hỗ trợ, chỉ hỗ trợ tệp .pdf;.png;.jpeg;.jpg;.gif;.pjpeg");
            }
            if (info.formFile == null)
            {
                return GetErrorResponse<FileStorageInfo>(ApiResult.Invalid, 2, "Chưa chọn file hồ sơ");
            }
            var result = await _metaService.SetMetaUpload(info);
            if (result != null && result.valid)
            {
                var data = await _metaService.GetMetaDetail(result.id, null);
                return GetResponse(ApiResult.Success, data.FirstOrDefault());
            }
            else
            {
                return GetErrorResponse<FileStorageInfo>(ApiResult.Invalid, 2, result.messages);
            }
        }
        #endregion File-reg

    }
}
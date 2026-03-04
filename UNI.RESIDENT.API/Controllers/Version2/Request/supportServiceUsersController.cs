using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.Model.Request;

namespace UNI.Resident.API.Controllers.Version2.Request
{
    /// <summary>
    /// Phân công trưởng nhóm và các thành viên xử lý nhóm yêu cầu hỗ trợ
    /// </summary>
    [Route("api/v2/supportServiceUsers/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class SupportServiceUsersController : UniController
    {
        private readonly ISupportServiceUsersService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public SupportServiceUsersController(ISupportServiceUsersService service,
            IOptions<AppSettings> appSettings, ILoggerFactory logger) : base(appSettings, logger)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetsupportServiceUsersFilter()
        {
            try
            {
                var result = await _service.GetsupportServiceUsersFilter();
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonViewInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="inputFilter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetsupportServiceUsersPage([FromQuery] SupportServiceUsersFilter inputFilter)
        {
            try
            {
                var result = await _service.GetsupportServiceUsersPage(inputFilter);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonDataPage(), ex.Message);
            }
        }

        /// <summary>
        /// Thông tin thêm/sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<viewBaseInfo>> GetsupportServiceUsersFields([FromQuery] Guid? oid)
        {
            try
            {
                var result = await _service.GetsupportServiceUsersFields(oid);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new viewBaseInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu nháp
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<viewBaseInfo>> SetsupportServiceUsersDraft([FromBody] viewBaseInfo inputData)
        {
            try
            {
                var result = await _service.GetsupportServiceUsersFields(null, inputData);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new viewBaseInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetsupportServiceUsers([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetsupportServiceUsers(inputData);
                return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Xóa một bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<BaseValidate>> SetsupportServiceUsersDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetsupportServiceUsersDelete(new List<Guid> { oid });
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Xóa nhiều bản ghi
        /// </summary>
        /// <param name="arrOid"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetsupportServiceUsersDeletes([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetsupportServiceUsersDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }
    }
}

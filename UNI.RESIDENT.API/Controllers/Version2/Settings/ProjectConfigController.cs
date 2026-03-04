using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.Model.Project;

namespace UNI.Resident.API.Controllers.Version2.Settings
{
    /// <summary>
    /// Cấu hình chung cho dự án
    /// </summary>
    [Route("api/v2/ProjectConfig/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ProjectConfigController : UniController
    {
        private readonly IProjectConfigService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public ProjectConfigController(IProjectConfigService service)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetProjectConfigFilter()
        {
            try
            {
                var result = await _service.GetProjectConfigFilter();
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
        public async Task<BaseResponse<CommonDataPage>> GetProjectConfigPage([FromQuery] FilterBase inputFilter)
        {
            try
            {
                var result = await _service.GetProjectConfigPage(inputFilter);
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
        public async Task<BaseResponse<viewBaseInfo>> GetProjectConfigFields([FromQuery] Guid? oid)
        {
            try
            {
                var result = await _service.GetProjectConfigFields(oid);
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
        public async Task<BaseResponse<BaseValidate>> SetProjectConfig([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetProjectConfig(inputData);
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
        public async Task<BaseResponse<BaseValidate>> SetProjectConfigDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetProjectConfigDelete(new List<Guid> { oid });
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
        public async Task<BaseResponse<BaseValidate>> SetProjectConfigDeletes([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetProjectConfigDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Upload/Set lại giá trị cấu hình mặc định. truyền null để upload lại file gốc, hoặc truyền giá trị để update luôn vào giá trị mặc định ở DB
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetProjectConfigDefaultValue([FromBody] ProjectConfigSetDefaultValueInput input)
        {
            try
            {
                var result = await _service.SetProjectConfigDefaultValue(input);
                return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="configCode"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<BaseValidate<string>>> GetProjectConfigValue([FromQuery] string configCode)
        {
            try
            {
                var result = await _service.GetProjectConfigValue(configCode);
                return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate<string>(), ex.Message);
            }
        }
    }
}
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;

namespace UNI.Resident.API.Controllers.Version2.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Nước
    /// </summary>
    [Route("api/v2/ServicePriceWater/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ServicePriceWaterController : UniController
    {
        private readonly IServicePriceWaterService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public ServicePriceWaterController(IServicePriceWaterService service)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetServicePriceWaterFilter()
        {
            try
            {
                var result = await _service.GetServicePriceWaterFilter();
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
        public async Task<BaseResponse<CommonDataPage>> GetServicePriceWaterPage([FromQuery] FilterBase inputFilter)
        {
            try
            {
                var result = await _service.GetServicePriceWaterPage(inputFilter);
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
        public async Task<BaseResponse<viewBaseInfo>> GetServicePriceWaterFields([FromQuery] Guid? oid)
        {
            try
            {
                var result = await _service.GetServicePriceWaterFields(oid, false);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new viewBaseInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Sao chép cấu hình bảng giá
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<viewBaseInfo>> GetServicePriceWaterCopyFields([FromQuery] Guid oid)
        {
            try
            {
                var result = await _service.GetServicePriceWaterFields(oid, true);
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceWater([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetServicePriceWater(inputData);
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceWaterDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetServicePriceWaterDelete(new List<Guid> { oid });
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceWaterDeletesMany([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetServicePriceWaterDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }
    }
}
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
    /// Cấu hình giá dịch vụ - Gửi xe tháng
    /// </summary>
    [Route("api/v2/ServicePriceVehicle/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ServicePriceVehicleController : UniController
    {
        private readonly IServicePriceVehicleService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public ServicePriceVehicleController(IServicePriceVehicleService service)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao cho danh sách dữ liệu phần trang dạng lưới
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetServicePriceVehicleFilter()
        {
            try
            {
                var result = await _service.GetServicePriceVehicleFilter();
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonViewInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị dạng lưới
        /// </summary>
        /// <param name="inputFilter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetServicePriceVehiclePage([FromQuery] FilterBase inputFilter)
        {
            try
            {
                var result = await _service.GetServicePriceVehiclePage(inputFilter);
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
        public async Task<BaseResponse<viewBaseInfo>> GetServicePriceVehicleFields([FromQuery] Guid? oid)
        {
            try
            {
                var result = await _service.GetServicePriceVehicleFields(oid);
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceVehicle([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetServicePriceVehicle(inputData);
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceVehicleDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetServicePriceVehicleDelete(new List<Guid> { oid });
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceVehicleDeletesMany([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetServicePriceVehicleDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Lấy danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetServicePriceVehicleTypeForDropdownList([FromQuery] string filter)
        {
            try
            {
                var result = await _service.GetServicePriceVehicleTypeForDropdownList(filter);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new List<CommonValue>(), ex.Message);
            }
        }

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetServicePriceVehicleDailyTypeForDropdownList([FromQuery] string filter)
        {
            try
            {
                var result = await _service.GetServicePriceVehicleDailyTypeForDropdownList(filter);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new List<CommonValue>(), ex.Message);
            }
        }
    }
}
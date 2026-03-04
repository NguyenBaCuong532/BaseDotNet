using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.API.Controllers.Version2.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Gửi xe ngày - Chi tiết
    /// </summary>
    [Route("api/v2/ServicePriceVehicleDailyDetail/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ServicePriceVehicleDailyDetailController : UniController
    {
        private readonly IServicePriceVehicleDailyDetailService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public ServicePriceVehicleDailyDetailController(IServicePriceVehicleDailyDetailService service)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetServicePriceVehicleDailyDetailFilter()
        {
            try
            {
                var result = await _service.GetServicePriceVehicleDailyDetailFilter();
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
        public async Task<BaseResponse<CommonDataPage>> GetServicePriceVehicleDailyDetailPage([FromQuery] ServicePriceVehicleDailyDetailTypeFilter inputFilter)
        {
            try
            {
                var result = await _service.GetServicePriceVehicleDailyDetailPage(inputFilter);
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
        /// <param name="vehicleDailyOid"></param>
        /// <param name="oid"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<viewBaseInfo>> GetServicePriceVehicleDailyDetailFields([FromQuery] Guid vehicleDailyOid, [FromQuery] Guid? oid)
        {
            try
            {
                var result = await _service.GetServicePriceVehicleDailyDetailFields(vehicleDailyOid, oid);
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceVehicleDailyDetail([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetServicePriceVehicleDailyDetail(inputData);
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceVehicleDailyDetailDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetServicePriceVehicleDailyDetailDelete(new List<Guid> { oid });
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
        public async Task<BaseResponse<BaseValidate>> SetServicePriceVehicleDailyDetailDeletesMany([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetServicePriceVehicleDailyDetailDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }
    }
}
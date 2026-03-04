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
    /// Cấu hình thứ tự ưu tiên thanh toán dịch vụ căn hộ
    /// </summary>
    [Route("api/v2/PaymentPriorityConfigs/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class PaymentPriorityConfigsController : UniController
    {
        private readonly IPaymentPriorityConfigsService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public PaymentPriorityConfigsController(IPaymentPriorityConfigsService service)
        {
            _service = service;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetPaymentPriorityConfigsFilter()
        {
            try
            {
                var result = await _service.GetPaymentPriorityConfigsFilter();
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
        public async Task<BaseResponse<CommonDataPage>> GetPaymentPriorityConfigsPage([FromQuery] FilterBase inputFilter)
        {
            try
            {
                var result = await _service.GetPaymentPriorityConfigsPage(inputFilter);
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
        public async Task<BaseResponse<viewBaseInfo>> GetPaymentPriorityConfigsFields([FromQuery] Guid? oid)
        {
            try
            {
                var result = await _service.GetPaymentPriorityConfigsFields(oid);
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
        public async Task<BaseResponse<BaseValidate>> SetPaymentPriorityConfigs([FromBody] CommonViewInfo inputData)
        {
            try
            {
                var result = await _service.SetPaymentPriorityConfigs(inputData);
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
        public async Task<BaseResponse<BaseValidate>> SetPaymentPriorityConfigsDelete([FromQuery] Guid oid)
        {
            try
            {
                var data = await _service.SetPaymentPriorityConfigsDelete(new List<Guid> { oid });
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
        public async Task<BaseResponse<BaseValidate>> SetPaymentPriorityConfigsDeletes([FromBody] List<Guid> arrOid)
        {
            try
            {
                var data = await _service.SetPaymentPriorityConfigsDelete(arrOid);
                return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }
    }
}
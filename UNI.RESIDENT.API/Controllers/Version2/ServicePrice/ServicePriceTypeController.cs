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
    /// Cấu hình giá dịch vụ - Loại giá dịch vụ: sinh hoạt, kinh doanh..
    /// </summary>
    [Route("api/v2/ServicePriceType/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ServicePriceTypeController : UniController
    {
        private readonly IServicePriceTypeService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public ServicePriceTypeController(IServicePriceTypeService service)
        {
            _service = service;
        }

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetServicePriceTypeForDropdownList([FromQuery] string filter)
        {
            try
            {
                var result = await _service.GetServicePriceTypeForDropdownList(filter);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new List<CommonValue>(), ex.Message);
            }
        }
    }
}
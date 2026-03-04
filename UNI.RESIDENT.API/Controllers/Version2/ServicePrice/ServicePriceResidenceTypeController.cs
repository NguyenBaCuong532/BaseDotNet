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
    /// Các loại hình căn hộ (Dịch vụ, cho thuê, cư dân....)
    /// </summary>
    [Route("api/v2/ServicePriceResidenceType/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ServicePriceResidenceTypeController : UniController
    {
        private readonly IServicePriceResidenceTypeService _service;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        public ServicePriceResidenceTypeController(IServicePriceResidenceTypeService service)
        {
            _service = service;
        }

        /// <summary>
        /// Danh sách cho Dropdown COntrol
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetServicePriceResidenceTypeForDropdownList([FromQuery] string filter)
        {
            try
            {
                var result = await _service.GetServicePriceResidenceTypeNameValue(filter);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new List<CommonValue>(), ex.Message);
            }
        }
    }
}
using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SSG.Resident.BLL.BusinessInterfaces.App;
using System.Collections.Generic;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.Marketing;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// Marketing Controller
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 07/02/2017 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/marketing/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class MarketingController : SSGController
    {
        private const string _PREFIX = "ssupapp_";

        private readonly IMarketingService _markService;
        private readonly IMapper _mapper;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="markService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public MarketingController(
            IMarketingService markService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _markService = markService;
        }
        #region App Home   


        /// <summary>
        /// Get Page Voucher
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="vou_status"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public ResponseList<List<mktVoucher>> GetVoucherPage([FromQuery] string filter, [FromQuery] int vou_status,
            [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBase2(this.ClientId, this.UserId, offSet, pageSize, filter, vou_status, 0);
            var result = _markService.GetVoucherPage(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        /// <summary>
        /// Get Voucher Detail
        /// </summary>
        /// <param name="vouId"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<mktVoucherGet> GetVoucher([FromQuery] string vouId)
        {
            var result = _markService.GetVoucher(this.UserId, vouId);
            return GetResponse(ApiResult.Success, result);
        }
        #endregion


    }
}

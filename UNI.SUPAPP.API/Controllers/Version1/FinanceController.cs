using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.Model.SHome;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// Finance Controller
    /// </summary>
    /// Author: duongpx 
    /// CreatedDate: 07/02/2020 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/finance/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class FinanceController : SSGController
    {
        private readonly ISHomeService _homeService;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="homeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public FinanceController(ISHomeService homeService, 
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _homeService = homeService;
        }

        #region App Home   
        
        /// <summary>
        /// Get Wallet - ví điểm
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<Wallet> GetWallet()
        {
            var result = _homeService.GetWallet(this.UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetPointTransHistoryList - lịch sử tiêu điểm, tích điểm
        /// </summary>
        /// <param name="filterType"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public ResponseList<List<WalPointTran>> GetPointTransHistoryList([FromQuery] string filterType
            , [FromQuery] int offSet, [FromQuery] int pageSize)
        {
            var flt = new FilterBase(this.ClientId, this.UserId, offSet, pageSize, filterType);
            var result = _homeService.GetPointTransHistoryList(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        /// <summary>
        /// GetPointTransDetail - chi tiết giao dịch điểm
        /// </summary>
        /// <param name="transNo"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<WalPointTran> GetPointTransDetail([FromQuery] string transNo)
        {
            var result = _homeService.GetPointTransDetail(this.UserId, transNo);
            return GetResponse(ApiResult.Success, result);
        }
        #endregion


    }
}

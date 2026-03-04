using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model;
using System;
using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using System.Collections.Generic;

namespace UNI.Resident.API.Controllers.Version2.ServiceFee
{

    /// <summary>
    /// Card Controller
    /// </summary>
    /// Author: hoanpv
    /// <seealso cref="UniController" />
    [Route("api/v2/receipt/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ReceiptController : UniController
    {
        #region instance-reg
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IReceiptService _receiptService;
        private readonly IUserService _userService;
        //private readonly ISHomeService _homeService;
        //private readonly IAppManagerService _appService;
        //private readonly ICustomerService _custService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ReceiptController"/> class.
        /// </summary>
        /// <param name="receiptService"></param>
        /// <param name="userService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public ReceiptController(
            IReceiptService receiptService,
            IUserService userService,
            //ISHomeService homeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _receiptService = receiptService;
            _userService = userService;
            _mapper = mapper;
            //_homeService = homeService;
        }
        #endregion instance-reg

        public BaseResponse<CommonViewInfo> GetReceiptFilter()
        {
            var result = _receiptService.GetReceiptFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Receipt Page
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetReceiptPagev2(
            [FromQuery] string projectCd, [FromQuery] int isExpected, [FromQuery] int isResident,
            [FromQuery] bool isDateFilter, [FromQuery] string fromDate, [FromQuery] string toDate,
            [FromQuery] string filter,
            [FromQuery] Guid periodsOid,
            [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            try
            {
                if (projectCd == null)
                    projectCd = await _userService.GetUserProject(UserId);

                var flt = new ReceiptRequestModel(ClientId, UserId, offSet, pageSize, filter, projectCd, isExpected, isResident, isDateFilter, fromDate, toDate)
                {
                    PeriodsOid = periodsOid
                };

                var result = await _receiptService.GetReceiptPagev2(flt);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }

        }

        /// <summary>
        /// GetReceiptInfo - Xem chi tiết biên nhận
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ReceiptInfo>> GetReceiptInfo([FromQuery] int ReceiptId)
        {

            try
            {
                var rs = await _receiptService.GetReceiptInfo(ReceiptId.ToString());
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ReceiptInfo>(ApiResult.Error, e.Message);
                return rp;
            }

        }
        [HttpGet]
        public async Task<IActionResult> GetBillReceipt([Required] long receiptId)
        {
            string rs = await _receiptService.GetBillReceiptAsync(receiptId);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="info">Trường @RoomCd bắt buộc truyền vào khi call api</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<long>> SetReceiptInfo([FromBody] ReceiptInfo info)
        {
            try
            {
                var rs = await _receiptService.SetReceiptInfo(CtrlClient, info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, rs.regId, rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, 0L, e.Message);
            }
        }

        /// <summary>
        /// DeleteCardAsync - Xóa thẻ căn hộ 
        /// </summary>
        /// <param name="ReceiptId"> mã thẻ</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DeleteReceiptInfo(int ReceiptId)
        {
            try
            {
                var rs = await _receiptService.DeleteReceiptInfo(ReceiptId);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }
        /// <summary>
        /// Lịch sử giao dịch theo căn hộ
        /// </summary>
        /// <param name="aparmentId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetReceiptByApartmentIdPage([FromQuery] ReceiptHistoryByApartmentIdModel query)
        {
            try
            {
                var result = await _receiptService.GetReceiptByApartmentIdPage(query);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }

        }
        /// <summary>
        /// GetReceiptByApartmentId - Xem chi tiết biên nhận theo apartmentId
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ReceiptInfo>> GetReceiptByApartmentId([FromQuery] int ApartmentId)
        {

            try
            {
                var rs = await _receiptService.GetReceiptByApartmentInfo(ApartmentId);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ReceiptInfo>(ApiResult.Error, e.Message);
                return rp;
            }

        }
        /// <summary>
        /// SetReceipt - Chuyển nợ hàng loạt
        /// </summary>
        /// <param name="receipt"></param>
        /// <returns></returns>
        public async Task<BaseResponse<HomReceiptGet>> SetReceipt([FromBody] HomReceiptSet receipt)
        {
            var result = await _receiptService.SetReceipt(receipt);
            if (result != null)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetResponse<HomReceiptGet>(ApiResult.Fail, null);
            }
        }

        /// <summary>
        /// GetPaymentAmountOptions - lấy các lựa chọn số tiền thanh toán
        /// </summary>
        /// <param name="ReceiveId">mã hóa đơn</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetPaymentAmountOptions([FromQuery] string ReceiveId)
        {
            var result = await _receiptService.GetPaymentAmountOptions(ReceiveId);
            return GetResponse(ApiResult.Success, result);
        }
    }
}


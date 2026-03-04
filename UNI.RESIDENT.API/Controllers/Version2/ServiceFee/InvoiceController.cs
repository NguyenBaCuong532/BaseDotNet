using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.Model.Receipt;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using UNI.Resident.Model.Resident;
using System;
using UNI.Resident.Model.Invoice;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.Model.Common;

namespace UNI.Resident.API.Controllers.Version2.ServiceFee
{
    [Route("api/v2/Invoice/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    [ApiController]
    public class InvoiceController : UniController
    {
        private readonly IInvoiceService _invoiceService;

        public InvoiceController(IInvoiceService invoiceService)
        {
            _invoiceService = invoiceService;
        }
        /// <summary>
        /// Gửi thông báo
        /// </summary>
        /// <param name="receipts"></param>
        /// <param name="projectcode"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> PushNotify([FromBody] ReceiptsBase receipts, [FromHeader] string projectcode)
        {
            BaseValidate rs = await _invoiceService.PushNotifyAsync(receipts, projectcode);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// Gửi thông báo nhắc nợ
        /// </summary>
        /// <param name="receipts"></param>
        /// <param name="projectcode"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> PushRemindNotify([FromBody] ReceiptsBase receipts, [FromHeader] string projectcode)
        {
            BaseValidate rs = await _invoiceService.PushRemindNotifyAsync(receipts, projectcode);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <remarks>
        /// <param name="type"> confirm(xác nhận và tạo phếu thu)/transfer(chuyển nợ)</param>
        /// <returns></returns>
        [HttpGet("{type}")]
        public async Task<IActionResult> GetInfo(string type, long? id, decimal? remainamt)
        {
            CommonViewInfo rs = await _invoiceService.GetInfoAsync(type, id, remainamt);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <remarks>
        /// <param name="type"> confirm(xác nhận và tạo phếu thu) xử lý form</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> GetInfoDraft([FromBody] CommonViewInfo form)
        {
            CommonViewInfo rs = await _invoiceService.GetInfoDraftoAsync(form);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// Tạo hoá đơn hàng loạt
        /// </summary>
        /// <param name="receipts"></param>
        /// <param name="receiveIds"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> CreateInvoices([FromBody] ReceiptsBase receipts)
        {
            BaseValidate rs = await _invoiceService.CreateInvoicesAsync(receipts);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }

        /// <summary>
        /// Hủy hóa đơn
        /// </summary>
        /// <param name="ReceiptId"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<IActionResult> Delete([FromQuery] long ReceiptId)
        {
            var rs = await _invoiceService.DeleteAsync(ReceiptId);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }

        /// <summary>
        /// Hủy hóa đơn
        /// </summary>
        /// <param name="delIds"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> DeleteMulti([FromBody] CommonDeleteMulti delIds)
        {
            var rs = await _invoiceService.DeleteMultiAsync(delIds);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return Ok(rp);
        }
        /// <summary>
        /// Lịch sử hóa đơn theo căn hộ
        /// </summary>
        /// <param name="aparmentId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetInvoiceHistoryByApartmentIdPage([FromQuery] InvoiceRequestModel query)
        {
            try
            {
                var result = await _invoiceService.GetInvoiceHistoryByApartmentIdPage(query);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }

        }
    }
}

using DocumentFormat.OpenXml.Office2016.Drawing.ChartDrawing;
using Google.Api.Gax.ResourceNames;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.BLL.BusinessService.Invoice;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Billing
{
    /// <summary>
    /// Kỳ thanh toán - Hóa đơn
    /// </summary>
    [Route("api/v2/BillingInvoices/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class BillingInvoicesController : UniController
    {
        private readonly IBillingInvoicesService _service;
        private readonly IFeeServiceService _feeServiceService;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="service"></param>
        /// <param name="feeServiceService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public BillingInvoicesController(IBillingInvoicesService service,
            IFeeServiceService feeServiceService,
            IOptions<AppSettings> appSettings, ILoggerFactory logger) : base(appSettings, logger)
        {
            _service = service;
            _feeServiceService = feeServiceService;
        }

        ///// <summary>
        ///// Control tìm kiếm nâng cao danh sách phân trang
        ///// </summary>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<CommonViewInfo>> GetBillingInvoicesFilter()
        //{
        //    try
        //    {
        //        var result = await _service.GetBillingInvoicesFilter();
        //        return GetResponse(ApiResult.Success, result);
        //    }
        //    catch (Exception ex)
        //    {
        //        return GetResponse(ApiResult.Error, new CommonViewInfo(), ex.Message);
        //    }
        //}

        ///// <summary>
        ///// Danh sách dữ liệu phân trang hiển thị ở lưới
        ///// </summary>
        ///// <param name="inputFilter"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public async Task<BaseResponse<CommonDataPage>> GetBillingInvoicesPage([FromQuery] FilterBase inputFilter)
        //{
        //    try
        //    {
        //        var result = await _service.GetBillingInvoicesPage(inputFilter);
        //        return GetResponse(ApiResult.Success, result);
        //    }
        //    catch (Exception ex)
        //    {
        //        return GetResponse(ApiResult.Error, new CommonDataPage(), ex.Message);
        //    }
        //}

        ///// <summary>
        ///// Lưu thông tin Thêm/Sửa bản ghi
        ///// </summary>
        ///// <param name="inputData"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<BaseValidate>> SetBillingInvoices([FromBody] CommonViewInfo inputData)
        //{
        //    try
        //    {
        //        var result = await _service.SetBillingInvoices(inputData);
        //        return GetResponse(result.valid ? ApiResult.Success : ApiResult.Error, result, result.messages);
        //    }
        //    catch (Exception ex)
        //    {
        //        return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
        //    }
        //}

        ///// <summary>
        ///// Xóa một bản ghi
        ///// </summary>
        ///// <param name="oid"></param>
        ///// <returns></returns>
        //[HttpDelete]
        //public async Task<BaseResponse<BaseValidate>> SetBillingInvoicesDelete([FromQuery] Guid oid)
        //{
        //    try
        //    {
        //        var data = await _service.SetBillingInvoicesDelete(new List<Guid> { oid });
        //        return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
        //    }
        //    catch (Exception ex)
        //    {
        //        return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
        //    }
        //}

        ///// <summary>
        ///// Xóa nhiều bản ghi
        ///// </summary>
        ///// <param name="arrOid"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<BaseValidate>> SetBillingInvoicesDeletes([FromBody] List<Guid> arrOid)
        //{
        //    try
        //    {
        //        var data = await _service.SetBillingInvoicesDelete(arrOid);
        //        return GetResponse(data.valid ? ApiResult.Success : ApiResult.Error, data, data.messages);
        //    }
        //    catch (Exception ex)
        //    {
        //        return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
        //    }
        //}

        /// <summary>
        /// Form tạo hóa đơn hàng loại
        /// </summary>
        /// <param name="periodsOid"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBillingInvoicesFields(Guid periodsOid)
        {
            try
            {
                var res = await _service.GetBillingInvoicesFields(periodsOid);
                return GetResponse(ApiResult.Success, res);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonViewInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Lưu nháp tạo hoá đơn hàng loạt
        /// </summary>
        /// <param name="receipts"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<CommonViewInfo>> SetBillingInvoicesFieldsDraft([FromBody] ReceiptsBaseViewInfo receipts)
        {
            try
            {
                var res = await _service.GetBillingInvoicesFields(Guid.Empty, receipts);
                return GetResponse(ApiResult.Success, res);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new CommonViewInfo(), ex.Message);
            }
        }

        /// <summary>
        /// Tạo hoá đơn hàng loạt
        /// </summary>
        /// <param name="receipts"></param> 
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingInvoicesFields([FromBody] ReceiptsBaseViewInfo receipts)
        {
            try
            {
                var rs = await _service.SetBillingInvoicesFields(receipts);
                return GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, rs, rs.messages);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Chuyển nợ hàng loạt
        /// </summary>
        /// <param name="receipt"></param>
        /// <returns></returns>
        public async Task<BaseResponse<HomReceiptGet>> SetBillingInvoicesReceipt([FromBody] HomReceiptSet receipt)
        {
            try
            {
                var result = await _service.SetBillingInvoicesReceipt(receipt);
                if (result != null)
                    return GetResponse(ApiResult.Success, result);
                else
                    return GetResponse<HomReceiptGet>(ApiResult.Fail, null);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new HomReceiptGet(), ex.Message);
            }
        }

        /// <summary>
        /// Hủy từng hóa đơn
        /// </summary>
        /// <param name="receiptId"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<BaseValidate>> SetBillingInvoicesDelete([FromQuery] int receiptId)
        {
            try
            {
                var delIds = new Model.Common.CommonDeleteMulti { Ids = new List<int?> { receiptId } };
                var result = await _service.SetBillingInvoicesDelete(delIds);
                var apiResult = result == null || !result.valid ? ApiResult.Error : ApiResult.Success;
                return GetResponse<BaseValidate>(apiResult, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Hủy hóa đơn
        /// </summary>
        /// <param name="delIds"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetBillingInvoicesDeletes([FromBody] Model.Common.CommonDeleteMulti delIds)
        {
            try
            {
                var result = await _service.SetBillingInvoicesDelete(delIds);

                var apiResult = result == null || !result.valid ? ApiResult.Error : ApiResult.Success;
                return GetResponse<BaseValidate>(apiResult, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new BaseValidate(), ex.Message);
            }
        }

        /// <summary>
        /// Tạo hóa đơn từng căn hộ
        /// </summary>
        /// <param name="bill"> Thông tin hóa đơn</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBillingInvoicesBill([FromBody] ServiceReceivableBill bill)
        {
            try
            {
                bill.RunNewVersion = true;
                var result = bill.RunNewVersion
                    ? await _feeServiceService.SetServiceReceivableBillNew(bill)
                    : await _feeServiceService.SetServiceReceivableBill(bill);

                var apiResult = string.IsNullOrEmpty(result) ? ApiResult.Error : ApiResult.Success;
                if (apiResult == ApiResult.Error)
                    result = "Chưa tạo được hóa đơn";

                return GetResponse(apiResult, result, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, "", ex.Message);
            }
        }
    }
}
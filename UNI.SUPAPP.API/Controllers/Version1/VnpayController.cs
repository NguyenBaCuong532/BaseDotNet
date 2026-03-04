using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using SSG.BLL.BusinessService.HelperService;
using SSG.BLL.BusinessServiceInterfaces;
using SSG.Common;
using SSG.Model;
using SSG.Model.Api;
using SSG.Model.SRE.SHousing;
using SSG.Model.SunshineTV;
using SSG.Model.Vnpay;
using SSG.Utils;
using System;
using System.Threading.Tasks;

namespace SSG.SupApp.API.Controllers.Version1
{
    /// <summary>
    ///     Thanh toán VNPAY
    /// </summary>
    [Route("api/v1/vnpay/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class VnpayController : SSGController
    {
        //private readonly ISHousingService _housingService;
        //private readonly IInvestmentService _investService;
        private readonly ISunshineTVService _sunshineTVService;
        private readonly IVnpayService _vnpayService;

        /// <summary>
        /// </summary>
        /// <param name="housingService"></param>
        /// <param name="investService"></param>
        /// <param name="vnpayService"></param>
        /// <param name="appSetting"></param>
        /// <param name="logger"></param>
        public VnpayController(
            //ISHousingService housingService,
            //IInvestmentService investService,
            IVnpayService vnpayService,
            ISunshineTVService sunshineTVService,
            IOptions<AppSettings> appSetting,
            ILoggerFactory logger) : base(appSetting, logger)
        {
            //_housingService = housingService;
            //_investService = investService;
            _vnpayService = vnpayService;
            _sunshineTVService = sunshineTVService;
        }

        ///// <summary>
        /////     Tạo mã QR thanh toán
        ///// </summary>
        ///// <remarks>
        /////     Yêu cầu:
        ///// 
        /////         id: Id (*)
        /////         amount: Số tiền (*)
        /////         separate: [1 - Booking, Selling, 2 - Investment] (*)
        /////         transType: [1 - Invest, 2 - Transfer]
        ///// 
        /////     Phản hồi:
        ///// 
        /////         qrCode: Mã QR
        /////         transId: Id của giao dịch thanh toán
        /////         expireDate: Ngày hết hạn của thanh toán
        ///// 
        ///// </remarks>
        ///// <param name="req"></param>
        ///// <returns></returns>
        //[HttpPost]
        //public async Task<BaseResponse<SreVnpayCreateRes>> CreateQR([FromBody] SreVnpayCreateReq req)
        //{
        //    try
        //    {
        //        var result = GetResponse<SreVnpayCreateRes>(ApiResult.Invalid);

        //        if (!ModelState.IsValid)
        //        {
        //            result.AddErrors(Errors);
        //            return result;
        //        }

        //        var data = new SreVnpayCreateRes();
        //        var request = new VnpayReq();
        //        if (req.Separate == 1)
        //        {
        //            var booking = _housingService.GetRoomBooking(UserId, req.Id ?? 0);
        //            if (booking == null)
        //            {
        //                result.AddError("BookingId không hợp lệ!");
        //                return result;
        //            }

        //            var paymentSet = new SreBookingPaymentSet
        //            {
        //                BookingId = req.Id ?? 0,
        //                Amount = req.Amount ?? 0,
        //                TransType = "VNPAY",
        //                PaymentStatus = 0
        //            };

        //            var payment = _housingService.SetBookingPayment(UserId, paymentSet);
        //            if (payment == null)
        //            {
        //                result.AddError("Lỗi thêm mới giao dịch booking!");
        //                return result;
        //            }

        //            var tran = new SreVnpayTransaction
        //            {
        //                Id = payment.Id,
        //                Separate = req.Separate
        //            };

        //            request.TxnId = SecurityHelper.ToBase64Encode(tran);
        //            request.Amount = $"{Math.Round(payment.paymentAmt)}";
        //            request.ExpDate = payment.ExpireDate.HasValue
        //                ? payment.ExpireDate.Value.ToString("yyMMddHHmm")
        //                : "";
        //            request.TerminalId = VnpayConfig.TerminalId1;

        //            data.TransId = payment.Id;
        //            data.ExpireDate = payment.ExpireDate;
        //        }

        //        var response = await _vnpayService.CreateQR(request);
        //        if (response.Code != "00")
        //        {
        //            result.AddError(response.Message);
        //            return result;
        //        }

        //        data.QrCode = response.Data;

        //        result = GetResponse(ApiResult.Success, data);

        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError($"{ex}");
        //        throw;
        //    }
        //}

        ///// <summary>
        /////     Cập nhật trạng thái thanh toán QR
        ///// </summary>
        ///// <remarks>
        /////     Yêu cầu:
        ///// 
        /////         {
        /////             "code": "00",
        /////             "message": "tru tien thanh cong",
        /////             "msgType": "1",
        /////             "txnId": "eyJJZCI6NDksIlR5cGUiOjF9",
        /////             "qrTrace": "000180534",
        /////             "bankCode": "AGRIBANK",
        /////             "mobile": "0979382928",
        /////             "accountNo": "",
        /////             "amount": "26000",
        /////             "payDate": "20200221171101",
        /////             "masterMerCode": "A000000775",
        /////             "merchantCode": "0107432651",
        /////             "terminalId": "SUN0001",
        /////             "addData":
        /////             [ {
        /////                 "merchantType": "6513",
        /////                 "serviceCode": "06",
        /////                 "masterMerCode": "A000000775",
        /////                 "merchantCode": "0107432651",
        /////                 "terminalId": "SUN0001",
        /////                 "productId": "",
        /////                 "amount": "26000",
        /////                 "ccy": "704",
        /////                 "qty": "1",
        /////                 "note": "" } ],
        /////                 "checksum": "42D875ACD8A27900BDADBF3137C473DA",
        /////                 "ccy": "704",
        /////                 "address": "",
        /////                 "secretKey": "VNPAY"
        /////             }]
        /////         }
        ///// 
        /////     Phản hồi:
        ///// 
        ///// </remarks>
        ///// <param name="req"></param>
        ///// <returns></returns>
        //[HttpPost]
        //[AllowAnonymous]
        //public async Task<SreVnpayCallBackRes> CallBack([FromBody] SreVnpayCallBackReq req)
        //{
        //    try
        //    {
        //        _logger.LogInformation("Params: {req}", JsonConvert.SerializeObject(req));

        //        var result = new SreVnpayCallBackRes
        //        {
        //            Code = "00",
        //            Message = "Đặt hàng thành công"
        //        };

        //        if (!ModelState.IsValid)
        //        {
        //            _logger.LogError("Lỗi valid: {errors}", $"{Errors}");

        //            result.Code = "08";
        //            result.Message = $"{Errors}";

        //            return result;
        //        }

        //        var checksumKey = req.Code + "|" + req.MsgType + "|" + req.TxnId + "|"
        //                          + req.QrTrace + "|" + req.BankCode + "|" + req.Mobile
        //                          + "|" + req.AccountNo + "|" + req.Amount + "|"
        //                          + req.PayDate + "|" + req.MerchantCode + "|" +
        //                          VnpayConfig.SecretKeyPaymentQR;

        //        if (!SecurityHelper.VerifyMd5Hash(checksumKey, req.Checksum))
        //        {
        //            _logger.LogError("Checksum Valid: {checksum}", SecurityHelper.GetMd5Hash(checksumKey));

        //            result.Code = "08";
        //            result.Message = "Checksum không hợp lệ";

        //            return result;
        //        }

        //        var vnpayTran = SecurityHelper.ToBase64Decode<SreVnpayTransaction>(req.TxnId);
        //        if (vnpayTran == null)
        //        {
        //            _logger.LogError("Lỗi decode: {txnId}", req.TxnId);

        //            result.Code = "08";
        //            result.Message = $"Lỗi decode: {req.TxnId}!";

        //            return result;
        //        }

        //        if (vnpayTran.Separate == 1)
        //        {
        //            var callBack = new SreBookingPaymentCallBack
        //            {
        //                Id = vnpayTran.Id ?? 0,
        //                StatusId = 1
        //            };

        //            var payment = _housingService.SetBookingPaymentCallBack(this.UserId, callBack);
        //            if (payment == null)
        //            {
        //                _logger.LogError("Lỗi cập nhật trạng thái thanh toán với BookingId: {Id}", vnpayTran.Id);

        //                result.Code = "08";
        //                result.Message =
        //                    $"Lỗi cập nhật trạng thái thanh toán với BookingId: {vnpayTran.Id}";

        //                return result;
        //            }

        //            //_ = _housingService.SendNotify(new HouNotifyParam
        //            //{
        //            //    tpl_no = TemplateNo.Hou001,
        //            //    user_id = this.UserId,
        //            //    trans_id = vnpayTran.Id ?? 0
        //            //});

        //            //_ = _housingService.SendNotify(new HouNotifyParam
        //            //{
        //            //    tpl_no = TemplateNo.Hou002,
        //            //    user_id = this.UserId,
        //            //    trans_id = vnpayTran.Id ?? 0
        //            //});
        //        }

        //        if (vnpayTran.Separate == 2)
        //        {
        //            //var callBack = new SreBookingPaymentCallBack
        //            //{
        //            //    Id = vnpayTran.Id ?? 0,
        //            //    StatusId = 1
        //            //};

        //            //var isSuccess = await _investService.SetTransactionCallback(this.UserId, callBack);
        //            //if (!isSuccess)
        //            //{
        //            //    _logger.LogError("Lỗi cập nhật trạng thái giao dịch với trans_id: {Id}", vnpayTran.Id);

        //            //    result.Code = "08";
        //            //    result.Message = $"Lỗi cập nhật trạng thái giao dịch với trans_id: {vnpayTran.Id}";

        //            //    return result;
        //            //}

        //            //_ = _investService.SendNotify(new InvNotifyParam
        //            //{
        //            //    tpl_no = TemplateNo.Inv002,
        //            //    user_id = this.UserId,
        //            //    trans_id = vnpayTran.Id??0
        //            //});

        //            //_ = _investService.SendNotify(new InvNotifyParam
        //            //{
        //            //    tpl_no = TemplateNo.Inv003,
        //            //    user_id = this.UserId,
        //            //    trans_id = vnpayTran.Id??0
        //            //});
        //        }
        //        if (vnpayTran.Separate == 3)
        //        {
        //            var callBack = new transaction_payment_callback
        //            {
        //                trans_id = vnpayTran.Id ?? 0,
        //                //trans_id = 5260
        //                trans_st = 1
        //            };

        //            var res = await _sunshineTVService.SetTransactionCallback(this.UserId, callBack);
        //            if (!res.valid)
        //            {
        //                _logger.LogError("Lỗi cập nhật trạng thái giao dịch với trans_id: {Id}", vnpayTran.Id);
        //                result.Code = "08";
        //                result.Message = $"Lỗi cập nhật trạng thái giao dịch với trans_id: {vnpayTran.Id}";

        //                return result;
        //            }
        //            else
        //            {
        //                    var cus = await _sunshineTVService.GetCustomerInfoSyncByTransId(this.UserId, callBack.trans_id);
        //                    var _qnetService = new QNetService();
        //                    var sysu = await _qnetService.SyncCustomer(cus.customer_info.operatorId,
        //                                           cus.customer_info.userId,
        //                                           cus.customer_info.phoneNumber,
        //                                           cus.customer_info.planId,
        //                                           cus.customer_info.planType,
        //                                           cus.customer_info.planAmount,
        //                                           cus.customer_info.isPromotion,
        //                                           cus.customer_info.promotionName,
        //                                           cus.customer_info.promotionValue,
        //                                           cus.customer_info.createdAt,
        //                                           cus.customer_info.expiredAt,
        //                                           cus.customer_info.signature,
        //                                           "production"
        //                                           );
                        
        //                    if (sysu.Value.ec == 0)
        //                    {
        //                        await _sunshineTVService.UpdateTransactionSyncedQnet(cus.customer_info.transactionId);
        //                        var tsu = await _qnetService.SyncTransactionCustomer(cus.customer_info.operatorId,
        //                                                   cus.customer_info.userId,
        //                                                   cus.customer_info.transactionId,
        //                                                   cus.customer_info.planId,
        //                                                   cus.customer_info.planType,
        //                                                   cus.customer_info.planValue,
        //                                                   cus.customer_info.planAmount,
        //                                                   cus.customer_info.planExtra,
        //                                                   cus.customer_info.planDesc,
        //                                                   cus.customer_info.isPromotion,
        //                                                   cus.customer_info.promotionName,
        //                                                   cus.customer_info.promotionValue,
        //                                                   cus.customer_info.createdAt,
        //                                                   cus.customer_info.signature,
        //                                                   cus.customer_info.signaturetmp,
        //                                                   "production",
        //                                                   cus.customer_info.phoneNumber,
        //                                                   cus.customer_info.expiredAt
        //                                                   );
        //                        if (tsu.Value.ec == 0)
        //                            await _sunshineTVService.UpdateCustomerSyncedQnet(this.UserId);
        //                    }
                        
        //            }

        //            //_ = _investService.SendNotify(new InvNotifyParam
        //            //{
        //            //    tpl_no = TemplateNo.Sstv001,
        //            //    user_id = this.UserId,
        //            //    trans_id = vnpayTran.Id ?? 0
        //            //});

        //            //_ = _investService.SendNotify(new InvNotifyParam
        //            //{
        //            //    tpl_no = TemplateNo.Sstv001,
        //            //    user_id = this.UserId,
        //            //    trans_id = vnpayTran.Id ?? 0
        //            //});
        //        }

        //        _logger.LogInformation("Transaction: {tran}", JsonConvert.SerializeObject(vnpayTran));

        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError($"{ex}");
        //        throw;
        //    }
        //}

    }
}
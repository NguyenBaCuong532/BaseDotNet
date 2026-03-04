using SSG.Resident.BLL.BusinessInterfaces;
using SSG.Resident.DAL.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.CRM;
using UNI.Model.SPay;
using UNI.Utils;

namespace SSG.Resident.BLL.BusinessService
{
    /// <summary>
    /// Class SPay Service.
    /// <author>Thien TH</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public class SPayService : ISPayService
    {
        private readonly ISPayRepository _spayRepository;
        public SPayService(
            ISPayRepository payRepository
            )
        {
            _spayRepository = payRepository;
        }
        public WalletHome GetWalletHome(string userId)
        {
            return _spayRepository.GetWalletHome(userId);
        }
        public Wallet GetWallet(string userId)
        {
            return _spayRepository.GetWallet(userId);
        }
        public RechargeSource GetRechargeSource(string userId)
        {
            return _spayRepository.GetRechargeSource(userId);
        }
        public RechargePage GetRechargePage(string userId)
        {
            return _spayRepository.GetRechargePage(userId);
        }
        public WalCardInfo GetCardInfo(string cardNum, string posCd)
        {
            return _spayRepository.GetCardInfo(cardNum, posCd);
        }
        public List<WalBank> GetBanksByType(string userId, int isInternal)
        {
            return _spayRepository.GetBanksByType(userId, isInternal);
        }
        public ResponseList<List<WalBank>> GetBankList(string userId, FilterBase filter)
        {
            return _spayRepository.GetBankList(userId, filter);
        }
        public PayToken GetPaymentLimit(string userId)
        {
            return _spayRepository.GetPaymentLimit(userId);
        }
        public List<decimal> GetAmountLimitList(string userId)
        {
            return _spayRepository.GetAmountLimitList(userId);
        }
        public List<decimal> GetPhoneCardValues(string userId)
        {
            return _spayRepository.GetPhoneCardValues(userId);
        }
        public List<decimal> GetRecentAmountList(string userId)
        {
            return _spayRepository.GetRecentAmountList(userId);
        }
        public Task SetChangePayLimit(string userId, ChangePayLimit limit)
        {
            return _spayRepository.SetChangePayLimit(userId, limit);
        }
        public ResponseList<List<PayTransHistory>> GetPayHistoryList(FilterBase filter)
        {
            return _spayRepository.GetPayHistoryList(filter);
        }
        public PayTransDetail GetPayTransDetail(string userId, string transNo)
        {
            return _spayRepository.GetPayTransDetail(userId, transNo);
        }

        //public TransactionRespone SetWalletRecharge(BaseCtrlClient client, WalRechargeBase rec)
        //{
        //    var tran = _spayRepository.SetWalletRecharge(client, rec);
        //    if (tran.TranferCd == "BANKLINK")
        //    {
        //        return new TransactionRespone { status = "Success" };
        //    }
        //    else //if (tran.TranferCd == "INT" || tran.TranferCd == "ATM")
        //    {
        //        var recharv = this.GetRechargeView(client.UserId, rec);
        //        var napTran = tran.NapTranBuild(client.UserId, recharv.TotalAmount, recharv.LinkedID);
        //        var napRes = _spayRepository.SetNapTransaction(napTran);
        //        return new TransactionRespone { ReturnUrl = client.hostUrl + 
        //            string.Format("/napas/GetNapasPayUrl?userId={0}&clientIp={1}&orderId={2}&amount={3}&cardScheme={4}&transactionType={5}&secureHash={6}",
        //            napTran.userId, napTran.clientIp, napTran.orderId, napTran.amount, napTran.cardType, napTran.transactionType,
        //            napTran.getHash(napRes.TxnNo)), WalTxnId = tran.WalTxnId };
        //    }

        //}

        //public TransactionRespone SetWalletRechargeNow(BaseCtrlClient client, WalRechargeNow recharge)
        //{
        //    var tran = _spayRepository.SetWalletRecharge(client, rec);
        //    if (recharge.TranferCd == "INT" || recharge.TranferCd == "ATM")
        //    {
        //        var recharv = this.GetRechargeView(client.UserId, recharge);
        //        var napTran = tran.NapTranBuild(client.UserId, recharv.TotalAmount, recharv.LinkedID);
        //        var napRes = _spayRepository.SetNapTransaction(napTran);
        //        return new TransactionRespone
        //        {
        //            ReturnUrl = client.hostUrl +
        //            string.Format("/napas/GetNapasPayUrl?userId={0}&clientIp={1}&orderId={2}&amount={3}&cardScheme={4}&transactionType={5}&secureHash={6}",
        //            napTran.userId, napTran.clientIp, napTran.orderId, napTran.amount, napTran.cardType, napTran.transactionType,
        //            napTran.getHash(napRes.TxnNo))
        //        };
        //    }
        //}
        public async Task<TransactionRespone> SetWalletPayment(BaseCtrlClient client, WalPayment payment)
        {
            var wall = GetWallet(client.UserId);
            if (payment.PaymentType.ToUpper() == "SPoint".ToUpper())
            {
                if (wall.CurrentPoint >= payment.Amount)
                {
                    var id = await SetSPointToOrder(client, payment.GetCardOrder(wall.CustId));
                    return new TransactionRespone { status = "Success", WalTxnId = id };
                }
                else
                {
                    return new TransactionRespone { status = "Error", error = "The Point is't enough" };
                }
            }
            else if (payment.PaymentType.ToUpper() == "SPay".ToUpper())
            {
                if (wall.CurrentAmount >= payment.Amount)
                {
                    var tranRes = _spayRepository.SetWalletPayment(client, payment);
                    await _spayRepository.SetWalTransactionPayed(new TransactionPayed { RefNo = tranRes.RefNo, ResponseCode = 0 });
                    var pos = _spayRepository.GetPosCallback(payment.PosCd);
                    if (pos.callbackUrl != null && pos.callbackChecksumSecret != null)
                    {
                        var callback = new HelperService.PayCallbackService();
                        callback.SetPayCallback(payment.PayCallback(pos.callbackChecksumSecret), pos.callbackUrl);
                    }
                    return new TransactionRespone { status = "Success", WalTxnId = tranRes.WalTxnId };
                }
                //else
                //{
                //    var tranRes = _spayRepository.SetWalletPayment(client, payment);
                //    var rec = new WalRechargeBase { TranferCd = payment.TranferCd, Amount = payment.Amount };
                //    var tran = _spayRepository.SetWalletRecharge(client, rec, tranRes.WalTxnId);

                //    var recharv = this.GetRechargeView(client.UserId, rec);
                //    var napTran = tran.NapTranBuild(client.UserId, recharv.TotalAmount, recharv.LinkedID);
                //    var napRes = _spayRepository.SetNapTransaction(client, napTran);
                //    return new TransactionRespone
                //    {
                //        ReturnUrl = client.hostUrl +
                //        string.Format("/napas/GetNapasPayUrl?userId={0}&clientIp={1}&orderId={2}&amount={3}&cardScheme={4}&transactionType={5}&secureHash={6}",
                //        napTran.userId, napTran.clientIp, napTran.orderId, napTran.amount, napTran.cardType, napTran.transactionType,
                //        napTran.getHash(napRes.TxnNo)), WalTxnId = tranRes.WalTxnId,
                //        status = "Success"
                //    };
                //}
                return new TransactionRespone { status = "Error", error = "Payment Type invalid" };
            }
            else
            {
                return new TransactionRespone { status = "Error", error = "Payment Type invalid" };
            }

        }
        public Task SetBank(string userId, WalBank bank)
        {
            return _spayRepository.SetBank(userId, bank);
        }

        public List<WalTranfer> GetServiceRecharges(string userId)
        {
            return _spayRepository.GetServiceRecharges(userId);
        }
        public List<WalTranfer> GetServicePayments(string userId, bool isPayment)
        {
            return _spayRepository.GetServicePayments(userId, isPayment);
        }

        public Task<int> SetSCardToOrder(BaseCtrlClient client, CardOrder order)
        {
            return _spayRepository.SetSCardToOrder(client, order);
        }
        public Task<int> SetSPointToOrder(BaseCtrlClient client, CardOrder order)
        {
            return _spayRepository.SetSPointToOrder(client, order);
        }
        public TransactionRespone SetWalTransaction(string userId, string clientIp, WalTransactionSet tran)
        {
            TransactionRespone respone = new TransactionRespone();
            var restran = _spayRepository.SetWalTransaction(userId, tran);
            return respone;
        }
        public Task SetWalTransactionPayed(string userId, TransactionPayed tran)
        {
            return _spayRepository.SetWalTransactionPayed(tran);
        }
        //public LinkRespone SetTranferLink(BaseCtrlClient client, WalBankLinkReg link)
        //{
        //    var respone = new LinkRespone();
        //    respone.LinkedID = _spayRepository.SetTranferLink(client.UserId, link);
        //    if (link.TranferCd != "BANKLINK")
        //    {
        //        var rawStr = string.Join("", respone.LinkedID, client.UserId, client.ClientIp,link.cardScheme, NapasTransactionType.CREATE_TOKEN);
        //        respone.LinkUrl = client.hostUrl +
        //            string.Format("/napas/GetNapasLinkUrl?userId={0}&clientIp={1}&cardScheme={2}&transactionType={3}&secureHash={4}",
        //            client.UserId, client.ClientIp, link.cardScheme, Model.SPay.Napas.NapasTransactionType.CREATE_TOKEN,
        //            Utils.SecurityHelper.GetMd5Hash(rawStr));
        //    }
        //    return respone;
        //}
        public WalRechargeView GetRechargeView(string userId, WalRechargeBase recharge)
        {
            return _spayRepository.GetRechargeView(userId, recharge);
        }
        public Task SetWalActived(string phone)
        {
            return _spayRepository.SetWalActived(phone);
        }
        public ResponseList<List<WalletList>> GetWalletList(FilterBase filter)
        {
            return _spayRepository.GetWalletList(filter);
        }
        public ResponseList<List<WalProviderSet>> GetProviderList(FilterBase filter)
        {
            return _spayRepository.GetProviderList(filter);
        }
        public WalProviderSet GetProvider(string userId, int providerId)
        {
            return _spayRepository.GetProvider(userId, providerId);
        }

        public Task SetProvider(string userId, WalProviderSet provider)
        {
            return _spayRepository.SetProvider(userId, provider);
        }
        public ResponseList<List<PayTransactionGet>> GetPayTransactionList(FilterBase filter)
        {
            return _spayRepository.GetPayTransactionList(filter);
        }
        public ResponseList<List<ProviderTransactionGet>> GetProviderTransactionList(FilterBase filter)
        {
            return _spayRepository.GetProviderTransactionList(filter);
        }
        public ResponseList<List<BankLinkGet>> GetBankServiceLinks(string userId, FilterBase filter)
        {
            return _spayRepository.GetBankServiceLinks(userId, filter);
        }
        public Task SetBankServiceLink(string userId, BankLinkSet link)
        {
            return _spayRepository.SetBankServiceLink(userId, link);
        }
        public ResponseList<List<WalService>> GetServiceList(string userId, FilterBase filter)
        {
            return _spayRepository.GetServiceList(userId, filter);
        }
        public Task SetService(string userId, WalServiceSet service)
        {
            return _spayRepository.SetService(userId, service);
        }
        public Task SetLinkService(string userId, WalServiceLink link)
        {
            return _spayRepository.SetLinkService(userId, link);
        }
        public Task DeletePointOrder(BaseCtrlClient ctrlClient, string cardNum, string refNo)
        {
            return _spayRepository.DeletePointOrder(ctrlClient, cardNum, refNo);
        }
        public Task SetServicePOS(string userId, WalServicePOS pos)
        {
            return _spayRepository.SetServicePOS(userId, pos);
        }
        public WalServiceGet GetService(string userId, string serviceKey)
        {
            return _spayRepository.GetService(userId, serviceKey);
        }
        public IEnumerable<ServiceProvider> GetTelecomProviders(string userId)
        {
            return _spayRepository.GetTelecomProviders(userId);
        }
        public WalTelephoneCardRespone SetToBuyTelephoneCard(BaseCtrlClient client, WalTelephoneCardSet buyCards)
        {
            return _spayRepository.SetToBuyTelephoneCard(client, buyCards);
        }
        public Task DeleteRechargeLink(string userId, int linkedId)
        {
            return _spayRepository.DeleteRechargeLink(userId, linkedId);
        }
        public string GetAbout()
        {
            return _spayRepository.GetAbout();
        }
        //public List<Model.Cab.HelpView> GetHelpers()
        //{
        //    return _spayRepository.GetHelpers();
        //}
        public WalPromotion GetPromotion(string userId)
        {
            return _spayRepository.GetPromotion(userId);
        }
        public Task SetPincode(string userId, WalPincode pin)
        {
            return _spayRepository.SetPincode(userId, pin);
        }
        public bool SetVerifyPincode(string userId, WalPincode pin)
        {
            return _spayRepository.SetVerifyPincode(userId, pin);
        }
        public List<WalTransFilterType> GetTransFilterTypes(string userId)
        {
            return _spayRepository.GetTransFilterTypes(userId);
        }
        public async Task<TransactionRespone> SetPayToQrCode(BaseCtrlClient client, PayQrCode qrCode)
        {
            var payment = qrCode.GetPayment();
            var respone = await SetWalletPayment(client, payment);
            return respone;
        }
        public WalQrPayView SetPayViewQrCode(BaseCtrlClient client, PayQrCode qrCode)
        {
            return new WalQrPayView { Amount = qrCode.Amount, FeeRate = 0, Fee = 0, TotalAmount = qrCode.Amount };
        }
        public WalQrCode GetQrCode(string userId, string serviceKey)
        {
            //var result = storeSevice.SaveQrContent(code.QRCode);
            var result = _spayRepository.GetQrCode(userId, serviceKey);
            //result.QRCode = _storageService.SaveQrContent(result.QRCode);
            return result;
        }
        public WalletProfile GetWalletProfile(BaseCtrlClient userId, string phone)
        {
            return _spayRepository.GetWalletProfile(userId, phone);
        }
        public Task SetPhoneBooks(BaseCtrlClient client, ListOfPhoneBook books)
        {
            var wallets = _spayRepository.GetWalletList(new FilterBase(client.ClientId, client.UserId, 0, -1, null, 0)).Data;
            foreach (var w in wallets)
            {
                var sphone = SecurityHelper.GetMd5Hash(Utils.FormatPhoneNumber(w.Phone));
                var fphone = books.books.Where(p => p.phone == sphone).FirstOrDefault();
                if (fphone != null)
                {
                    fphone.isWallet = true;
                    fphone.walletCd = w.WalletCd;
                }
            }
            return _spayRepository.SetPhoneBooks(client, books);
        }
        public ResponseList<List<WalPhoneBookGet>> GetPhoneBooks(FilterBase filter)
        {
            return _spayRepository.GetPhoneBooks(filter);
        }
        public WalPaymentViewGet GetPaymentView(string userId, WalPaymentView pay)
        {
            return _spayRepository.GetPaymentView(userId, pay);
        }
        public List<WalBankLink> GetRechargeATMLinked(string userId)
        {
            return _spayRepository.GetRechargeATMLinked(userId);
        }
        public WalUserGrant SetPincodeRequest(string userId)
        {
            return _spayRepository.SetPincodeRequest(userId);
        }
        public WalPointTran SetWalRechargePoint(BaseCtrlClient client, WalRechargePointSet point)
        {
            return _spayRepository.SetWalRechargePoint(client, point);
        }
        public ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter)
        {
            return _spayRepository.GetPointTransHistoryList(filter);
        }
        public WalPointTran GetPointTransDetail(string userId, string transNo)
        {
            return _spayRepository.GetPointTransDetail(userId, transNo);
        }
        public List<WalServiceBase> GetPointServiceList(string userId, string filter)
        {
            return _spayRepository.GetPointServiceList(userId, filter);
        }
        public List<WalServicePOSBase> GetPointLocationList(string userId, string filter, string serviceKey)
        {
            return _spayRepository.GetPointLocationList(userId, filter, serviceKey);
        }
        //public crmLoyalPointPage GetPointListPage(PointTotalFilter filter)
        //{
        //    return _spayRepository.GetPointListPage(filter);
        //}
        //public crmLoyalPointCustPage GetPointCustomerPage(PointTransFilter filter)
        //{
        //    return _spayRepository.GetPointCustomerPage(filter);
        //}
        //public crmLoyalTransactionPage GetPointTransactionPage(PointTransFilter filter)
        //{
        //    return _spayRepository.GetPointTransactionPage(filter);
        //}
        //public crmLoyalVoucherPage GetPointVoucherPage(PointTransFilter filter)
        //{
        //    return _spayRepository.GetPointVoucherPage(filter);
        //}
        //public Task<BaseValidate> SetPointVoucher(BaseCtrlClient clt, WalPointVoucher voucher)
        //{
        //    return _spayRepository.SetPointVoucher(clt, voucher);
        //}
        //public Task SetPointVoucherExpPush(BaseCtrlClient clt, WalPointPush push)
        //{
        //    return _spayRepository.SetPointVoucherExpPush(clt, push);
        //}
        //public Task<BaseValidate> SetPointCancel(BaseCtrlClient clt, WalPointTranBase voucher)
        //{
        //    return _spayRepository.SetPointCancel(clt, voucher);
        //}
        //public Task<BaseValidate> SetPointWithdraw(BaseCtrlClient clt, WalPointTranWithdraw withdraw)
        //{
        //    return _spayRepository.SetPointWithdraw(clt, withdraw);
        //}
        //public Task<BaseValidate> DelPointTransaction(BaseCtrlClient clt, string ref_no)
        //{
        //    return _spayRepository.DelPointTransaction(clt, ref_no);
        //}
        //public WalApartmentInfo GetPointByCustInfo(string userId, string phone, string roomCode)
        //{
        //    return _spayRepository.GetPointByCustInfo(userId, phone, roomCode);
        //}
        //public List<WalPointTranType> GetPointTranTypeList(string userId, string filter)
        //{
        //    return _spayRepository.GetPointTranTypeList(userId, filter);
        //}
        //public WalCustInfo GetCustSearch(string search_key, string posCd)
        //{
        //    return _spayRepository.GetCustSearch(search_key, posCd);
        //}
    }

}

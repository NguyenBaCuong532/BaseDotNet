using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.CRM;
using UNI.Model.SPay;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SSG.Resident.BLL.BusinessInterfaces
{
    /// <summary>
    /// Interface ISPayService
    /// <author>Tai NT</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public interface ISPayService
    {
        WalletHome GetWalletHome(string userId);
        Wallet GetWallet(string userId);
        RechargeSource GetRechargeSource(string userId);
        RechargePage GetRechargePage(string userId);
        WalCardInfo GetCardInfo(string cardNum, string posCd);
        List<WalBank> GetBanksByType(string userId, int isInternal);
        ResponseList<List<WalBank>> GetBankList(string userId, FilterBase filter);
        PayToken GetPaymentLimit(string userId);
        List<decimal> GetAmountLimitList(string userId);
        List<decimal> GetPhoneCardValues(string userId);
        List<decimal> GetRecentAmountList(string userId);
        Task SetChangePayLimit(string userId, ChangePayLimit limit);
        ResponseList<List<PayTransHistory>> GetPayHistoryList(FilterBase filter);
        //TransactionRespone SetWalletRecharge(BaseCtrlClient client, WalRechargeBase recharge);
        Task<TransactionRespone> SetWalletPayment(BaseCtrlClient client, WalPayment payment);
        Task SetBank(string userId, WalBank bank);
        PayTransDetail GetPayTransDetail(string userId, string transNo);
        List<WalTranfer> GetServiceRecharges(string userId);
        List<WalTranfer> GetServicePayments(string userId, bool isPayment);
        Task<int> SetSCardToOrder(BaseCtrlClient client, CardOrder order);
        TransactionRespone SetWalTransaction(string userId, string clientIp, WalTransactionSet tran);
        Task SetWalTransactionPayed(string userId, TransactionPayed payment);
        //LinkRespone SetTranferLink(BaseCtrlClient client, WalBankLinkReg link);
        WalRechargeView GetRechargeView(string userId, WalRechargeBase recharge);
        //Task SetTranferLinked(string userId, WalLinked link);
        Task SetWalActived(string phone);
        ResponseList<List<WalletList>> GetWalletList(FilterBase filter);

        ResponseList<List<WalProviderSet>> GetProviderList(FilterBase filter);
        WalProviderSet GetProvider(string userId, int providerId);
        Task SetProvider(string userId, WalProviderSet provider);
        ResponseList<List<PayTransactionGet>> GetPayTransactionList(FilterBase filter);
        ResponseList<List<ProviderTransactionGet>> GetProviderTransactionList(FilterBase filter);
        ResponseList<List<BankLinkGet>> GetBankServiceLinks(string userId, FilterBase filter);
        Task SetBankServiceLink(string userId, BankLinkSet link);
        ResponseList<List<WalService>> GetServiceList(string userId, FilterBase filter);
        Task SetService(string userId, WalServiceSet service);
        Task SetLinkService(string userId, WalServiceLink link);
        Task DeletePointOrder(BaseCtrlClient ctrlClient, string cardNum, string refNo);
        Task SetServicePOS(string userId, WalServicePOS pos);
        WalServiceGet GetService(string userId, string serviceKey);
        IEnumerable<ServiceProvider> GetTelecomProviders(string userId);
        WalTelephoneCardRespone SetToBuyTelephoneCard(BaseCtrlClient client, WalTelephoneCardSet buyCards);

        Task DeleteRechargeLink(string userId, int linkedId);
        string GetAbout();
        //List<Model.Cab.HelpView> GetHelpers();
        WalPromotion GetPromotion(string userId);
        Task SetPincode(string userId, WalPincode pin);
        bool SetVerifyPincode(string userId, WalPincode pin);
        List<WalTransFilterType> GetTransFilterTypes(string userId);
        Task<TransactionRespone> SetPayToQrCode(BaseCtrlClient client, PayQrCode qrCode);
        WalQrPayView SetPayViewQrCode(BaseCtrlClient client, PayQrCode qrCode);
        WalQrCode GetQrCode(string userId, string serviceKey);
        WalletProfile GetWalletProfile(BaseCtrlClient userId, string phone);
        Task SetPhoneBooks(BaseCtrlClient ctrlClient, ListOfPhoneBook books);
        ResponseList<List<WalPhoneBookGet>> GetPhoneBooks(FilterBase filter);
        WalPaymentViewGet GetPaymentView(string userId, WalPaymentView pay);
        List<WalBankLink> GetRechargeATMLinked(string userId);
        WalUserGrant SetPincodeRequest(string userId);

        WalPointTran SetWalRechargePoint(BaseCtrlClient client, WalRechargePointSet point);
        ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter);
        WalPointTran GetPointTransDetail(string userId, string transNo);
        //List<WalServiceBase> GetPointServiceList(string userId, string filter);
        //List<WalServicePOSBase> GetPointLocationList(string userId, string filter, string serviceKey);
        //crmLoyalPointPage GetPointListPage(PointTotalFilter filter);
        //crmLoyalPointCustPage GetPointCustomerPage(PointTransFilter filter);
        //crmLoyalTransactionPage GetPointTransactionPage(PointTransFilter filter);
        //crmLoyalVoucherPage GetPointVoucherPage(PointTransFilter filter);
        //Task<BaseValidate> SetPointVoucher(BaseCtrlClient ctrlClient, WalPointVoucher voucher);
        //Task SetPointVoucherExpPush(BaseCtrlClient clt, WalPointPush push);
        //Task<BaseValidate> SetPointCancel(BaseCtrlClient ctrlClient, WalPointTranBase voucher);
        //Task<BaseValidate> SetPointWithdraw(BaseCtrlClient ctrlClient, WalPointTranWithdraw withdraw);
        //Task<BaseValidate> DelPointTransaction(BaseCtrlClient ctrlClient, string ref_no);
        //WalApartmentInfo GetPointByCustInfo(string userId, string phone, string roomCode);
        //List<WalPointTranType> GetPointTranTypeList(string userId, string filter);
        //WalCustInfo GetCustSearch(string search_key, string posCd);
    }
}

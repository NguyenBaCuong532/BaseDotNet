using Dapper;
using Microsoft.Extensions.Configuration;
using SSG.Resident.DAL.Interfaces;
using SSG.Resident.DAL.Interfaces.Notify;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM;

namespace SSG.Resident.DAL.Repositories
{
    /// <summary>
    /// SPay Repository
    /// </summary>
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="SPayRepository" />
    public class SPayRepository : ISPayRepository
    {
        private readonly string _connectionString;
        private readonly IFirebaseRepository _notifyRepository;
        private readonly IAppManagerRepository _appRepository;
        public SPayRepository(IConfiguration configuration,
            IAppManagerRepository appRepository,
            IFirebaseRepository notifyRepository)
        {
            _notifyRepository = notifyRepository;
            _appRepository = appRepository;
            _connectionString = configuration.GetConnectionString("SHomeConnection");
        }
        public WalletHome GetWalletHome(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_WalletHome_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId);
                    var homePage = new WalletHome();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);

                    homePage.Profile = result.ReadFirstOrDefault<WalletProfile>();
                    if (homePage.Profile != null)
                    {
                        homePage.WalServices = result.Read<WalServiceSPay>().ToList();
                        homePage.wallet = GetWallet(userId);
                        //homePage.Notifications = result.Read<NotificationGet>().ToList();
                    }
                    return homePage;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public Wallet GetWallet(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var wal = result.ReadFirstOrDefault<Wallet>();
                    if (wal != null)
                    {
                        wal.TranferLink = result.ReadFirstOrDefault<WalBankLink>();
                        if (wal.TranferLink == null)
                            wal.TranferLink = new WalBankLink();
                    }

                    return wal;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public RechargeSource GetRechargeSource(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Recharge_Source";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var rech = new RechargeSource();
                    rech.BankLinks = result.ReadFirstOrDefault<BankSourceLink>();
                    rech.BankLinks.LinkOfList = result.Read<WalBankLink>().ToList();
                    rech.CardAtmLink = result.ReadFirstOrDefault<CardSourceLink>();
                    rech.CardCreditLink = result.ReadFirstOrDefault<CardSourceLink>();

                    //notPage.TranferLinks = result.Read<WalTranferLink>().ToList();
                    //if (notPage.TranferLinks!=null)
                    //{
                    //    var links = result.Read<WalBankLink>().ToList();
                    //    foreach (var tl in notPage.TranferLinks)
                    //    {
                    //        tl.LinkOfList = links.Where(b => b.TranferCd == tl.TranferCd).ToList();
                    //    }
                    //}
                    return rech;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public RechargePage GetRechargePage(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Recharge_Page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var rech = new RechargePage();
                    rech.BankLinks = result.ReadFirstOrDefault<BankSourceLinked>();
                    rech.BankLinks.LinkOfList = result.Read<WalBankLinked>().ToList();
                    rech.CardAtmLink = result.ReadFirstOrDefault<CardSourceLinked>();
                    rech.CardAtmLink.cardLinks = result.Read<WalCardLinked>().ToList();
                    rech.CardCreditLink = result.ReadFirstOrDefault<CardSourceLinked>();
                    rech.CardCreditLink.cardLinks = result.Read<WalCardLinked>().ToList();
                    return rech;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalCardInfo GetCardInfo(string cardNum, string posCd)
        {
            const string storedProcedure = "sp_Pay_Get_Card_Info";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@cardNum", cardNum);
                    var cardServ = new WalCardInfo();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    cardServ = result.ReadFirstOrDefault<WalCardInfo>();
                    return cardServ;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalCustInfo GetCustSearch(string search_key, string posCd)
        {
            const string storedProcedure = "sp_Pay_Get_Cust_Info";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@search_key", search_key);
                    var cardServ = new WalCustInfo();
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    cardServ = result.ReadFirstOrDefault<WalCustInfo>();
                    return cardServ;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<WalBank> GetBanksByType(string userId, int isInternal)
        {
            const string storedProcedure = "sp_Pay_Get_Inter_Cards";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@isInternal", isInternal);
                    return connection.Query<WalBank>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalBank>> GetBankList(string userId, FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Bank_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<WalBank>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<WalBank>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public PayToken GetPaymentLimit(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_WalletLimit_ByUserId";//??????
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.QueryFirstOrDefault<PayToken>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<decimal> GetAmountLimitList(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_AmountLimit";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.Query<decimal>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<decimal> GetPhoneCardValues(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PhoneCard_Values";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.Query<decimal>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<decimal> GetRecentAmountList(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_AmountRecent";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.Query<decimal>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetChangePayLimit(string userId, ChangePayLimit limit)
        {
            const string storedProcedure = "sp_Pay_Update_Wallet_PayLimit";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@Password", limit.Password);
                    param.Add("@LimitAmount", limit.LimitAmount);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<PayTransHistory>> GetPayHistoryList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PayHistory_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@FilterType", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<PayTransHistory>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<PayTransHistory>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public PayTransDetail GetPayTransDetail(string userId, string transNo)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PayHistory_ByNo";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@transNo", transNo);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var pay = result.ReadFirstOrDefault<PayTransDetail>();
                    if (pay.TransType == 3)
                    {
                        pay.cardProvider = result.ReadFirstOrDefault<WalTelephoneCardProvider>();
                        pay.TelephoneCards = result.Read<WalTelephoneCard>().ToList();
                    }
                    return pay;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task SetBank(string userId, WalBank bank)
        {
            const string storedProcedure = "sp_Pay_Insert_Bank";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@BankCd", bank.SourceCd);
                    param.Add("@BankName", bank.SourceName);
                    param.Add("@BankShort", bank.ShortName);
                    param.Add("@LogoUrl", bank.LogoUrl);
                    param.Add("@IsInternal", bank.IsInternal);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public List<WalTranfer> GetServiceRecharges(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Sevice_Recharges";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.Query<WalTranfer>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<WalTranfer> GetServicePayments(string userId, bool isPayment)
        {
            const string storedProcedure = "sp_Pay_Get_Sevice_Payments";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@isPayment", isPayment);
                    return connection.Query<WalTranfer>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<int> SetSCardToOrder(BaseCtrlClient clt, CardOrder order)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_CardOrder";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", clt.UserId);
                    param.Add("@PayType", order.PayType);
                    param.Add("@CardNum", order.CardNum);
                    param.Add("@RefNo", order.RefNo);
                    param.Add("@OrderInfo", order.OrderInfo);
                    param.Add("@Point", order.Point);
                    param.Add("@CreditPoint", order.CreditPoint);
                    param.Add("@OrderAmount", order.OrderAmount);
                    param.Add("@ServiceKey", order.ServiceKey);
                    param.Add("@PosCd", order.PosCd);
                    param.Add("@roomCode", null);
                    param.Add("@ClientId", clt.ClientId);
                    param.Add("@ClientIp", clt.ClientIp);
                    param.Add("@notiQue", 1);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var notis = result.Read<AppQueueNotifySingle<CfgEventSPay>>().ToList();
                    if (notis != null && notis.Count > 0)
                    {
                        foreach (var n in notis)
                        {
                            if (n.action_list.Contains("sms"))
                                await _appRepository.TakeMessage(clt, n.apMessage());
                            if (n.action_list.Contains("email"))
                                await _appRepository.TakeSendMail(clt, n.apEmail());
                            if (n.action_list.Contains("push"))
                                await _notifyRepository.SendNotifyQueue(n.fbNotify(new CfgEventSPay { moduleId = "s-pay", ref_No = n.ref_no }), false);
                        }
                    }
                    return 1;
                }
            }
            catch (Exception ex)
            {
                //throw ex;
                return 0;
            }
        }
        public WalTransactionGet SetWalTransaction(string userId, WalTransactionSet tran)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_Transaction";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@BaseCif", tran.BaseCif);
                    param.Add("@TranferCd", tran.TranferCd);
                    param.Add("@TxnInfo", tran.OrderInfo);
                    param.Add("@RefNo", tran.RefNo);
                    param.Add("@DBCR", tran.DBCR);
                    param.Add("@Amount", tran.Amount);
                    param.Add("@FeeAmt", tran.FeeAmt);
                    return connection.QueryFirstOrDefault<WalTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetWalTransactionPayed(TransactionPayed payment)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_TransactionPayed";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@RefNo", payment.RefNo);
                    param.Add("@SourceCd", null);
                    param.Add("@ResponseCode", payment.ResponseCode);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetNapTransactionPayed(NapasTransactionPayed payment)
        {
            const string storedProcedure = "sp_Pay_Insert_Nap_TransactionPayed";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@vpc_MerchTxnRef", payment.vpc_MerchTxnRef);
                    param.Add("@vpc_Amount", payment.vpc_Amount);
                    param.Add("@vpc_OrderInfo", payment.vpc_OrderInfo);
                    param.Add("@vpc_TransactionNo", payment.vpc_TransactionNo);
                    param.Add("@vpc_BatchNo", payment.vpc_BatchNo);
                    param.Add("@vpc_AcqResponseCode", payment.vpc_AcqResponseCode);
                    param.Add("@vpc_AdditionalData", payment.vpc_AdditionalData);
                    param.Add("@vpc_ResponseCode", payment.vpc_ResponseCode);
                    param.Add("@vpc_Message", payment.vpc_Message);

                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetNapTransactionCallback(NapasFormResult data)
        {
            if (data.TokenResult != null && data.TokenResult.Result == "SUCCESS")
            {
                await SetTranferLinked(data.TokenResult);
            }
            var payment = data.PaymentResult;
            if (payment != null)
            {
                const string storedProcedure = "sp_Pay_Insert_Nap_TransactionCallback";
                try
                {
                    using (SqlConnection connection = new SqlConnection(_connectionString))
                    {
                        connection.Open();
                        var param = new DynamicParameters();
                        param.Add("@vpc_OrderInfo", payment.Order.Id);
                        param.Add("@vpc_Amount", payment.Order.Amount);
                        param.Add("@vpc_TransactionNo", payment.Transaction.Id);
                        param.Add("@vpc_ResponseCode", payment.Response.AcquirerCode);
                        param.Add("@vpc_Message", payment.Response.Message);
                        if (payment.SourceOfFunds != null && payment.SourceOfFunds.Provided != null && payment.SourceOfFunds.Provided.Card != null)
                            param.Add("@vpc_Source", payment.SourceOfFunds.Provided.Card.Brand);
                        else
                            param.Add("@vpc_Source", null);
                        param.Add("@vpc_Result", payment.Result);
                        await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                        return;
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
        }

        private async Task SetTranferLinked(TokenResult link)
        {
            const string storedProcedure = "sp_Pay_Update_Wallet_Tranferlinked";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", link.DeviceId);
                    param.Add("@Token", link.Token);

                    param.Add("@Brand", link.Card.Brand);
                    param.Add("@NameOnCard", link.Card.NameOnCard);
                    param.Add("@IssueDate", link.Card.IssueDate);
                    param.Add("@Number", link.Card.Number);
                    param.Add("@Scheme", link.Card.Scheme);

                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public string SetTranferLink(string userId, WalBankLinkReg link)
        {
            const string storedProcedure = "sp_Pay_Update_Wallet_Tranfer_Link";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@TranferCd", link.TranferCd);
                    //param.Add("@SourceCd", link.SourceCd);
                    var result = connection.QueryFirstOrDefault<string>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public WalRechargeView GetRechargeView(string userId, WalRechargeBase recharge)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_RechargeView";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@TranferCd", recharge.TranferCd);
                    param.Add("@LinkedID", recharge.LinkedID);
                    param.Add("@Amount", recharge.Amount);
                    var result = connection.QueryFirstOrDefault<WalRechargeView>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalTransactionGet SetWalletRecharge(BaseCtrlClient client, WalRechargeBase recharge, long ordTnxId = 0)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_Recharge";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", client.UserId);
                    param.Add("@ClientId", client.ClientId);
                    param.Add("@ClientIp", client.ClientIp);
                    param.Add("@TranferCd", recharge.TranferCd);
                    param.Add("@LinkedID", recharge.LinkedID);
                    param.Add("@Amount", recharge.Amount);
                    param.Add("@ordTnxId", ordTnxId);
                    var result = connection.QueryFirstOrDefault<WalTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public NapasTransactionGet SetNapTransaction(BaseCtrlClient client, NapasTransactionSet napTran)
        {
            const string storedProcedure = "sp_Pay_Insert_Nap_TransactionInfo";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", client.UserId);
                    param.Add("@ClientId", client.ClientId);
                    param.Add("@ClientIp", client.ClientIp);

                    param.Add("@RefNo", napTran.RefNo);
                    param.Add("@Amount", napTran.Amount);
                    param.Add("@TranferCd", napTran.TranferCd);
                    param.Add("@SourceCd", napTran.SourceCd);
                    var result = connection.QueryFirstOrDefault<NapasTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public NapasTransactionGet SetNapTransaction(NapasTran tran)
        {
            const string storedProcedure = "sp_Pay_Insert_Nap_Transaction";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", tran.userId);
                    param.Add("@ClientIp", tran.clientIp);
                    param.Add("@orderId", tran.orderId);
                    param.Add("@amount", tran.amount);
                    param.Add("@cardType", tran.cardType);
                    param.Add("@transactionType", tran.transactionType);
                    param.Add("@linkedId", tran.linkedId);
                    var result = connection.QueryFirstOrDefault<NapasTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public NapasTransactionGet GetNapTransaction(string orderId)
        {
            const string storedProcedure = "sp_Pay_Get_Nap_Transaction";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@orderId", orderId);
                    var result = connection.QueryFirstOrDefault<NapasTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalTransactionGet SetWalletPayment(BaseCtrlClient client, WalPayment payment)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_Payment";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", client.UserId);
                    param.Add("@ClientId", client.ClientId);
                    param.Add("@ClientIp", client.ClientIp);
                    param.Add("@RefNo", payment.RefNo);
                    param.Add("@OrderInfo", payment.OrderInfo);
                    param.Add("@Amount", payment.Amount);
                    param.Add("@fromWalletCd", payment.fromWalletCd);
                    param.Add("@toWalletCd", payment.toWalletCd);
                    param.Add("@ServiceKey", payment.ServiceKey);
                    param.Add("@PosCd", payment.PosCd);
                    var result = connection.QueryFirstOrDefault<WalTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<string> SetWalActived(string phone)
        {
            const string storedProcedure = "sp_Pay_Create_New_Wallet";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@phone", phone);
                    param.Add("@IsInternal", 0);
                    param.Add("@WalletCd", "", DbType.String, ParameterDirection.InputOutput);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return param.Get<string>("@WalletCd");
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalletList>> GetWalletList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_List_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var cleanlist = result.Read<WalletList>().ToList();
                    return new ResponseList<List<WalletList>>(cleanlist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalProviderSet>> GetProviderList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Provider_ByManger";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var provlist = result.Read<WalProviderSet>().ToList();
                    return new ResponseList<List<WalProviderSet>>(provlist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetProvider(string userId, WalProviderSet provider)
        {
            const string storedProcedure = "sp_Pay_Insert_Provider";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ProviderId", provider.ProviderId);
                    param.Add("@ProviderCd", provider.ProviderCd);
                    param.Add("@ProviderShort", provider.ProviderShort);
                    param.Add("@ProviderName", provider.ProviderName);
                    param.Add("@LogoUrl", provider.LogoUrl);
                    param.Add("@ContactName", provider.ContactName);
                    param.Add("@Phone", provider.Phone);
                    param.Add("@Email", provider.Email);
                    param.Add("@Address", provider.Address);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalProviderSet GetProvider(string userId, int providerId)
        {
            const string storedProcedure = "sp_Pay_Get_Provider_ById";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@providerId", providerId);
                    var result = connection.QueryFirstOrDefault<WalProviderSet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<PayTransactionGet>> GetPayTransactionList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Transaction_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<PayTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<PayTransactionGet>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<ProviderTransactionGet>> GetProviderTransactionList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Transaction_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<ProviderTransactionGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<ProviderTransactionGet>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<BankLinkGet>> GetBankServiceLinks(string userId, FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_BankLink_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<BankLinkGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<BankLinkGet>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task SetBankServiceLink(string userId, BankLinkSet link)
        {
            const string storedProcedure = "sp_Pay_Insert_BankLink";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@LinkId", link.LinkId);
                    param.Add("@SourceCd", link.SourceCd);
                    param.Add("@TranferCd", link.TranferCd);
                    param.Add("@IsInternal", link.IsInternal);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalService>> GetServiceList(string userId, FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Service_ByManager";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<WalService>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<WalService>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetService(string userId, WalServiceSet service)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_Service";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ServiceCd", service.ServiceCd);
                    param.Add("@ServiceName", service.ServiceName);
                    param.Add("@ServiceViewUrl", service.ServiceViewUrl);
                    param.Add("@ProviderCd", service.ProviderCd);
                    param.Add("@IconKey", service.IconKey);
                    param.Add("@IsFlage", service.IsFlage);
                    param.Add("@intOrder", service.intOrder);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetLinkService(string userId, WalServiceLink link)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_ServiceLink";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@ServiceKey", link.ServiceKey);
                    param.Add("@ProviderCd", link.ProviderCd);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetServicePOS(string userId, WalServicePOS pos)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_ServicePOS";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@PosCd", pos.PosCd);
                    param.Add("@ServiceKey", pos.ServiceKey);
                    param.Add("@PosName", pos.PosName);
                    param.Add("@Address", pos.Address);
                    param.Add("@IsPayment", pos.IsPayment);
                    param.Add("@IsRecharge", pos.IsRecharge);
                    param.Add("@IsSPay", pos.IsSPay);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalServiceGet GetService(string userId, string serviceKey)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Service_ByCd";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@serviceKey", serviceKey);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var servGet = result.ReadFirstOrDefault<WalServiceGet>();
                    if (servGet != null)
                    {
                        servGet.ServicePOS = result.Read<WalServicePOS>().ToList();
                    }
                    return servGet;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<ServiceProvider> GetTelecomProviders(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_TelecomProviders";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    return connection.Query<ServiceProvider>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalTelephoneCardRespone SetToBuyTelephoneCard(BaseCtrlClient client, WalTelephoneCardSet buyCards)
        {
            const string storedProcedure = "sp_Pay_Insert_Buy_TelephoneCard";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", client.UserId);
                    param.Add("@ProviderCd", buyCards.ProviderCd);
                    param.Add("@cardValue", buyCards.cardValue);
                    param.Add("@Quantity", buyCards.Quantity);
                    param.Add("@ClientId", client.ClientId);
                    param.Add("@ClientIp", client.ClientIp);
                    param.Add("@serviceKey", null);
                    param.Add("@PosCd", null);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var reponse = result.ReadFirstOrDefault<WalTelephoneCardRespone>();
                    if (reponse != null)
                    {
                        reponse.cardProvider = result.ReadFirstOrDefault<WalTelephoneCardProvider>();
                        reponse.TelephoneCards = result.Read<WalTelephoneCard>().ToList();
                    }
                    return reponse;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task DeleteRechargeLink(string userId, int linkedId)
        {
            const string storedProcedure = "sp_Pay_Delete_Recharge_Link";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@linkedId", linkedId);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;

            }
        }
        public string GetAbout()
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_About";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    return connection.QueryFirstOrDefault<string>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //public List<Model.Cab.HelpView> GetHelpers()
        //{
        //    const string storedProcedure = "sp_Pay_Get_Wallet_Helpers";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            return connection.Query<Model.Cab.HelpView>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        public WalPromotion GetPromotion(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Promotion";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    return connection.QueryFirstOrDefault<WalPromotion>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetPincode(string userId, WalPincode pin)
        {
            const string storedProcedure = "sp_Pay_Update_Wallet_Pincode";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@pincode", pin.pincode);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool SetVerifyPincode(string userId, WalPincode pin)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Pincode";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var pincode = connection.QueryFirstOrDefault<string>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return pin.pincode == pincode;
                }
            }
            catch (Exception ex)
            {
                throw ex;

            }
        }
        public List<WalTransFilterType> GetTransFilterTypes(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_FilterTypes";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    return connection.Query<WalTransFilterType>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalQrCode GetQrCode(string userId, string serviceKey)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_QrCode";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@serviceKey", serviceKey);
                    return connection.QueryFirstOrDefault<WalQrCode>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalletProfile GetWalletProfile(BaseCtrlClient userId, string phone)
        {
            const string storedProcedure = "sp_Pay_Get_WalletProfile_ByPhone";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@UserId", userId.UserId);
                    param.Add("@phone", phone);
                    var homePage = new WalletHome();
                    var result = connection.QueryFirstOrDefault<WalletProfile>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task SetPhoneBooks(BaseCtrlClient client, ListOfPhoneBook books)
        {
            const string storedProcedure = "sp_Pay_Update_Phone_Books";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", client.UserId);
                    //param.Add("@pincode", books);
                    param.Add("@XML", Utils.SerializeXml<List<WalPhoneBook>>(books.books));
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalPhoneBookGet>> GetPhoneBooks(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Phone_Books_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<WalPhoneBookGet>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<WalPhoneBookGet>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalPaymentViewGet GetPaymentView(string userId, WalPaymentView pay)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PaymentView";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@PosCd", pay.PosCd);
                    param.Add("@ServiceKey", pay.ServiceKey);
                    param.Add("@PaymentType", pay.PaymentType);
                    param.Add("@Amount", pay.Amount);
                    var result = connection.QueryFirstOrDefault<WalPaymentViewGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<WalBankLink> GetRechargeATMLinked(string userId)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Recharge_ATMLinked";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.Query<WalBankLink>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalPosCallback GetPosCallback(string posCd)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_Callback_ByPosCd";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@posCd", posCd);
                    var result = connection.QueryFirstOrDefault<WalPosCallback>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalUserGrant SetPincodeRequest(string userId)
        {
            const string storedProcedure = "sp_Pay_Update_Wallet_Pincode_Request";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    var result = connection.QueryFirstOrDefault<WalUserGrant>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalPointTran SetWalRechargePoint(BaseCtrlClient client, WalRechargePointSet point)
        {
            const string storedProcedure = "sp_Pay_Update_Point_ByToken";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", client.UserId);
                    param.Add("@CardToken", point.CardToken);
                    return connection.QueryFirstOrDefault<WalPointTran>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PointHistory_ByUserId";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@FilterType", filter.filter);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);

                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

                    var result = connection.Query<WalPointTran>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return new ResponseList<List<WalPointTran>>(result, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public WalPointTran GetPointTransDetail(string userId, string transNo)
        {
            const string storedProcedure = "sp_Pay_Get_Wallet_PointHistory_ByNo";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@transNo", transNo);
                    return connection.QueryFirstOrDefault<WalPointTran>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task DeletePointOrder(BaseCtrlClient ctrlClient, string cardNum, string refNo)
        {
            const string storedProcedure = "sp_Pay_Delete_Point_ByOrder";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", ctrlClient.UserId);
                    param.Add("@ClientId", ctrlClient.ClientId);
                    param.Add("@ClientIp", ctrlClient.ClientIp);
                    param.Add("@cardNum", cardNum);
                    param.Add("@refNo", refNo);
                    await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;

            }
        }
        public async Task<int> SetSPointToOrder(BaseCtrlClient clt, CardOrder order)
        {
            const string storedProcedure = "sp_Pay_Insert_Wallet_PointOrder";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", clt.UserId);
                    param.Add("@PayType", order.PayType);
                    param.Add("@CustId", order.CardNum);
                    param.Add("@RefNo", order.RefNo);
                    param.Add("@OrderInfo", order.OrderInfo);
                    param.Add("@Point", order.Point);
                    param.Add("@CreditPoint", order.CreditPoint);
                    param.Add("@OrderAmount", order.OrderAmount);
                    param.Add("@ServiceKey", order.ServiceKey);
                    param.Add("@PosCd", order.PosCd);
                    param.Add("@ClientId", clt.ClientId);
                    param.Add("@ClientIp", clt.ClientIp);
                    param.Add("@notiQue", 1);
                    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var notis = result.Read<AppQueueNotifySingle<CfgEventSPay>>().ToList();
                    if (notis != null && notis.Count > 0)
                    {
                        foreach (var n in notis)
                        {
                            if (n.action_list.Contains("sms"))
                                await _appRepository.TakeMessage(clt, n.apMessage());
                            if (n.action_list.Contains("email"))
                                await _appRepository.TakeSendMail(clt, n.apEmail());
                            if (n.action_list.Contains("push"))
                                await _notifyRepository.SendNotifyQueue(n.fbNotify(new CfgEventSPay { moduleId = "s-pay", ref_No = n.ref_no }), false);
                        }
                    }
                    return 1;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<WalServiceBase> GetPointServiceList(string userId, string filter)
        {
            const string storedProcedure = "sp_Pay_Service_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@filter", filter);
                    return connection.Query<WalServiceBase>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<WalServicePOSBase> GetPointLocationList(string userId, string filter, string serviceKey)
        {
            const string storedProcedure = "sp_Pay_ServicePOS_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@serviceKey", serviceKey);
                    param.Add("@filter", filter);
                    return connection.Query<WalServicePOSBase>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //public crmLoyalPointPage GetPointListPage(PointTotalFilter filter)
        //{
        //    const string storedProcedure = "sp_Pay_Point_List_Page";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserId", filter.userId);
        //            param.Add("@Filter", filter.filter);
        //            param.Add("@lastDate", filter.lastDate);
        //            param.Add("@numDay", filter.numDay);
        //            param.Add("@gridWidth", filter.gridWidth);
        //            param.Add("@Offset", filter.offSet);
        //            param.Add("@PageSize", filter.pageSize);
        //            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = new crmLoyalPointPage();
        //            if (filter.offSet == null || filter.offSet == 0)
        //            {
        //                data.gridflexs = result.Read<viewGridFlex>().ToList();
        //                data.chart_day = result.Read<crmLoyalPointDay>().ToList();
        //                data.total_of_days = result.ReadFirstOrDefault<crmLoyalPointTotal>();
        //                data.total_last = result.ReadFirstOrDefault<crmLoyalPointTotal>();
        //            }
        //            var deplist = result.Read<crmLoyalPoint>().ToList();
        //            data.dataList = new ResponseList<List<crmLoyalPoint>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public crmLoyalPointCustPage GetPointCustomerPage(PointTransFilter filter)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Cust_Page";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserId", filter.userId);
        //            //param.Add("@custId", filter.custId);
        //            param.Add("@serviceKey", filter.serviceKey);
        //            param.Add("@posCd", filter.posCd);
        //            param.Add("@tranType", filter.tranType);
        //            param.Add("@dateFilter", filter.dateFilter);
        //            param.Add("@startDate", filter.startDate);
        //            param.Add("@endDate", filter.endDate);
        //            param.Add("@Filter", filter.filter);
        //            param.Add("@gridWidth", filter.gridWidth);
        //            param.Add("@Offset", filter.offSet);
        //            param.Add("@PageSize", filter.pageSize);
        //            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = new crmLoyalPointCustPage();
        //            if (filter.offSet == null || filter.offSet == 0)
        //            {
        //                data.gridflexs = result.Read<viewGridFlex>().ToList();
        //            }
        //            var deplist = result.Read<crmLoyalPoint>().ToList();
        //            data.dataList = new ResponseList<List<crmLoyalPoint>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public crmLoyalTransactionPage GetPointTransactionPage(PointTransFilter filter)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Transaction_Page";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserId", filter.userId);
        //            param.Add("@custId", filter.custId);
        //            param.Add("@serviceKey", filter.serviceKey);
        //            param.Add("@posCd", filter.posCd);
        //            param.Add("@tranType", filter.tranType);
        //            param.Add("@dateFilter", filter.dateFilter);
        //            param.Add("@startDate", filter.startDate);
        //            param.Add("@endDate", filter.endDate);
        //            param.Add("@Filter", filter.filter);
        //            param.Add("@gridWidth", filter.gridWidth);
        //            param.Add("@Offset", filter.offSet);
        //            param.Add("@PageSize", filter.pageSize);
        //            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = new crmLoyalTransactionPage();
        //            if (filter.offSet == null || filter.offSet == 0)
        //            {
        //                data.gridflexs = result.Read<viewGridFlex>().ToList();
        //            }
        //            var deplist = result.Read<crmLoyalTransaction>().ToList();
        //            data.dataList = new ResponseList<List<crmLoyalTransaction>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public crmLoyalVoucherPage GetPointVoucherPage(PointTransFilter filter)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Voucher_Page";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@UserId", filter.userId);
        //            param.Add("@custId", filter.custId);
        //            param.Add("@serviceKey", filter.serviceKey);
        //            param.Add("@posCd", filter.posCd);
        //            param.Add("@tranType", filter.tranType);
        //            param.Add("@dateFilter", filter.dateFilter);
        //            param.Add("@startDate", filter.startDate);
        //            param.Add("@endDate", filter.endDate);
        //            param.Add("@Filter", filter.filter);
        //            param.Add("@gridWidth", filter.gridWidth);
        //            param.Add("@Offset", filter.offSet);
        //            param.Add("@PageSize", filter.pageSize);
        //            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = new crmLoyalVoucherPage();
        //            if (filter.offSet == null || filter.offSet == 0)
        //            {
        //                data.gridflexs = result.Read<viewGridFlex>().ToList();
        //            }
        //            var deplist = result.Read<crmLoyalVoucher>().ToList();
        //            data.dataList = new ResponseList<List<crmLoyalVoucher>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public async Task<BaseValidate> SetPointVoucher(BaseCtrlClient clt, WalPointVoucher voucher)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Transaction_Voucher";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", clt.UserId);
        //            param.Add("@ClientId", clt.ClientId);
        //            param.Add("@ClientIp", clt.ClientIp);
        //            param.Add("@custId", voucher.custId);
        //            param.Add("@cardCd", voucher.cardCd);
        //            param.Add("@ref_No", voucher.ref_No);
        //            param.Add("@orderInfo", voucher.orderInfo);
        //            param.Add("@pointCd", voucher.pointCd);
        //            param.Add("@point", voucher.point);
        //            param.Add("@serviceKey", voucher.serviceKey);
        //            param.Add("@posCd", voucher.posCd);
        //            param.Add("@roomCode", voucher.roomCode);
        //            param.Add("@expireDate", voucher.expireDate);
        //            var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
        //            if (valid.valid && valid.notiQue)
        //            {
        //                var notiQue = await result.ReadFirstOrDefaultAsync<CfgQueueNotify<CfgEventSPay>>();
        //                if (notiQue != null)
        //                {
        //                    notiQue.CreatedDate = DateTime.UtcNow;
        //                    var users = await result.ReadAsync<PushNotifyUser>();
        //                    notiQue.Users = users.ToList();
        //                    notiQue.ExternalInfo = new CfgEventSPay { moduleId = "s-pay", ref_No = voucher.ref_No };
        //                    await _notifyRepository.SendNotifyQueue(notiQue, false);
        //                }
        //            }
        //            return valid;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;

        //    }
        //}
        //public async Task SetPointVoucherExpPush(BaseCtrlClient clt, WalPointPush push)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Voucher_Push";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", clt.UserId);
        //            param.Add("@expire_dt", push.expire_date);
        //            param.Add("@ref_Nos", string.Join(",", push.ref_Nos));
        //            var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var notis = result.Read<AppQueueNotifySingle<CfgEventSPay>>().ToList();
        //            if (notis != null && notis.Count > 0)
        //            {
        //                foreach (var n in notis)
        //                {
        //                    if (n.action_list.Contains("push"))
        //                        await _notifyRepository.SendNotifyQueue(n.fbNotify(new CfgEventSPay { moduleId = "s-pay", ref_No = n.ref_no }), false);
        //                    if (n.action_list.Contains("sms"))
        //                        await _appRepository.TakeMessage(clt, n.apMessage());
        //                    if (n.action_list.Contains("email"))
        //                        await _appRepository.TakeSendMail(clt, n.apEmail());

        //                }
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public async Task<BaseValidate> SetPointCancel(BaseCtrlClient clt, WalPointTranBase voucher)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Transaction_Cancel";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", clt.UserId);
        //            param.Add("@ClientId", clt.ClientId);
        //            param.Add("@ClientIp", clt.ClientIp);
        //            param.Add("@ref_no", voucher.ref_no);
        //            return await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;

        //    }
        //}
        //public async Task<BaseValidate> SetPointWithdraw(BaseCtrlClient clt, WalPointTranWithdraw withdraw)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Transaction_Withdraw";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", clt.UserId);
        //            param.Add("@ClientId", clt.ClientId);
        //            param.Add("@ClientIp", clt.ClientIp);
        //            param.Add("@ref_no", withdraw.ref_no);
        //            param.Add("@point", withdraw.point);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var valid = result.ReadFirst<BaseValidate>();
        //            if (valid.valid)
        //            {
        //                var notis = result.Read<AppQueueNotifySingle<CfgEventSPay>>().ToList();
        //                if (notis != null && notis.Count > 0)
        //                {
        //                    foreach (var n in notis)
        //                    {
        //                        if (n.action_list.Contains("push"))
        //                            await _notifyRepository.SendNotifyQueue(n.fbNotify(new CfgEventSPay { moduleId = "s-pay", ref_No = n.ref_no }), false);
        //                        if (n.action_list.Contains("sms"))
        //                            await _appRepository.TakeMessage(clt, n.apMessage());
        //                        if (n.action_list.Contains("email"))
        //                            await _appRepository.TakeSendMail(clt, n.apEmail());

        //                    }
        //                }
        //            }
        //            return valid;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;

        //    }
        //}
        //public async Task<BaseValidate> DelPointTransaction(BaseCtrlClient clt, string ref_no)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Transaction_Del";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", clt.UserId);
        //            param.Add("@ref_no", ref_no);
        //            return await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;

        //    }
        //}
        //public WalApartmentInfo GetPointByCustInfo(string userId, string phone, string roomCode)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Cust_Info";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", userId);
        //            param.Add("@phone", phone);
        //            param.Add("@roomCode", roomCode);
        //            var result = connection.QueryFirstOrDefault<WalApartmentInfo>(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            return result;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public List<WalPointTranType> GetPointTranTypeList(string userId, string filter)
        //{
        //    const string storedProcedure = "sp_Pay_Point_Trantype_List";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", userId);
        //            param.Add("@filter", filter);
        //            return connection.Query<WalPointTranType>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
    }
}

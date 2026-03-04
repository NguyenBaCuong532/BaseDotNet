using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.Bank.KLBank;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.DAL.Interfaces.Transaction;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Repositories.Transaction
{
    public class TransactionRepository : UniBaseRepository, ITransactionRepository
    {
        //private readonly INotifyRepository _apiNotifyRepository;
        private readonly IFirebaseRepository _fbRepository;

        public TransactionRepository(IUniCommonBaseRepository common, INotifyRepository apiNotifyRepository, IFirebaseRepository fbRepository) : base(common)
        {
            //_apiNotifyRepository = apiNotifyRepository;
            _fbRepository = fbRepository;
        }
    #region trans_bank
        public async Task<klbInquiryCheckingResponse> InquiryChecking(klbInquiryCheckingRequest request)
        {
            const string storedProcedure = "sp_res_inquery_checking";
            return await GetFirstOrDefaultAsync<klbInquiryCheckingResponse>(storedProcedure, new { request.virtualAccount });
        }

        public async Task<klbDepositCheckingResponse> DepositChecking(klbDepositCheckingRequest request)
        {
            const string storedProcedure = "sp_res_deposit_checking";
            return await GetFirstOrDefaultAsync<klbDepositCheckingResponse>(storedProcedure, new { request.virtualAccount, request.amount });
        }

        public Task<BaseValidate> SetPaymentCallBack(klbNotifyTransactionEnscrypt response)
        {
            const string storedProcedure = "sp_res_bank_response_set";
            return base.SetAsync(storedProcedure, new { response.success, response.interBankTrace, response.virtualAccount,
                                                        response.actualAccount, response.fromBin, response.fromAccount, response.amount,
                                                        response.statusCode, response.txnNumber, response.transferDesc, response.time
            });
        }

        public Task<BaseValidate> SetLogTransactionInfo(LogTransactionBank logTransaction)
        {
            const string storedProcedure = "sp_res_log_transaction_bank_set";
            return base.SetAsync(storedProcedure, logTransaction);
        }

        public async Task<BaseValidate> PushNotifyAsync(string virtualAccount)
        {
            const string storedProcedure = "sp_res_invoice_notify_push_paid";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("@virtualAccount", virtualAccount);
                return param;
            }, async result =>
            {
                var notis = (await result.ReadAsync<AppQueueNotifySingle<CfgEventBillResident>>()).ToList();
                if (notis != null && notis.Count > 0)
                {
                    foreach (var n in notis)
                    {
                        if (n.action_list.Contains("push"))
                            await _fbRepository.SendNotifyQueue(n.fbNotify(new CfgEventBillResident { moduleId = "s-resident", receiveId = n.Id }), false);
                    }
                }
                return new BaseValidate { valid = true, messages = "Gửi thông báo thành công" };
            });
            //using (SqlConnection connection = new SqlConnection(_connectionString))
            //{
            //    connection.Open();
            //    var param = new DynamicParameters();

            //    var result = await connection.QueryMultipleAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
            //    var notis = result.Read<AppQueueNotifySingle<CfgEventBillResident>>().ToList();
            //    if (notis != null && notis.Count > 0)
            //    {
            //        foreach (var n in notis)
            //        {
            //            if (n.action_list.Contains("push"))
            //                await _fbRepository.SendNotifyQueue(n.fbNotify(new CfgEventBillResident { moduleId = "s-resident", receiveId = n.Id }), false);
            //            //var noti = await _notifyRepository.TakeNotification2(ctrlClient, n.getNotify());
            //            //if (n.action_list.Contains("sms"))
            //            //    await _appRepository.TakeMessage(clt, n.apMessage());
            //            //if (n.action_list.Contains("email"))
            //            //    await _appRepository.TakeSendMail(clt, n.apEmail());
            //            //if (noti.valid)
            //            //    await this.SetReceiptNotifyPushed(ctrlClient.UserId, n.Id);
            //            //else
            //            //    return noti;
            //        }
            //    }
            //    return new BaseValidate { valid = true, messages = "Gửi thông báo thành công" };
            //}
        }
       
        public Task<CommonViewInfo> GetTransBankFilter(string userId)
        {
            const string storedProcedure = "tran_response_filter";
            return base.GetTableFilterAsync(storedProcedure);
        }

        public async Task<CommonDataPage> GetTransBankPage(FilterTransInput param)
        {
            const string storedProcedure = "sp_res_trans_bank_page";
            return await base.GetDataListPageAsync(storedProcedure, param, new {param.projectCd, param.RoomCode, from_dt = param.fromDt, to_dt = param.toDt});
        }
        #endregion trans_bank
    }
}
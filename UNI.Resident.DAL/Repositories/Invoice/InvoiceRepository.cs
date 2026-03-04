using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model.Invoice;
using UNI.Resident.Model.Receipt;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Resident.Model.Common;
using UNI.Model.APPM.Notifications;
using System.Collections.Generic;

namespace UNI.Resident.DAL.Repositories.Invoice
{
    public class InvoiceRepository : UniBaseRepository, IInvoiceRepository
    {
        private readonly IFirebaseRepository _fbRepository;
        private readonly INotifyRepository _notifyRepository;

        public InvoiceRepository(IUniCommonBaseRepository common,
            IFirebaseRepository fbRepository,
            INotifyRepository notifyRepository) : base(common)
        {
            _notifyRepository = notifyRepository;
            _fbRepository = fbRepository;
        }
        #region invoice-reg
        public async Task<BaseValidate> PushNotifyAsync(ReceiptsBase receipts, string projectcode)
        {
            const string storedProcedure = "sp_res_invoice_notify_push_kafka_v3";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, param =>
            {
                //param.Add("@userId", ctrlClient.UserId);
                param.Add("@projectcode", projectcode);
                param.Add("@receiveIds", string.Join(",", receipts.receiveIds));
                return param;
            }, async result =>
            {
                var data = result.ReadFirstOrDefault<BaseValidate>();
                if (data.valid)
                {
                    var pushRuns = result.Read<PushNotifyRun>();
                    if (pushRuns != null)
                    {
                        foreach (var pushRun in pushRuns)
                        {
                            pushRun.ids = new List<string>();
                            await _notifyRepository.SendToKafka(pushRun);
                        }
                    }
                }
                return (data);
            }
            );
        }

        //public async Task SetReceiptNotifyPushed(string receiveId)
        //{
        //    const string storedProcedure = "sp_res_invoice_notify_pushed_set";
        //    await SetAsync<int>(storedProcedure, new { receiveId });
        //}

        public async Task<BaseValidate> PushRemindNotifyAsync(ReceiptsBase receipts, string projectcode)
        {
            const string storedProcedure = "sp_res_invoice_notify_remind_push_kafka_v3";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, param =>
            {
                //param.Add("@userId", clt.UserId);
                param.Add("@projectcode", projectcode);
                param.Add("@receiveIds", string.Join(",", receipts.receiveIds));
                return param;
            }, async result =>
            {
                var data = result.ReadFirstOrDefault<BaseValidate>();
                if (data.valid)
                {
                    var pushRuns = result.Read<PushNotifyRun>();
                    if (pushRuns != null)
                    {
                        foreach (var pushRun in pushRuns)
                        {
                            pushRun.ids = new List<string>();
                            await _notifyRepository.SendToKafka(pushRun);
                        }
                    }
                }
                return (data);
            });
        }
        //public async Task SetServiceReceivableReminded(string receiveId)
        //{
        //    const string storedProcedure = "sp_res_invoice_notify_remind_pushed_set";
        //    await SetAsync<int>(storedProcedure, new { receiveId });
        //}

        public async Task<BaseValidate> DeleteAsync(long receiptId)
        {
            const string storedProcedure = "sp_res_receipt_del";
            return await DeleteAsync(storedProcedure, new { ReceiptId = receiptId });
        }
        public async Task<BaseValidate> DeleteMultiAsync(CommonDeleteMulti delids)
        {
            const string storedProcedure = "sp_res_receipt_dels";
            return await DeleteAsync(storedProcedure, new { receiveIds = string.Join(",", delids.Ids) });
        }

        public async Task<CommonViewInfo> GetInfoAsync(string type, long? id, decimal? remainamt)
        {
            string storedProcedure = string.Empty;
            switch (type)
            {
                case "confirm":
                    storedProcedure = "sp_res_invoice_confirm_field";
                    break;
                case "transfer":
                    storedProcedure = "sp_res_invoice_transfer_field";
                    break;
            }
            if (string.IsNullOrEmpty(storedProcedure)) return null;
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { receiveId = id, remainamt });
        }

        public async Task<BaseValidate> CreateInvoicesAsync(ReceiptsBase receipts)
        {
            const string storedProcedure = "sp_res_invoices_create";
            return await GetMultipleAsync(storedProcedure,
                param =>
                {
                    param.Add("@projectCd", receipts.projectCd);
                    param.Add("@receiveIds", string.Join(",", receipts.receiveIds));
                    return param;
                }, async result =>
                {
                    var data = result.ReadFirstOrDefault<BaseValidate>();
                    if (data.valid)
                    {
                        var listId = receipts.receiveIds.Select(i => i.ToString()).ToList();
                        var resSendToKafka = await _notifyRepository.SendToKafka(new PushNotifyRun() { action = "bill", ids = listId });
                        if (resSendToKafka.Result != UNI.Model.Api.ApiResult.Success)
                        {
                            data.valid = false;
                            data.messages = resSendToKafka.Message;
                            if (resSendToKafka.Error != null && resSendToKafka.Error.Count > 0)
                                data.messages = $"{data.messages}: {string.Join("; ", resSendToKafka.Error)}";
                        }
                    }
                    return (data);
                });
        }

        public async Task<CommonDataPage> GetInvoiceHistoryByApartmentIdPage(InvoiceRequestModel flt)
        {
            const string storedProcedure = "sp_res_receivable_bill_page_by_apartId";
            return await GetDataListPageAsync(storedProcedure, flt, new { flt.apartmentId });
        }
        #endregion invoice-reg
    }
}

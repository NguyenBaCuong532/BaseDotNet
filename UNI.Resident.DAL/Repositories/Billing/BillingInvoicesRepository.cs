using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;

namespace UNI.Resident.DAL.Repositories.Billing
{
    /// <summary>
    /// Kỳ thanh toán - Hóa đơn
    /// </summary>
    public class BillingInvoicesRepository : ResidentBaseRepository, IBillingInvoicesRepository
    {
        private readonly INotifyRepository _notifyRepository;

        public BillingInvoicesRepository(IResidentCommonBaseRepository common,
            INotifyRepository notifyRepository) : base(common)
        {
            _notifyRepository = notifyRepository;
        }

        ///// <summary>
        ///// Control tìm kiếm nâng cao danh sách phân trang
        ///// </summary>
        ///// <returns></returns>
        //public Task<CommonViewInfo> GetBillingInvoicesFilter()
        //    => this.GetTableFilter("config_sp_res_billing_invoices_filter");

        ///// <summary>
        ///// Danh sách dữ liệu phân trang hiển thị ở lưới
        ///// </summary>
        ///// <param name="filter"></param>
        ///// <returns></returns>
        //public Task<CommonDataPage> GetBillingInvoicesPage(FilterBase filter)
        //    => base.GetDataListPageAsync("sp_res_billing_invoices_page", filter, objParams: null);

        ///// <summary>
        ///// Lưu thông tin Thêm/Sửa bản ghi
        ///// </summary>
        ///// <param name="inputData"></param>
        ///// <returns></returns>
        //public Task<BaseValidate> SetBillingInvoices(CommonViewInfo inputData)
        //    => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_invoices_set", inputData.ConvertToParam());

        ///// <summary>
        ///// Xóa bản ghi
        ///// </summary>
        ///// <param name="oid"></param>
        ///// <returns></returns>
        //public async Task<BaseValidate> SetBillingInvoicesDelete(List<Guid> arrOid)
        //    => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_invoices_del", new { ArrOid = string.Join(",", arrOid) });

        /// <summary>
        /// Form tạo hóa đơn hàng loạt
        /// </summary>
        /// <param name="periodsOid"></param>
        /// <returns></returns>
        public async Task<CommonViewInfo> GetBillingInvoicesFields(Guid periodsOid, ReceiptsBaseViewInfo receipts = null)
        {
            var objParam = receipts != null ? receipts.ToObject() : new { periods_oid = periodsOid };
            return await this.GetFieldsAsync<CommonViewInfo>("sp_res_billing_invoices_field", dynamicParam: null, objParam);
        }

        public async Task<BaseValidate> SetBillingInvoicesFields(ReceiptsBaseViewInfo receipts)
        {
            const string storedProcedure = "sp_res_invoices_create";
            return await GetMultipleAsync(storedProcedure,
                param =>
                {
                    param.Add("@projectCd", receipts.projectCd);
                    param.Add("@receiveIds", string.Join(",", receipts.receiveIds));
                    param.AddDynamicParams(receipts.ToObject());
                    return param;
                },
                async result =>
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

        public async Task<HomReceiptGet> SetBillingInvoicesReceipt(HomReceiptSet rec)
        {
            const string storedProcedure = "sp_Hom_Service_Receipt_Set";
            return await GetMultipleAsync<HomReceiptGet>(storedProcedure,
                param =>
                {
                    param.Add("@userId", base.CommonInfo.UserId);
                    param.Add("@ProjectCd", rec.ProjectCd);
                    param.Add("@ReceiptId", rec.ReceiptId);
                    param.Add("@ReceiptNo", rec.ReceiptNo);
                    param.Add("@ReceiptDate", rec.ReceiptDate);
                    param.Add("@ReceiveId", rec.ReceiveId);
                    param.Add("@ApartmentId", rec.ApartmentId);
                    param.Add("@CustId", rec.CustId);
                    param.Add("@TranferCd", rec.TranferCd);
                    param.Add("@Object", rec.Object);
                    param.Add("@PassNo", rec.PassNo);
                    param.Add("@PassDate", rec.PassDate);
                    param.Add("@PassPlc", rec.PassPlc);
                    param.Add("@Address", rec.Address);
                    param.Add("@Contents", rec.Contents);
                    param.Add("@Amount", rec.Amount);
                    param.Add("@Attach", "");
                    param.Add("@IsDBCR", 1);
                    param.Add("@IsDebit", rec.IsDebit);
                    param.Add("@AmtSubtractPoint", rec.SubtractPoint);
                    return param;
                },
                async result =>
                {
                    var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                    if (valid != null && valid.valid && valid.notiQue)
                    {
                        var notiTake = await result.ReadFirstOrDefaultAsync<AppNotifyTake>();
                        if (notiTake != null)
                        {
                            notiTake.appUsers = (await result.ReadAsync<PushNotifyUser>()).ToList();
                            await _notifyRepository.TakeNotification(notiTake);
                        }
                    }
                    return result.ReadFirstOrDefault<HomReceiptGet>();
                });
        }

        public async Task<BaseValidate> SetBillingInvoicesDelete(Model.Common.CommonDeleteMulti delids)
        {
            const string storedProcedure = "sp_res_receipt_dels";
            return await DeleteAsync(storedProcedure, new { receiveIds = string.Join(",", delids.Ids) });
        }
    }
}
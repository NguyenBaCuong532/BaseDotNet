using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Billing
{
    /// <summary>
    /// Chi tiết kỳ hóa đơn
    /// </summary>
    public class InvoicePeriodsDetailRepository : ResidentBaseRepository, IInvoicePeriodsDetailRepository
    {
        private readonly INotifyRepository _notifyRepository;

        public InvoicePeriodsDetailRepository(IResidentCommonBaseRepository common, INotifyRepository notifyRepository) : base(common)
        {
            _notifyRepository = notifyRepository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetInvoicePeriodsDetailFilter()
            => this.GetTableFilter("sp_res_service_receivable_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetInvoicePeriodsDetailPage(ServiceReceivableRequestModel query)
            => base.GetDataListPageAsync("sp_res_service_receivable_page",
                query,
                objParams: new
                {
                    query.ProjectCd,
                    query.isDateFilter,
                    query.ToDate,
                    query.StatusPayed,
                    query.IsBill,
                    query.IsPush,
                    query.InvoicePeriodOid
                });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetInvoicePeriodsDetailFields(Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_service_receive_entry_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetInvoicePeriodsDetail(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_receive_entry_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetInvoicePeriodsDetailDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_receive_entry_del", new { ArrOid = string.Join(",", arrOid) });

        public async Task<CommonViewInfo> GetCreateInvoiceFields()
            => await GetFieldsAsync<CommonViewInfo>("sp_res_service_receive_entry_invoice_field", new { tableKey = "filter_invoice_create" });

        public async Task<BaseValidate> SetCreateInvoiceFields(CommonViewInfo inputData)
        {
            //this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_receive_entry_set", inputData.ConvertToParam());
            try
            {
                //const string storedProcedure = "sp_res_invoices_create";
                const string storedProcedure = "sp_res_service_receive_entry_invoice_set";
                return await GetMultipleAsync(storedProcedure,
                    param =>
                    {
                        //param.Add("@projectCd", inputData.projectCd);
                        //param.Add("@receiveIds", string.Join(",", receipts.receiveIds));
                        return param;
                    },
                    readerHandler: async result =>
                    {
                        var data = result.ReadFirstOrDefault<BaseValidate>();
                        if (data.valid)
                        {
                            //var listId = receipts.receiveIds.Select(i => i.ToString()).ToList();
                            var listId = new List<string>();
                            var resSendToKafka = await _notifyRepository.SendToKafka(new PushNotifyRun() { action = "bill", ids = listId });
                            if (resSendToKafka.StatusCode != Constants.CodeStatusSuccess)
                            {
                                data.valid = false;
                                data.messages = resSendToKafka.Message;
                            }
                        }
                        return data;
                    });
            }
            catch (Exception ex)
            {
                return new BaseValidate { messages = ex.Message };
            }
        }
    }
}
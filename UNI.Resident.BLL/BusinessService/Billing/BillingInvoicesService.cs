using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Billing
{
    /// <summary>
    /// Kỳ thanh toán - Hóa đơn
    /// </summary>
    public class BillingInvoicesService : UniBaseService, IBillingInvoicesService
    {
        private readonly IBillingInvoicesRepository _repository;

        public BillingInvoicesService(IBillingInvoicesRepository repository)
        {
            _repository = repository;
        }

        ///// <summary>
        ///// Control tìm kiếm nâng cao danh sách phân trang
        ///// </summary>
        ///// <returns></returns>
        //public Task<CommonViewInfo> GetBillingInvoicesFilter()
        //    => _repository.GetBillingInvoicesFilter();

        ///// <summary>
        ///// Danh sách dữ liệu phân trang hiển thị ở lưới
        ///// </summary>
        ///// <param name="filter"></param>
        ///// <returns></returns>
        //public Task<CommonDataPage> GetBillingInvoicesPage(FilterBase filter)
        //    => _repository.GetBillingInvoicesPage(filter);

        ///// <summary>
        ///// Thông tin Thêm/Sửa bản ghi
        ///// </summary>
        ///// <param name="oid"></param>
        ///// <returns></returns>
        //public Task<viewBaseInfo> GetBillingInvoicesFields(Guid? oid)
        //    => _repository.GetBillingInvoicesFields(oid);

        ///// <summary>
        ///// Lưu thông tin Thêm/Sửa bản ghi
        ///// </summary>
        ///// <param name="inputData"></param>
        ///// <returns></returns>
        //public Task<BaseValidate> SetBillingInvoices(CommonViewInfo inputData)
        //    => _repository.SetBillingInvoices(inputData);

        ///// <summary>
        ///// Xóa bản ghi
        ///// </summary>
        ///// <param name="oid"></param>
        ///// <returns></returns>
        //public Task<BaseValidate> SetBillingInvoicesDelete(List<Guid> arrOid)
        //    => _repository.SetBillingInvoicesDelete(arrOid);

        public async Task<CommonViewInfo> GetBillingInvoicesFields(Guid periodsOid, ReceiptsBaseViewInfo receipts = null)
            => await _repository.GetBillingInvoicesFields(periodsOid, receipts);

        public async Task<BaseValidate> SetBillingInvoicesFields(ReceiptsBaseViewInfo receipts)
            => await _repository.SetBillingInvoicesFields(receipts);

        public async Task<HomReceiptGet> SetBillingInvoicesReceipt(HomReceiptSet bill)
            => await _repository.SetBillingInvoicesReceipt(bill);

        public async Task<BaseValidate> SetBillingInvoicesDelete(Model.Common.CommonDeleteMulti delids)
            => await _repository.SetBillingInvoicesDelete(delids);
    }
}
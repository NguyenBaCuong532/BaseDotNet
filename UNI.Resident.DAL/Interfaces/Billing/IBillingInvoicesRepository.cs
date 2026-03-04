using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IBillingInvoicesRepository : IResidentBaseRepository
    {
        //Task<CommonViewInfo> GetBillingInvoicesFilter();

        //Task<CommonDataPage> GetBillingInvoicesPage(FilterBase filter);

        //Task<BaseValidate> SetBillingInvoices(CommonViewInfo inputData);

        //Task<BaseValidate> SetBillingInvoicesDelete(List<Guid> arrOid);

        Task<CommonViewInfo> GetBillingInvoicesFields(Guid periodsOid, ReceiptsBaseViewInfo receipts = null);

        Task<BaseValidate> SetBillingInvoicesFields(ReceiptsBaseViewInfo receipts);

        Task<HomReceiptGet> SetBillingInvoicesReceipt(HomReceiptSet rec);

        Task<BaseValidate> SetBillingInvoicesDelete(Model.Common.CommonDeleteMulti delids);
    }
}
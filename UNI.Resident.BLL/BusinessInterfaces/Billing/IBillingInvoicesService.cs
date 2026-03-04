using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IBillingInvoicesService : IUniBaseService
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
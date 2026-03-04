using UNI.Model;
using UNI.Resident.Model.Receipt;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Resident.Model.Invoice;
using UNI.Resident.Model.Common;

namespace UNI.Resident.BLL.BusinessInterfaces.Invoice
{
    public interface IInvoiceService
    {
        Task<BaseValidate> CreateInvoicesAsync(ReceiptsBase receipts);
        Task<BaseValidate> DeleteAsync(long receiptId);
        Task<BaseValidate> DeleteMultiAsync(CommonDeleteMulti delids);
        Task<CommonViewInfo> GetInfoAsync(string type, long? id, decimal? remainamt);
        Task<CommonViewInfo> GetInfoDraftoAsync(CommonViewInfo form);
        Task<BaseValidate> PushNotifyAsync(ReceiptsBase receipts, string projectcode);
        Task<BaseValidate> PushRemindNotifyAsync(ReceiptsBase receipts, string projectcode);
        Task<CommonDataPage> GetInvoiceHistoryByApartmentIdPage(InvoiceRequestModel flt);
    }
}

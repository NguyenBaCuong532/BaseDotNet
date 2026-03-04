using UNI.Model;
using UNI.Resident.Model.Receipt;
using System.Threading.Tasks;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.Invoice;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Interfaces.Invoice
{
    public interface IInvoiceRepository
    {
        Task<BaseValidate> PushNotifyAsync(ReceiptsBase receipts, string projectcode);
        Task<BaseValidate> DeleteAsync(long receiptId);
        Task<BaseValidate> DeleteMultiAsync(CommonDeleteMulti delids);
        Task<CommonViewInfo> GetInfoAsync(string type, long? id, decimal? remainamt);
        Task<BaseValidate> CreateInvoicesAsync(ReceiptsBase receipts);
        Task<BaseValidate> PushRemindNotifyAsync(ReceiptsBase receipts, string projectcode);
        Task<CommonDataPage> GetInvoiceHistoryByApartmentIdPage(InvoiceRequestModel flt);
    }
}

using UNI.Resident.Model.Receipt;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using System.Collections.Generic;

namespace UNI.Resident.BLL.BusinessInterfaces.Invoice
{
    public interface IReceiptService
    {
        #region web-receipt
        //3. Các giao dịch của căn hộ
        // Giao dịch

        CommonViewInfo GetReceiptFilter(string userId);
        Task<CommonDataPage> GetReceiptPagev2(ReceiptRequestModel flt); 
        Task<ReceiptInfo> GetReceiptInfo(string ReceiptId);
        Task<BaseValidate> SetReceiptInfo(BaseCtrlClient client, ReceiptInfo info);

        Task<BaseValidate> DeleteReceiptInfo(int ReceiptId);
        Task<string> GetBillReceiptAsync(long receiptId);
        Task<CommonDataPage> GetReceiptByApartmentIdPage(ReceiptHistoryByApartmentIdModel flt);
        Task<ReceiptInfo> GetReceiptByApartmentInfo(int ApartmentId);
        Task<HomReceiptGet> SetReceipt(HomReceiptSet bill);
        Task<List<CommonValue>> GetPaymentAmountOptions(string receiveId);
        #endregion
    }
}

using Google.Apis.Drive.v3;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Invoice
{
    public class ReceiptService: IReceiptService
    {
        private readonly IReceiptRepository _repository;
        public ReceiptService(
            IReceiptRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }

        public CommonViewInfo GetReceiptFilter(string userId)
        {
            return _repository.GetReceiptFilter(userId);
        }
        public async Task<CommonDataPage> GetReceiptPagev2(ReceiptRequestModel flt)
        {
            return await _repository.GetReceiptPagev2(flt);
        }

        public Task<ReceiptInfo> GetReceiptInfo(string ReceiptId)
        {
            return _repository.GetReceiptInfo(ReceiptId);
        }

        public async Task<BaseValidate> SetReceiptInfo(BaseCtrlClient client, ReceiptInfo info)
        {
            return await _repository.SetReceiptInfo(client, info);
        }

        public async Task<BaseValidate> DeleteReceiptInfo(int ReceiptId)
        {
            return await _repository.DeleteReceiptInfo(ReceiptId);
        }

        public async Task<string> GetBillReceiptAsync(long receiptId)
        {
            var data = await _repository.GetServiceReceivableStreamAsync(receiptId, ReportType.pdf);
            if (data is null || data.stream is null)
            {
                return null;
            }
            else
            {
                GoogleDriverBaseService baseService = new GoogleDriverBaseService();
                DriveService driveService = baseService.GetService3();
                GoogleDriverHomeBillService _googleDriverService = new GoogleDriverHomeBillService();
                var result = _googleDriverService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 2,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType,
                    folderName = data.folderName,
                    dDate = data.dDate
                });
                await _repository.SetReceiptBillAsync(new ReceiptPrinting() { ReceiptId = receiptId, ReceiptBillUrl = result.WebContentLink, ReceiptBillViewUrl = result.WebViewLink });
                return result.WebViewLink;
            }
        }

        public async Task<CommonDataPage> GetReceiptByApartmentIdPage(ReceiptHistoryByApartmentIdModel flt)
        {
            return await _repository.GetReceiptByApartmentIdPage(flt);
        }

        public async Task<ReceiptInfo> GetReceiptByApartmentInfo(int ApartmentId)
        {
            return await _repository.GetReceiptByApartmentInfo(ApartmentId);
        }
        public Task<HomReceiptGet> SetReceipt(HomReceiptSet bill)
        {
            return _repository.SetReceipt(bill);
        }

        public Task<List<CommonValue>> GetPaymentAmountOptions(string receiveId)
        {
            return _repository.GetPaymentAmountOptions(receiveId);
        }
    }
}

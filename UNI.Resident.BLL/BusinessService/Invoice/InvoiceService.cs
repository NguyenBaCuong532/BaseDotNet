using UNI.Model;
using UNI.Resident.Model.Receipt;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Resident.Model.Invoice;
using UNI.Resident.DAL.Interfaces.Api;
using Microsoft.Extensions.Configuration;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.Model.Common;

namespace UNI.Resident.BLL.BusinessService.Invoice
{
    public class InvoiceService : IInvoiceService
    {
        private IInvoiceRepository _invoiceRepository;
       // private IApiKafkaRepository _kafkaRepository;
        private readonly IConfiguration _configuration;
        private readonly IReceiptRepository _receiptRepository;

        public InvoiceService(IInvoiceRepository invoiceRepository, IConfiguration configuration, IReceiptRepository receiptRepository)
        {
            _invoiceRepository = invoiceRepository;
            //_kafkaRepository = kafkaRepository;
            _configuration = configuration;
            _receiptRepository = receiptRepository;
        }
        public async Task<BaseValidate> PushNotifyAsync(ReceiptsBase receipts, string projectcode)
        {
            //var notifyTopic = _configuration.GetSection("Kafka:ProducerSettings:Topics:PublishInvoice").Value;
            //await _kafkaRepository.SendToKafka(topic: notifyTopic, receipts.SerializeToJson());
            return await _invoiceRepository.PushNotifyAsync(receipts, projectcode);
        }
        public Task<BaseValidate> PushRemindNotifyAsync(ReceiptsBase receipts, string projectcode)
        {
            return _invoiceRepository.PushRemindNotifyAsync(receipts, projectcode);
        }
        public Task<BaseValidate> DeleteAsync(long receiptId)
        {
            return _invoiceRepository.DeleteAsync(receiptId);
        }
        public Task<BaseValidate> DeleteMultiAsync(CommonDeleteMulti delids)
        {
            return _invoiceRepository.DeleteMultiAsync(delids);
        }
        public Task<CommonViewInfo> GetInfoAsync(string type, long? id, decimal? remainamt)
        {
            return _invoiceRepository.GetInfoAsync(type, id, remainamt);
        }

        public Task<BaseValidate> CreateInvoicesAsync(ReceiptsBase receipts)
        {
            return _invoiceRepository.CreateInvoicesAsync(receipts);
        }
        public async Task<CommonViewInfo> GetInfoDraftoAsync(CommonViewInfo form)
        {
            decimal.TryParse(form.GetValueByFieldName("amount"), out var amount);
            decimal.TryParse(form.GetValueByFieldName("total_amount"), out var totalAmount);

            // Lấy danh sách PaymentOption hiện tại
            var paymentOption = form.GetValueByFieldName("PaymentOption");

            // Nếu có chọn payment options → tính tổng lại
            if (!string.IsNullOrEmpty(paymentOption))
            {
                amount = 0;
                var listOption = paymentOption.Split(',');

                foreach (var item in listOption)
                {
                    if (decimal.TryParse(form.GetValueByFieldName(item), out var val))
                    {
                        amount += val;
                    }
                }
            }

            // Tính lại số tiền còn lại
            decimal remainAmount = totalAmount - amount;

            // Update vào form
            form.SetValueByFieldName("amount", amount.ToString());
            form.SetValueByFieldName("totalPrice", remainAmount.ToString());

            return form;
        }

        public Task<CommonDataPage> GetInvoiceHistoryByApartmentIdPage(InvoiceRequestModel flt)
        {
            return _invoiceRepository.GetInvoiceHistoryByApartmentIdPage(flt);
        }
    }
}

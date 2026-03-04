using Google.Apis.Drive.v3;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;
//using SSG.DAL.Interfaces;

namespace UNI.Resident.BLL.BusinessService.Invoice
{
    public class FeeServiceService : IFeeServiceService
    {
        private readonly IFeeServiceRepository _repository;
        
        public FeeServiceService(IFeeServiceRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }

        // Thông tin dịch vụ căn hộ : Phí dịch vụ + công tơ điện nước + đăng ký xe tháng + hợp đồng internet, truyền hình
        public async Task<ApartmentFeeInfo> GetApartmentFeeInfo(string ApartmentId)
        {
            return await _repository.GetApartmentFeeInfo(ApartmentId);
        }
        public async Task<ApartmentFeeInfo> SetApartmentFeeInfoDraft(ApartmentFeeInfo info)
        {
            return await _repository.SetApartmentFeeInfoDraft(info);
        }
        public async Task<BaseValidate> SetApartmentFeeInfo(ApartmentFeeInfo info)
        {
            return await _repository.SetApartmentFeeInfo(info);
        }
        // công tơ điện nước
        public async Task<CommonDataPage> GetServiceLivingPage(ServiceLivingRequestModel query)
        {
            return await _repository.GetServiceLivingPage(query);
        }
        public async Task<ServiceLivingInfo> GetServiceLivingInfo(int? LivingId)
        {
            return await _repository.GetServiceLivingInfo(LivingId);
        }

        public async Task<BaseValidate> SetServiceLivingInfo(ServiceLivingInfo info)
        {
            return await _repository.SetServiceLivingInfo(info);
        }
        public async Task<BaseValidate> DeleteServiceLiving(int? LivingId)
        {
            return await _repository.DeleteServiceLiving(LivingId);
        }

        public async Task<CommonDataPage> GetServiceCutHistoryPage(ServiceCutHistoryFilterModel query)
        {
            return await _repository.GetServiceCutHistoryPage(query);
        }
        public async Task<ServiceCutHistoryInfo> GetServiceCutHistoryInfo(string Id, string ApartmentId)
        {
            return await _repository.GetServiceCutHistoryInfo(Id, ApartmentId);
        }
        public async Task<BaseValidate> SetServiceCutHistoryInfo(ServiceCutHistoryInfo info)
        {
            return await _repository.SetServiceCutHistoryInfo(info);
        }
        public async Task<BaseValidate> DeleteServiceCutHistory(string Id)
        {
            return await _repository.DeleteServiceCutHistory(Id);
        }
        //hợp đồng internet, truyền hình
        public async Task<CommonDataPage> GetServiceExtendPage(ServiceExtendRequestModel query)
        {
            return await _repository.GetServiceExtendPage(query);
        }
        public async Task<ServiceExtendInfo> GetServiceExtendInfo(int? ExtendId)
        {
            return await _repository.GetServiceExtendInfo(ExtendId);
        }

        public async Task<BaseValidate> SetServiceExtendInfo(ServiceExtendInfo info)
        {
            return await _repository.SetServiceExtendInfo(info);
        }
        public async Task<BaseValidate> DeleteServiceExtend(int? ExtendId)
        {
            return await _repository.DeleteServiceExtend(ExtendId);
        }
        public CommonViewInfo GetServiceLivingMeterFilter(string userId)
        {
            return _repository.GetServiceLivingMeterFilter(userId);
        }
        public async Task<CommonDataPage> GetServiceLivingMeterPage(ServiceLivingMeterRequestModel query)
        {
            return await _repository.GetServiceLivingMeterPage(query);
        }

        public async Task<ServiceLivingMeterInfo> GetServiceLivingMeterInfo(int LivingId, int TrackingId)
        {
            return await _repository.GetServiceLivingMeterInfo(LivingId, TrackingId);
        }

        public async Task<BaseValidate> SetServiceLivingMeterInfo(ServiceLivingMeterInfo info)
        {
            return await _repository.SetServiceLivingMeterInfo(info);
        }

        public async Task<BaseValidate> DeleteServiceLivingMeter(int trackingId)
        {
            return await _repository.DeleteServiceLivingMeter(trackingId);
        }

        public async Task<BaseValidate> SetServiceLivingMeterCalculates(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
        {
            return await _repository.SetServiceLivingMeterCalculates(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
        }

        public async Task<ServiceLivingMeterCalculatorInfo> GetServiceLivingMeterCalculatorInfo(int trackingId)
        {
            return await _repository.GetServiceLivingMeterCalculatorInfo(trackingId);
        }

        public async Task<BaseValidate> SetServiceLivingMeterCalculates2(ServiceLivingMeterCalculatorInfo info)
        {
            return await _repository.SetServiceLivingMeterCalculates2(info);
        }
        public async Task<BaseValidate> SetServiceLivingMeterCalculates3(ServiceLivingMeterCalculatorInfo info)
        {
            return await _repository.SetServiceLivingMeterCalculates3(info);
        }

        public async Task<BaseValidate> DelMultiServiceLivingMeter(DeleteMultiServiceLivingMeter deleteMultiService)
        {
            return await _repository.DelMultiServiceLivingMeter(deleteMultiService);
        }
        public CommonViewInfo GetServiceExpectedFilter(string userId)
        {
            return _repository.GetServiceExpectedFilter(userId);
        }

        public async Task<CommonDataPage> GetServiceExpectedPage(ServiceExpectedRequestModel query)
        {
            return await _repository.GetServiceExpectedPage(query);
        }

        public async Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? ApartmentId, string projectCd)
        {
            return await _repository.GetServiceExpectedCalculatorInfo(ApartmentId, projectCd);
        }

        public async Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info)
        {
            return await _repository.SetServiceExpectedCalculatorInfo(info);
        }

        public async Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            return await _repository.GetServiceExpectedDetailsInfo(receiveId);
        }

        public async Task<CommonDataPage> GetServiceExpectedFeePage(ServiceExpectedFeeRequestModel query)
        {
            return await _repository.GetServiceExpectedFeePage(query);
        }

        public async Task<CommonDataPage> GetServiceExpectedVehiclePage(ServiceExpectedVehicleRequestModel query)
        {
            return await _repository.GetServiceExpectedVehiclePage(query);
        }

        public async Task<ServiceExpectedLivingPage> GetServiceExpectedLivingPage(ServiceExpectedLivingRequestModel query)
        {
            return await _repository.GetServiceExpectedLivingPage(query);
        }

        public async Task<CommonDataPage> GetServiceExpectedExtendPage(ServiceExpectedExtendRequestModel query)
        {
            return await _repository.GetServiceExpectedExtendPage(query);
        }

        public async Task<BaseValidate> DeleteServiceExpected(int receivableId)
        {
            return await _repository.DeleteServiceExpected(receivableId);
        }

        public async Task<ServiceExpectedReceivableExtendInfo> GetServiceExpectedReceivableExtendInfo(int receiveId)
        {
            return await _repository.GetServiceExpectedReceivableExtendInfo(receiveId);
        }

        public async Task<BaseValidate> SetServiceExpectedReceivableExtendInfo(ServiceExpectedReceivableExtendInfo info)
        {
            return await _repository.SetServiceExpectedReceivableExtendInfo(info);
        }

        public CommonViewInfo GetServiceReceivableFilter(string userId)
        {
            return _repository.GetServiceReceivableFilter(userId);
        }

        public async Task<CommonDataPage> GetServiceReceivablePage(ServiceReceivableRequestModel query)
        {
            return await _repository.GetServiceReceivablePage(query);
        }

        public async Task<ServiceReceivableInfo> GetServiceReceivableInfo(int? receiveId)
        {
            return await _repository.GetServiceReceivableInfo(receiveId);
        }
        public async Task<string> SetServiceReceivableBill(ServiceReceivableBill bill)
        {
            var data = await _repository.ApartmentFeeStream(ReportType.pdf, bill.ReceiveId);
            Google.Apis.Storage.v1.Data.Object pathfile = null;
            var pfile = $"Bill/{data.folderName}/{DateTime.Now.ToString("yyyyMM")}/{data.fileName}-{bill.ReceiveId}.pdf";

            if (data != null && data.stream != null)
            {
                pathfile = await FireBaseServices.UploadFile(data.stream, $"{pfile}", app: "s-service");
                var urlfile = pathfile.MediaLink.Replace("https://storage.googleapis.com/download/storage/v1/b/sunshine-app-production.appspot.com/o/", "https://cdn.sunshineapp.vn/");
                bill.BillUrl = urlfile; //result.WebContentLink;
                bill.BillViewUrl = urlfile; // result.WebViewLink;
                await _repository.SetServiceReceivableBill(bill);
                return bill.BillUrl;
            }
            else
            {
                return null;
            }
        }

        public async Task<string> SetServiceReceivableBillNew(ServiceReceivableBill bill)
        {
            var data = await _repository.ApartmentFeeStreamNew(ReportType.pdf, bill.ReceiveId);
            Google.Apis.Storage.v1.Data.Object pathfile = null;
            var pfile = $"Bill/{data.folderName}/{DateTime.Now.ToString("yyyyMM")}/{data.fileName}-{bill.ReceiveId}.pdf";

            if (data != null && data.stream != null)
            {
                var bucket = "sunshine-app-production.appspot.com";
                pathfile = await FireBaseServices.UploadFile(data.stream, $"{pfile}", app: "s-service", bucket: bucket);
                var urlfile = pathfile.MediaLink.Replace("https://storage.googleapis.com/download/storage/v1/b/sunshine-app-production.appspot.com/o/", "https://cdn.sunshineapp.vn/");
                bill.BillUrl = urlfile; //result.WebContentLink;
                bill.BillViewUrl = urlfile; // result.WebViewLink;
                await _repository.SetServiceReceivableBill(bill);
                return bill.BillUrl;
            }
            else
            {
                return null;
            }
        }

 

        public ggDriverFileDownload SetReceiveMoneyServiceGDrive(long receiptId)
        {
            var data = _repository.GetServiceReceivableStream(receiptId, ReportType.pdf);
            data.mimeType = "application/vnd.google-apps.spreadsheet";

            if (data.stream is null)
            {
                return null;
            }
            else
            {
                GoogleDriverBaseService baseService = new GoogleDriverBaseService();
                DriveService driveService = baseService.GetService3();
                GoogleDriverHomeBillService _googleDriverService = new GoogleDriverHomeBillService();
                var result = _googleDriverService.UploadBilFile(driveService, data);
                return result;
            }
        }
        #region import-reg
        public async Task<BaseValidate<Stream>> GetLivingImportTemp(int livingTypeId)
        {
            try
            {
                //var ds = await _repository.GetLivingImportTemp(livingTypeId);
                var r = new FlexcellUtils();
                var template = await System.IO.File.ReadAllBytesAsync($"templates/living/import_living.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, new DataSet(), p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }
        public async Task<ImportListPage> SetLivingImport(LivingImportSet organizes, bool? check)
        {
            return await _repository.SetLivingImport(organizes, check);
        }

        public async Task<BaseValidate<Stream>> GetDebitAmtImportTemp()
        {
            try
            {
                var r = new FlexcellUtils();
                var template = await System.IO.File.ReadAllBytesAsync($"templates/fee/mau_ton_no_cu_import.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, new DataSet(), p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> SetDebitAmtImport(DebitAmtImportSet debitAmtImport, bool v)
        {
            return _repository.SetDebitAmtImport(debitAmtImport, v);
        }

        public async Task<BaseValidate<Stream>> GetPaymentImportTemp()
        {
            try
            {
                var r = new FlexcellUtils();
                var template = await System.IO.File.ReadAllBytesAsync($"templates/fee/payment_import_template.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, new DataSet(), p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> SetPaymentImport(PaymentImportSet paymentImport, bool v)
        {
            return _repository.SetPaymentImport(paymentImport, v);
        }

        public async Task<BaseValidate<Stream>> GetTotalAmtImportTemp()
        {
            try
            {
                var r = new FlexcellUtils();
                var template = await System.IO.File.ReadAllBytesAsync($"templates/fee/import_Total_Amt.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, new DataSet(), p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> SetTotalAmtImport(TotalAmtImportSet totalAmtImport, bool v)
        {
            return _repository.SetTotalAmtImport(totalAmtImport, v);
        }


        #endregion import-reg

        #region setting price
        public async Task<CommonDataPage> GetServiceLivingPricePage(FilterProjectliving flt)
        {
            return await _repository.GetServiceLivingPricePage(flt);
        }
        #endregion setting price    
    }
}

using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Data;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces.Invoice
{
    public interface IFeeServiceRepository : IUniBaseRepository
    {
        #region web-feeService

        //2. Thông tin dịch vụ căn hộ : Phí dịch vụ + công tơ điện nước + đăng ký xe tháng + hợp đồng internet, truyền hình
        Task<ApartmentFeeInfo> GetApartmentFeeInfo(string ApartmentId);
        Task<ApartmentFeeInfo> SetApartmentFeeInfoDraft(ApartmentFeeInfo info);
        Task<BaseValidate> SetApartmentFeeInfo(ApartmentFeeInfo info);
        // Công tơ điện nước
        Task<CommonDataPage> GetServiceLivingPage(ServiceLivingRequestModel query);
        Task<ServiceLivingInfo> GetServiceLivingInfo(int? LivingId);
        Task<BaseValidate> SetServiceLivingInfo(ServiceLivingInfo info);
        Task<BaseValidate> DeleteServiceLiving(int? LivingId);
        Task<CommonDataPage> GetServiceCutHistoryPage(ServiceCutHistoryFilterModel query);
        Task<ServiceCutHistoryInfo> GetServiceCutHistoryInfo(string Id, string ApartmentId);
        Task<BaseValidate> SetServiceCutHistoryInfo(ServiceCutHistoryInfo info);
        Task<BaseValidate> DeleteServiceCutHistory(string Id);
        // đăng ký xe tháng
        //Task<VehicleFeePage> GetVehicleFeePage(VehicleFeeRequestModel query);
        //Task<VehicleFeeInfo> GetVehicleFeeInfo(string LivingId);
        //Task<BaseValidate> SetVehicleFeeInfo(VehicleFeeInfo info);
        //Task<BaseValidate> DeleteVehicleFee(string CardCd);
        //hợp đồng internet, truyền hình
        Task<CommonDataPage> GetServiceExtendPage(ServiceExtendRequestModel query);
        Task<ServiceExtendInfo> GetServiceExtendInfo(int? extendId);
        Task<BaseValidate> SetServiceExtendInfo(ServiceExtendInfo info);
        Task<BaseValidate> DeleteServiceExtend(int? extendId);
        // Chỉ số công tơ điện - chỉ số công tơ nước
        CommonViewInfo GetServiceLivingMeterFilter(string userId);
        Task<CommonDataPage> GetServiceLivingMeterPage(ServiceLivingMeterRequestModel query);
        Task<ServiceLivingMeterInfo> GetServiceLivingMeterInfo(int LivingId, int TrackingId);
        Task<BaseValidate> SetServiceLivingMeterInfo(ServiceLivingMeterInfo info);
        Task<BaseValidate> DeleteServiceLivingMeter(int trackingId);
        Task<BaseValidate> SetServiceLivingMeterCalculates(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear);
        Task<ServiceLivingMeterCalculatorInfo> GetServiceLivingMeterCalculatorInfo(int trackingId);
        Task<BaseValidate> SetServiceLivingMeterCalculates2(ServiceLivingMeterCalculatorInfo info);
        Task<BaseValidate> SetServiceLivingMeterCalculates3(ServiceLivingMeterCalculatorInfo info);

        // Dự thu
        CommonViewInfo GetServiceExpectedFilter(string userId);
        Task<CommonDataPage> GetServiceExpectedPage(ServiceExpectedRequestModel query);
        Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? ApartmentId, string projectCd);
        Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info);
        Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId); // Chi tiết dự thu
        Task<CommonDataPage> GetServiceExpectedFeePage(ServiceExpectedFeeRequestModel query);// ds dự thu dịch vụ
        Task<CommonDataPage> GetServiceExpectedVehiclePage(ServiceExpectedVehicleRequestModel query);// ds dự thu gửi xe
        Task<ServiceExpectedLivingPage> GetServiceExpectedLivingPage(ServiceExpectedLivingRequestModel query);// ds dự thu điện nước
        Task<CommonDataPage> GetServiceExpectedExtendPage(ServiceExpectedExtendRequestModel query);// ds dự thu dịch vụ khác
        Task<BaseValidate> DeleteServiceExpected(int receivableId);
        Task<ServiceExpectedReceivableExtendInfo> GetServiceExpectedReceivableExtendInfo(int receiveId);// form thêm dự thu dịch vụ khác
        Task<BaseValidate> SetServiceExpectedReceivableExtendInfo(ServiceExpectedReceivableExtendInfo info);// thêm dự thu dịch vụ khác
        // Hóa đơn
        CommonViewInfo GetServiceReceivableFilter(string userId);
        Task<CommonDataPage> GetServiceReceivablePage(ServiceReceivableRequestModel query);
        Task<ServiceReceivableInfo> GetServiceReceivableInfo(int? receiveId);// Chi tiết hóa đơn
        Task<int> SetServiceReceivableBill(ServiceReceivableBill bill);// Tạo hóa đơn
        Task<ggDriverFileStream> ApartmentFeeStream(ReportType reportType, long receiveId);
        Task<ggDriverFileStream> ApartmentFeeStreamNew(ReportType reportType, long receiveId);
       
        ggDriverFileStream GetServiceReceivableStream(long receiptId, ReportType reportType);
        #endregion
        #region import-reg
        Task<DataSet> GetLivingImportTemp(int livingTypeId);
        Task<ImportListPage> SetLivingImport(LivingImportSet organizes, bool? check);
        Task<BaseValidate> DelMultiServiceLivingMeter(DeleteMultiServiceLivingMeter deleteMultiService);
        Task<ImportListPage> SetDebitAmtImport(DebitAmtImportSet debitAmtImport, bool v);
        Task<ImportListPage> SetPaymentImport(PaymentImportSet paymentImport, bool v);
        Task<ImportListPage> SetTotalAmtImport(TotalAmtImportSet totalAmtImport, bool v);
        #endregion import-reg

        #region setting price
        Task<CommonDataPage> GetServiceLivingPricePage(FilterProjectliving flt);
        #endregion setting price

    }
}

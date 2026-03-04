using UNI.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace UNI.Resident.Model.Resident
{
    //public class ServiceLiving
    //{
    //}
    // Dịch vụ điện nước
    //public class ServiceLivingPage : viewBasePage<object>
    //{

    //}
    public class ServiceLivingInfo : viewBaseInfo
    {
        public int? LivingId { get; set; }
    }

    public class ServiceLivingRequestModel : FilterBase
    {
        public string ApartmentId { get; set; }
    }
    // Chỉ số công tơ điện - nước
    //public class ServiceLivingMeterPage : viewBasePage<object>
    //{

    //}
    public class ServiceLivingMeterInfo : viewBaseInfo
    {
        public int LivingId { get; set; }
        public int TrackingId { get; set; }
        public Guid PeriodsOid { get; set; }
    }

    public class ServiceLivingMeterRequestModel : FilterBase
    {
        public string livingType { get; set; }
        public string projectCd { get; set; }
        public int? month { get; set; }
        public int? year { get; set; }
        public Guid? PeriodsOid { get; set; }
    }
    public class ServiceLivingMeterCalculatorInfo : viewBaseInfo
    {
        public int TrackingId { get; set; }
        public string LivingType { get; set; }
        public Guid? PeriodsOid { get; set; }
    }
    // Dự toán
    //public class ServiceExpectedPage : viewBasePage<object>
    //{
    //}
    public class ServiceExpectedRequestModel : FilterBase
    {
        public Guid PeriodsOid { get; set; }
        public string ProjectCd { get; set; }
        public string ToDate { get; set; }
        public int IsCalculated { get; set; }
    }
    public class ServiceExpectedCalculatorInfo: viewBaseInfo
    {
        public string Apartments { get; set; }
        public List<viewGridFlex> apartment_gridflexs { get; set; }
        public ResponseList<List<object>> apartment_dataList { get; set; }
    }
    public class ServiceExpectedDetailsInfo : viewBaseInfo
    {
        public int ReceiveId { get; set; }
    }
    //public class ServiceExpectedFeePage : viewBasePage<object>
    //{
    //}
    public class ServiceExpectedFeeRequestModel : FilterBase
    {
        public int ReceiveId { get; set; }
    }
    //public class ServiceExpectedVehiclePage : viewBasePage<object>
    //{
    //}
    public class ServiceExpectedVehicleRequestModel : FilterBase
    {
        public int ReceiveId { get; set; }
        public string ProjectCd { get; set; }
    }
    public class ServiceExpectedLivingPage : viewBasePage<object>
    {
        public List<viewGridFlex> gridflexLivingDetails { get; set; }
        //public List<ServiceExpectedLivingDetail> livingDetails { get; set; }
    }
    public class ServiceExpectedLivingRequestModel : FilterBase
    {
        public int ReceiveId { get; set; }   
    }
    public class ServiceExpectedLiving
    {
        public int ReceivableId { get; set; }
        public int ReceiveId { get; set; }
        public int ServiceTypeId { get; set; }
        public string ServiceObject { get; set; }
        public int Amount { get; set; }
        public int VatAmt { get; set; }
        public int TotalAmt { get; set; }
        public string fromDt { get; set; }
        public string ToDate { get; set; }
        public int TrackingId { get; set; }
        public string LivingTypeName { get; set; }
        public string MeterSerial { get; set; }
        public int FromNum { get; set; }
        public int ToNum { get; set; }
        public int TotalNum { get; set; }
        public int LivingTypeId { get; set; }
        public decimal Price { get; set; }
        public decimal Quantity { get; set; }

        public List<ServiceExpectedLivingDetail> livingDetails { get; set; }
    }
    public class ServiceExpectedLivingDetail
    {
        public long Id { get; set; }
        public long TrackingId { get; set; }
        public int StepPos { get; set; }
        public int fromN { get; set; }
        public int toN { get; set; }
        public long Quantity { get; set; }
        public long Price { get; set; }
        public long Amount { get; set; }
        public string from_dt { get; set; }

    }
    //public class ServiceExpectedExtendPage : viewBasePage<object>
    //{
    //}
    public class ServiceExpectedExtendRequestModel : FilterBase
    {
        public int ReceiveId { get; set; }
    }
    public class ServiceExpectedReceivableExtendInfo : viewBaseInfo
    {
        public int ReceiveId { get; set; }
    }
    // Hóa đơn
    //public class ServiceReceivablePage : viewBasePage<object>
    //{
    //}
    public class ServiceReceivableRequestModel : FilterBase
    {
        public string ProjectCd { get; set; }
        public bool isDateFilter { get; set; }
        public string ToDate { get; set; }
        public int? StatusPayed { get; set; }
        public int? IsBill { get; set; }
        public int? IsPush { get; set; }
        public Guid? InvoicePeriodOid { get; set; }
    }
    public class ServiceReceivableInfo : viewBaseInfo
    {
        public int? ReceiveId { get; set; }
        public string QrPayment { get; set; }
    }
    public class ServiceReceivableBill
    {
        public long ReceiveId { get; set; }
        public string BillUrl { get; set; }
        public string BillViewUrl { get; set; }
        public bool overwrite { get; set; }
        public bool RunNewVersion { get; set; }
    }
    public static class ResServiceReport
    {
        public const string BILL_TEMPLATE = "s_service_report_fee.xlsx";
        public const string BILL_TEMPLATE_NEW = "s_service_report_fee_new.xlsx";
        public const string BILL_TEMPLATE_CENTER = "s_service_report_fee_new_center.xlsx";
        public const string BILL_TEMPLATE_HCM = "s_service_report_fee_new_diamond_river.xlsx";
        public const string RECEIVE_MONEY_TEMPLATE = "01_TT_Phieu_thu.xlsx";
    }
    public static class FolderResServiceReport
    {
        public const string FOLDER_TEMPLATE = "Reports";
    }

    public class ServiceCutHistoryFilterModel : FilterBase
    {
        public string ApartmentId { get; set; }
    }

    public class ServiceCutHistoryInfo : viewBaseInfo
    {
        public string ApartmentId { get; set; }
        public string Id { get; set; }
    }
}

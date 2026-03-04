using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomReceivable
    {
        public int ReceiveId { get; set; }
        public string PeriodMonth { get; set; }
        public string PeriodYear { get; set; }
        public string ReceivableDate { get; set; }
        public decimal TotalAmt { get; set; }
        public string ExpireDate { get; set; }
        public string fromDate { get; set; }
        public string toDate { get; set; }
        public bool IsPayed { get; set; }
        public string StatusPayed { get; set; }
        public string Remark { get; set; }
        public string FullName { get; set; }
        public string RoomCode { get; set; }
        public long CommonFee { get; set; }
        public long VehicleAmt { get; set; }
        public long LivingAmt { get; set; }
        public long ExtendAmt { get; set; }
        public decimal DebitAmt { get; set; }
        public decimal DebitAmtAnother { get; set; }
        public decimal TotalBill { get; set; }
        public string DebitAmtText { get; set; }
        public string RefundAmtText { get; set; }
        public decimal RefundAmt { get; set; }
    }
    public class HomFollowDebit
    {
        public int ApartmentId { get; set; }
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string BuildingName { get; set; }
        public string RoomCode { get; set; }
        public int Floor { get; set; }
        public float WaterwayArea { get; set; }
        public string CifNo { get; set; }
        public string FullName { get; set; }
        public string FamilyImageUrl { get; set; }

        public int PeriodMonth { get; set; }
        public int PeriodYear { get; set; }
        public int F_CreditAmt { get; set; }
        public int CurrAmt { get; set; }
        public int DebitAmt { get; set; }
        public string PayDate { get; set; }
    }
    public class HomPayService
    {
        public int ReceiveId { get; set; }
        public int ServiceTypeId { get; set; }
        public string ServiceTypeName { get; set; }
        public string ServiceObject { get; set; }
        public decimal Amount { get; set; }
        public decimal NetAmount { get; set; }
        public bool IsFree
        {
            get
            {
                if (this.NetAmount == 0)
                    return true;
                else
                    return false;
            }
        }

    }
    public class HomPayTransaction
    {
        public int PayId { get; set; }
        public int CardId { get; set; }
        public int Amount { get; set; }
        public string Note { get; set; }
    }

    public class HomCalculateService
    {
        public int month { get; set; }
        public int year { get; set; }
        public int overwrite { get; set; }
        public string projectCd { get; set; }
        public string ServiceTypeId { get; set; }
    }

    public class HomPayBill
    {
        public int PayRegBillId { get; set; }
        public int BillMonth { get; set; }
        public int BillYear { get; set; }
        public string RegDate { get; set; }
        public List<HomPayBillUrl> BillsUrl { get; set; }
    }
    public class HomPayBillUrl
    {
        internal int PayRegBillId { get; set; }
        public string BillTitle { get; set; }
        public int PayServiceId { get; set; }
        public string BillUrl { get; set; }
        public bool IsUsed { get; set; }
    }
    public class HomPayBillUrlSet
    {
        public int PayRegBillId { get; set; }
        public List<HomPayBillUrl> PayBillUrls { get; set; }
    }
    public class HomServiceBill
    {
        public long ReceiveId { get; set; }
        public string BillUrl { get; set; }
        public string BillViewUrl { get; set; }
        public bool overwrite { get; set; }
    }
    public class HomServiceReceiptBill
    {
        public long ReceiptId { get; set; }
        public string ReceiptBillUrl { get; set; }
        public string ReceiptBillViewUrl { get; set; }
        public bool overwrite { get; set; }
    }
    //[FirestoreData]
    //public class HomServiceBillEvent
    //{
    //    [FirestoreProperty(Name = "receive_id")]
    //    public long receiveId { get; set; }
    //    [FirestoreProperty(Name = "receive_bill_status")]
    //    public bool receiveBillStatus { get; set; }
    //}

    public class HomPaymentGet: HomReceivable
    {

        public HomPaymentApartmentFee apartmentFee { get; set; }
        public List<HomPaymentServiceVehicle> ServiceVehicle { get; set; }
        public List<HomPaymentServiceLiving> ServiceLiving { get; set; }
        public List<HomPaymentServiceExtend> ServiceExtend { get; set; }
    }
    public class HomPaymentApartmentFee
    {
        public long ReceivableId { get; set; }
        public long ReceiveId { get; set; }
        public string ServiceObject { get; set; }
        public double WaterwayArea { get; set; }
        public double Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Amount { get; set; }
        public decimal VatAmt { get; set; }
        public decimal TotalAmt { get; set; }
        public string fromDt { get; set; }
        public string toDt { get; set; }
        public string RoomCode { get; set; }
   
       
    }
   
    public class HomPaymentServiceLiving
    {
        public long ReceivableId { get; set; }
        public long TrackingId { get; set; }
        public string ToDate { get; set; }
        public int LivingTypeId { get; set; }
        public string LivingTypeName { get; set; }
        public string MeterSerial { get; set; }
        public int FromNum { get; set; }
        public int ToNum { get; set; }
        public int TotalNum { get; set; }
        public decimal Quantity { get; set; }
        public decimal Price { get; set; }
        public long Amount { get; set; }
        public long VatAmt { get; set; }
        public long NtshAmt { get; set; }
        public decimal DiscountAmt { get; set; }
        public decimal TotalAfterDiscountAmt { get; set; }
        public long TotalAmt { get; set; }
        public List<HomServiceLivingCalSheet> calSheets { get; set; }
    }
    public class HomPaymentServiceExtend
    {
        public long ReceivableId { get; set; }
        public string ServiceObject {get;set;}
        public long ExtendId { get; set; }
        public string ContractTypeName { get; set; }
        public string ContractNo { get; set; }
        public string ContractDate { get; set; }
        public string ProviderName { get; set; }
        public decimal Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Amount { get; set; }
        public decimal VatAmt { get; set; }
        public decimal TotalAmt { get; set; }
        public string ToDate { get; set; }
        public string DeviceSerial { get; set; }
        public string ContractUser { get; set; }
        public string ToDt { get; set; }
        //public decimal VatAmt { get; set; }
    }
    public class HomPaymentServiceVehicle
    {
        public long ReceivableId { get; set; }
        public long CardVehicleId { get; set; }
        public int VehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public string VehicleName { get; set; }
        public int VehicleNum { get; set; }
        public int Quantity { get; set; }
        public int Price { get; set; }
        public int Amount { get; set; }
        public long VatAmt { get; set; }
        public long TotalAmt { get; set; }
        public string fromDt { get; set; }
        public string toDt { get; set; }
        public bool? isCharginFee { get; set; }
    }
    public class HomServiceLivingCalSheet
    {
        public long Id { get; set; }
        public long TrackingId { get; set; }
        public int StepPos { get; set; }
        public int fromN { get; set; }
        public int toN { get; set; }
        public long Quantity { get; set; }
        public long Price { get; set; }
        public long Amount { get; set; }

    }
    public class HomBillDataResult
    {
        public string billNo { get; set; }
        public string url { get; set; }
        public string message { get; set; }

    }
    public class HomTransferInfo
    {
        public long receiveId { get; set; }
        public decimal TotalAmt { get; set; }
        public string receiveContent { get; set; }
        public string address { get; set; }
        public string timeWorking { get; set; }
        public string investorName { get; set; }
        public string projectName { get; set; }
        public string bank_acc_no { get; set; }
        public string bank_acc_name { get; set; }
        public string bank_branch { get; set; }
        public string bank_name { get; set; }
    }
}

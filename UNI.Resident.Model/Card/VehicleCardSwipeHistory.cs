using System;
using System.Text.Json.Serialization;
using UNI.Resident.Model.Common;

namespace UNI.Resident.Model.Card
{
    /// <summary>
    /// Model for vehicle card swipe history filter
    /// </summary>
    public class VehicleCardSwipeHistoryFilter : GridProjectFilter
    {
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public int? VehicleTypeId { get; set; }
        public int? Status { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class VehicleCardSwipeHistoryItem
    {
        public long LogId { get; set; } 
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public int? VehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
        public DateTime SwipeTime { get; set; }
        public string SwipeTimeStr { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
        public string Notes { get; set; }
        public int? CardId { get; set; }
        public int? CardVehicleId { get; set; }
        public int? StationId { get; set; }
        public string StationName { get; set; }
    }

    /// <summary>
    /// Model for vehicle card history filter (Lịch sử thẻ)
    /// </summary>
    public class VehicleCardHistoryFilter : GridProjectFilter
    {
        public int? ActionType { get; set; }
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public int? VehicleTypeId { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class VehicleCardHistoryItem
    {
        public long HistoryId { get; set; }
        public int ActionType { get; set; }
        public string ActionTypeName { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public int? VehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
        public string OldCardCode { get; set; }
        public string NewCardCode { get; set; }
        public string OldOwner { get; set; }
        public string NewOwner { get; set; }
        public string VehicleNo { get; set; }
        public string Operator { get; set; }
        public string ActionTime { get; set; }
        public string ActionTimeStr { get; set; }
        public string Notes { get; set; }
    }

    /// <summary>
    /// Model for vehicle card payment history filter (Lịch sử thanh toán thẻ xe)
    /// </summary>
    public class VehicleCardPaymentHistoryFilter : GridProjectFilter
    {
        public int? CardVehicleId { get; set; }
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public int? VehicleTypeId { get; set; }
        public int? PaymentStatus { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class VehicleCardPaymentHistoryItem
    {
        public int TransactionCode { get; set; }
        public decimal Amount { get; set; }
        public DateTime? PaymentDate { get; set; }
        public string PaymentDateStr { get; set; }
        public int? PaymentStatus { get; set; }
        public string PaymentStatusName { get; set; }
        public DateTime? StartDate { get; set; }
        public string StartDateStr { get; set; }
        public DateTime? EndDate { get; set; }
        public string EndDateStr { get; set; }
        public string PeriodName { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string CreatedDateStr { get; set; }
        public string CreatedDateStrFull { get; set; }
        public string Operator { get; set; }
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public int? VehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
        public int? CardVehicleId { get; set; }
        public string Remark { get; set; }
    }
}


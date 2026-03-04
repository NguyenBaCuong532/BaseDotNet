using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Resident
{
    
    public class FamilyCardInfo : viewBaseInfo
    {
        public string cardCd { get; set; }
    }

    public class FamilyCardRequestModel : FilterBase
    {
        public string ApartmentId { get; set; }
        /// <summary>Oid căn hộ (ưu tiên nếu có)</summary>
        public Guid? apartOid { get; set; }
    }
    // Thêm mới thẻ: thẻ xe, thẻ căn hộ, thẻ tín dụng
    public class CardInfoV2 : viewBaseInfo
    {
        public string RoomCd { get; set; }
    }
    // Thẻ xe
   
    public class VehicleCardInfo : viewBaseInfo
    {
        public int? CardVehicleId { get; set; }
    }

    public class VehicleCardRequestModel : FilterBase
    {
        public string CardCd { get; set; }
    }

    public class CardVehicle_CardReturnRequest
    {
        public int CardVehicleId { get; set; }

        public string CardReturnDate { get; set; }
    }

    public class VehicleHistoryChange : FilterBase
    {
        public int CardId { get; set; }
        /// <summary>Oid thẻ (ưu tiên nếu có)</summary>
        public Guid? cardOid { get; set; }
    }
    // Xe cư dân
   
    public class ResidentVehicleRequestModel : FilterBase
    {
        public string ProjectCd { get; set; }
        public int? Statuses { get; set; }
        public int? VehicleTypeId { get; set; }
        public int IsFilterDate { get; set; }
        public string EndDate { get; set; }
    }
    // Thẻ cư dân
   
    public class FilterCardResident : FilterBase
    {
        public string ProjectCd { get; set; }
        public string apartmentId { get; set; }
        /// <summary>Oid căn hộ (ưu tiên nếu có)</summary>
        public Guid? apartOid { get; set; }
        /// <summary>Oid thẻ (lọc theo thẻ khi có)</summary>
        public Guid? cardOid { get; set; }
        public string RoomCd { get; set; }
        //public int Statuses { get; set; }
        public int Statuses { get; set; }
        //public int vehicle { get; set; }
        public int isVehicle { get; set; }
    }
    // Thẻ lượt    
    public class VehicleCardDailyRequestModel : FilterBase
    {
        public string ProjectCd { get; set; }
        public int? Statuses { get; set; }
    }

    public class VehicleLockRequest
    {
        public int CardVehicleId { get; set; }
        /// <summary>Khóa logic (MAS_CardVehicle.oid). Ưu tiên khi có.</summary>
        public Guid? CardVehicleOid { get; set; }
        public int Status { get; set; }
        public string Reason { get; set; }
        public bool IsHardLock { get; set; }
    }

   
    public class VehiclePaymentLoadFormInfo : viewBaseInfo
    {
        public int CardVehicleId { get; set; }
        public Guid? PaymentId { get; set; }
        public string StartDate { get; set; }
        public string? SelectedFirstMonthPaymentMethod { get; set; }
        public List<PaymentMethodOption> FirstMonthPaymentMethods { get; set; } = new();
        public VehicleCardInfo VehicleCardInfo { get; set; }
    }

    public class PaymentMethodOption
    {
        public string Code { get; set; }
        public string Name { get; set; }
    }
    public class VehiclePaymentSubmitRequest : viewBaseInfo
    {
        public int CardVehicleId { get; set; }
        public string StartDate { get; set; }
        public string FirstMonthPaymentMethod { get; set; }
    }

    public static class FirstMonthPaymentMethodConst
    {
        public const string PAY_NOW = "PAY_NOW";
        public const string TRANSFER_DEBT_NEXT_MONTH = "TRANSFER_DEBT_NEXT_MONTH";
    }

}

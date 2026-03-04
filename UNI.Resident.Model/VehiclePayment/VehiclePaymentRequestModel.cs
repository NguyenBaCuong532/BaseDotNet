using System;
using System.ComponentModel.DataAnnotations;
using UNI.Model;

namespace UNI.Resident.Model.VehiclePayment
{
    public class VehiclePaymentRequestModel : FilterBase
    {
        public int? CardVehicleId { get; set; }
        public int? PaymentStatus { get; set; }
        public string ProjectCd { get; set; }
        public string ApartmentId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
}

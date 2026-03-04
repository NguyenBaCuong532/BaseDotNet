using System;
using System.ComponentModel.DataAnnotations;

namespace UNI.Resident.Model.VehiclePayment
{
    public class VehiclePaymentApproveModel
    {
        [Required]
        public Guid PaymentId { get; set; }
        
        [Required]
        public int PaymentStatus { get; set; }
        
        public string ApprovedNote { get; set; }
    }
}

using System;
using System.ComponentModel.DataAnnotations;
using UNI.Model;

namespace UNI.Resident.Model.VehiclePayment
{
    public class VehiclePaymentInfo : viewBaseInfo
    {
        public Guid? PaymentId { get; set; }
        public int? CardVehicleId { get; set; }        
    }
}

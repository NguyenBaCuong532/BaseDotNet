using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomCardRegSet
    {
        public int ApartmentId { get; set; }
        public int RequestId { get; set; }
        public string CifNo { get; set; }
        public int CardTypeId { get; set; }
        public bool IsVehicle { get; set; }
        public HomCardRegVehicle RegVehicle { get; set; }
        public HomCardRegCredit RegCredit { get; set; }
    }
    public class HomCardReg : HomCardRegSet
    {
        public string FullName { get; set; }
        public string RoomCode { get; set; }
        public string CardTypeName { get; set; }
        public string RequestDate { get; set; }
        public string StatusName { get; set; }
        public int Status { get; set; }
    }
    public class HomCardRegVehicle
    {
        public int RequestId { get; set; }
        public string VehicleNo { get; set; }
        public string VehicleName { get; set; }
        public string VehicleTypeName { get; set; }
        public int VehicleTypeId { get; set; }
        public int ServiceId { get; set; }
        public bool isVehicleNone { get; set; }
        public string startTime { get; set; }
    }
    public class HomCardRegCredit
    {
        public int RequestId { get; set; }
        public string CifNo2 { get; set; }
        public string FullName { get; set; }
        public int CreditLimit { get; set; }
        public int SalaryAvg { get; set; }
        public bool IsSalaryTranfer { get; set; }
        public string ResidenProvince { get; set; }
    }
}

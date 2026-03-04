using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomServiceExpectablePage : viewBasePage<HomServiceExpectable>
    {
    }
    public class HomServiceExpectable
    {
        public int ReceiveId { get; set; }
        public long apartmentId { get; set; }
        public string roomCode { get; set; }
        public string projectCd { get; set; }
        public string FullName { get; set; }
        public string ReceiveDate { get; set; }
        public double WaterwayArea { get; set; }
        public long CommonFee { get; set; }
        public long VehicleAmt { get; set; }
        public long LivingAmt { get; set; }
        public long ExtendAmt { get; set; }
        public long RemainAmt { get; set; }
        public long TotalAmt { get; set; }
        public string ToDate { get; set; }
        public bool IsPayed { get; set; }
        public string PayedDate { get; set; }
        public bool isExpected { get; set; }
        public string AccrualLastDt { get; set; }
        public string AccrualStatus { get; set; }

        public string lastReceived { get; set; }
        public int countVehicle { get; set; }
        public int livingElectric { get; set; }
        public int livingWater { get; set; }
        public decimal debitAmt { get; set; }
        public double yearFree { get; set; }
        public bool IsRent { get; set; }
        public decimal livingElectricAmt { get; set; }
        public decimal livingWaterAmt { get; set; }
    }
    public class HomServiceExpectableSet
    {
        public int receiveType { get; set; }
        public string projectCd { get; set; }
        public string ToDate { get; set; }
        public List<string> Apartments { get; set; }
    }

    public class HomServiceExpectableGet : HomServiceExpectable
    {
        public List<HomServiceExpectableVehicle> receivableVehicles { get; set; }
    }

    public class HomServiceExpectableVehicle
    {
        public long apartmentId { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public string ServiceObject { get; set; }
        public string VehicleTypeName { get; set; }
        public long NumMonth { get; set; }
        public long VehicleFee { get; set; }
    }

}

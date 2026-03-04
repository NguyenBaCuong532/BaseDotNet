using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomDashboard
    {
        public hdbApartment Apartment { get; set; }
        public hdbResident Resident { get; set; }
        public hdbResidentCard ResidentCard { get; set; }
        public hdbInternalCard InternalCard { get; set; }
        public hdbRequest Request { get; set; }
        public hdbElectricMeter ElectricMeter { get; set; }
        public hdbWaterMeter WaterMeter { get; set; }
    }
    public class hdbApartment
    {
        public int ApartmentTotal { get; set; }
        public int ApartmentReceived { get; set; }
        public int ApartmentContracted { get; set; }
    }
    public class hdbResident
    {
        public int ResidentTotal { get; set; }
        public int ResidentRegisted { get; set; }
        public int ResidentCard { get; set; }
        public int ResidentCardVehicle { get; set; }
        public int ResidentCardCredit { get; set; }
    }
    public class hdbResidentCard
    {
        public int CardTotal { get; set; }
        public int CardUsed { get; set; }
        public int CardLock { get; set; }
        public double CardApartmentAvg { get; set; }
        public int CardVehicle { get; set; }
        public double CardApartmentVehicleAvg { get; set; }
    }
    public class hdbInternalCard
    {
        public int CardTotal { get; set; }
        public int CardUsed { get; set; }
        public int CardLock { get; set; }
        public int CardService { get; set; }
        public int CardOther { get; set; }
        public int CardVehicle { get; set; }
    }
    public class hdbRequest
    {
        public int RequestFixTotal { get; set; }
        public int RequestFixProcess { get; set; }
        public int RequestFixFinished { get; set; }
        public int RequestSevTotal { get; set; }
        public int RequestSevProcess { get; set; }
        public int RequestSevFinished { get; set; }
        public int RequestCardTotal { get; set; }
        public int RequestCardProcess { get; set; }
        public int RequestCardFinished { get; set; }
    }
    public class hdbElectricMeter
    {
        public int Total { get; set; }
        public double AvgMeter { get; set; }
        public int MaxMeter { get; set; }
    }
    public class hdbWaterMeter
    {
        public int Total { get; set; }
        public double AvgMeter { get; set; }
        public int MaxMeter { get; set; }
    }
}

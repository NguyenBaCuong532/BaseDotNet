using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomServicePrice
    {
        public List<ServiceCommonPrice> CommonPrice { get; set; }
        public List<ServiceVehicleMonthlyPrice> VehicleMonthlyPrice { get; set; }
        public List<ServiceVehicleDailyPrice> VehicleDailyPrice { get; set; }
        public List<ServiceLivingPrice> LivingElectricPrice { get; set; }
        public List<ServiceLivingPrice> LivingWaterPrice { get; set; }
        public List<HomRequestTypePrice> RequestPrice { get; set; }
    }
    public class ServiceCommonPrice
    {
        public int ServicePriceId { get; set; }
        public string ServiceTypeName { get; set; }
        public string ServiceName { get; set; }
        public int Price { get; set; }
        //public int CalculateType { get; set; }
        public string Unit { get; set; }
        public bool IsFree { get; set; }
        public int? IsUsed { get; set; }
        public string Note { get; set; }
    }
    public class ServiceCommonPriceUpdate : ServiceCommonPrice
    {
        public string ProjectCd { get; set; }
        public int TypeId { get; set; }
        public int ServiceTypeId { get; set; }
        public int ServiceId { get; set; }
        public int Price2 { get; set; }
        public int CalculateType { get; set; }
        public string Note { get; set; }
    }


    public class ServiceVehicleMonthlyPrice
    {
        public int ServicePriceId { get; set; }
        public string ServiceTypeName { get; set; }
        public string ServiceName { get; set; }
        public int Price { get; set; }
        //public int CalculateType { get; set; }
        public string Unit { get; set; }
        public bool IsFree { get; set; }
        public string Note { get; set; }
    }
    public class ServiceVehicleDailyPrice
    {
        public int VehicleDailyId { get; set; }
        public int VehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
        public string Note0 { get; set; }
        public int Block0 { get; set; }
        public int Price0 { get; set; }
        public string Note1 { get; set; }
        public int Block1 { get; set; }
        public int Price1 { get; set; }
        public string Note2 { get; set; }
        public int Price2 { get; set; }
        public string Unit { get; set; }
        public bool IsFree { get; set; }
        public int? IsUsed { get; set; }

    }
    public class ServiceLivingPrice
    {
        public int LivingPriceId { get; set; }
        public string ProjectCd { get; set; }
        public string Description { get; set; }
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public int NumFrom { get; set; }
        public int NumTo { get; set; }
        public int Price { get; set; }
        public int CalculateType { get; set; }
        public String step { get; set; }
        public int pos { get; set; }
        public bool IsFree { get; set; }
        public int? IsUsed { get; set; }
    }
}

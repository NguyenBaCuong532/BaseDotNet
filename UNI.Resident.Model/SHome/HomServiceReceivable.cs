using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomServiceReceivablePage : viewBasePage <HomServiceReceivable>
    {

    }
    
    public class HomServiceReceivable
    {
        public long ReceiveId { get; set; }
        public long apartmentId { get; set; }
        public string RoomCode { get; set; }
        public string projectCd { get; set; }
        public string FullName { get; set; }
        public double WaterwayArea { get; set; }
        public decimal TotalAmt { get; set; }
        public string ExpireDate { get; set; }
        public decimal PaidAmt { get; set; }
        public decimal RemainAmt { get; set; }
        public bool IsPayed { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public string PayedDate { get; set; }
        public string ReceiptNos { get; set; }
        public bool isPush { get; set; }
        public string receiveDate { get; set; }
        public bool IsBill { get; set; }
        public string BillUrl { get; set; }
        public string BillViewUrl { get; set; }
        public string Remart { get; set; }
    }
    public class HomServiceReceivableSearch {
        public CommonFee commonfee { get; set; }
        public VehicleFee vehiclefee { get; set; }
        public LivingFee livingfee { get; set; }
        public List<HomServiceReceivable> homServiceReceivables { get; set; }
    }
    public class CommonFee
    {
       public decimal TotalCommonAmt { get; set; }
        public decimal TotalCommonPayed { get; set; }
        public decimal TotalCommonNotPayed { get; set; }
    }
    public class VehicleFee
    {
        public decimal TotalVehicelAmt { get; set; }
        public decimal TotalVehicelPayed { get; set; }
        public decimal TotalVehicelNotPayed { get; set; }
    }
    public class LivingFee
    {
        public decimal TotalLivingAmt { get; set; }
        public decimal TotalLivingPayed { get; set; }
        public decimal TotalLivingNotPayed { get; set; }
    }
    public class ExtendFee
    {
        public int receiveId { get; set; }
        public decimal extendAmt { get; set; }
        public string note { get; set; }
    }
    public class RefundFee: ExtendFee
    {

    }
    public class LivingImport
    {
        public int livingTypeId { get; set; }
        public IFormFile formFile { get; set; }
    }
    public class LivingDataImport
    {
        public string roomCode { get; set; }
        public int periodYear { get; set; }
        public int periodMonth { get; set; }
        public string fromDt { get; set; }
        public string toDt { get; set; }
        public int livingTypeId { get; set; }
        public int? fromNum { get; set; }
        public int? toNum { get; set; }
        public int? totalNum { get; set; }
    }
}

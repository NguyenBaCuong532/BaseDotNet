using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    
    public class FilterBaseApartment : FilterBase
    {
        public long? ApartmentId { get; set; }
        public FilterBaseApartment(string clientid, string userid, int? offset, int? pagesize, long? apartmentid) : base(clientid, userid, offset, pagesize, "", 0)
        {
            this.ApartmentId = apartmentid;
        }
    }
    public class FilterBaseProject : FilterBase
    {
        public string ProjectCd { get; set; }
        public FilterBaseProject(string clientid, string userid, int? offset, int? pagesize, string projectcd = "", string filter = "", int gridwidth = 0) : base(clientid, userid, offset, pagesize, filter, gridwidth)
        {
            this.ProjectCd = projectcd;
        }
    }
    public class FilterProjectliving : FilterBase
    {
        public string ProjectCd { get; set; }
        public int livingTypeid { get; set; }
        public FilterProjectliving(string clientid, string userid, int? offset, int? pagesize, string projectcd, string filter) : base(clientid, userid, offset, pagesize, filter, 0)
        {
            this.ProjectCd = projectcd;
        }
    }
    public class FilterBaseManger : FilterBaseProject
    {
        public string RoomCd { get; set; }
        public string Statuses { get; set; }
        public int IsCalculated { get; set; }
        public FilterBaseManger(string clientid, string userid, int? offset, int? pagesize, 
            string projectcd, string roomcd, string statuses, string filter, int gridwidth, int isCalculated) : base(clientid, userid, offset, pagesize, projectcd, filter, gridwidth)
        {
            this.RoomCd = roomcd;
            this.Statuses = statuses;
            this.IsCalculated = isCalculated;
        }
    }
    public class FilterBaseManger1: FilterBaseManger
    {
        public int vehicleTypeId { get; set; }
        public int partner_id { get; set; }
        public FilterBaseManger1(string clientid, string userid, int? offset, int? pagesize, 
            string projectcd, string filter, string statuses, int vehicletypeid, int partnerid) : base(clientid, userid, offset, pagesize, projectcd, "", statuses, filter, 0, 0)
        {
            this.vehicleTypeId = vehicletypeid;
            this.partner_id = partnerid;
        }
    }

    public class FilterBaseManger2: FilterBaseManger1
    {
        public int dateFilter { get; set; }
        public string endDate { get; set; }
        public FilterBaseManger2(string clientid, string userid, int? offset, int? pagesize,
            string projectcd, string filter, string statuses, int vehicletypeid, int partnerid,  int datefilter, string enddate) : base(clientid, userid, offset, pagesize, projectcd, filter, statuses, vehicletypeid, partnerid)
        {
            this.dateFilter = datefilter;
            this.endDate = enddate;
        }
    }
    public class FilterBaseCard : FilterBaseProject
    {
        public string cardCd { get; set; }
        public FilterBaseCard(string clientid, string userid, int? offset, int? pagesize, 
            string projectcd, string cardcd) : base(clientid, userid, offset, pagesize, projectcd)
        {
            this.cardCd = cardcd;
        }
    }
    public class FilterCard : FilterBase
    {
        public int CardTypeId { get; set; }
        public FilterCard(string clientid, string userid, int? offset, int? pagesize, string filter, int cardTypeId) : base(clientid, userid, offset, pagesize, filter,0)
        {
            this.CardTypeId = cardTypeId;
        }

    }
    public class FilterBasePayment : FilterBaseApartment
    {
        public int? Month { get; set; }
        public int? Year { get; set; }
        public int? payType { get; set; }
        public FilterBasePayment(string clientid, string userid, int? offset, int? pagesize, 
            long? apartmentid, int? month, int? year, int? paytype) 
            : base(clientid, userid, offset, pagesize, apartmentid)
        {
            this.Month = month;
            this.Year = year;
            this.payType = paytype;
        }
    }
    public class FilterBasePayments : FilterBasePayment
    {
        public string projectCd { get; set; }
        public string buildingCd { get; set; }
        public string Floor { get; set; }
        public string RoomCd { get; set; }
        public FilterBasePayments(string clientid, string userid, int? offset, int? pagesize,
            string projectcd, string roomcd, string buildingcd, string floor, int? month, int? year) : base(clientid, userid, offset, pagesize, 0, month, year, null)
        {
            this.projectCd = projectcd;
            this.buildingCd = buildingcd;
            this.Floor = floor;
            this.RoomCd = roomcd;
        }
    }
    public class FilterBaseRooms : FilterBaseProject
    {
        public string buildingCd { get; set; }
        public string Floor { get; set; }
        public string RoomCd { get; set; }
        public FilterBaseRooms(string clientid, string userid, int? offset, int? pagesize,
            string projectcd, string buildingcd, string roomcd,  string floor) : base(clientid, userid, offset, pagesize, projectcd)
        {
            this.buildingCd = buildingcd;
            this.Floor = floor;
            this.RoomCd = roomcd;
        }
    }
    public class FilterBaseCabVehicle : FilterBase
    {
        public long DriverId { get; set; }
        public long VehicleId { get; set; }
        public FilterBaseCabVehicle(string clientid, string userid, int? offset, int? pagesize, 
            string filter, long driverId, long vehicleId) : base(clientid, userid, offset, pagesize, filter,0)
        {
            this.DriverId = driverId;
            this.VehicleId = vehicleId;
        }

    }
    public class FilterElevatorZone : FilterBase
    {
        public string ProjectCd { get; set; }
        public string BuildingCd { get; set; }
        public FilterElevatorZone(string clientid, string userid, int? offset, int? pagesize, string filter,
            string projectCd, string areaCd) : base(clientid, userid, offset, pagesize, filter, 0)
        {
            this.ProjectCd = projectCd;
            this.BuildingCd = areaCd;
        }
    }
    public class FilterElevatorFloor : FilterBase
    {
        public string ProjectCd { get; set; }
        public string areaCd { get; set; }
        public string BuildZone { get; set; }
        public string HardWareId { get; set; }
        /// <summary>Oid tòa nhà (ưu tiên nếu có)</summary>
        public System.Guid? buildingOid { get; set; }
        public FilterElevatorFloor(string clientid, string userid, int? offset, int? pagesize, string filter, 
            string projectCd, string areaCd, string buildZone, System.Guid? buildingOid = null) : base(clientid, userid, offset, pagesize, filter,0)
        {
            this.ProjectCd = projectCd;
            this.areaCd = areaCd;
            this.BuildZone = buildZone;
            this.buildingOid = buildingOid;
        }
    }
    public class FilterElevatorDevice : FilterBase
    {
        public string ProjectCd { get; set; }
        public string BuildingCd { get; set; }
        public string BuildZone { get; set; }
        public int FloorNumber { get; set; }
        public string cardId { get; set; }
        public FilterElevatorDevice(string clientid, string userid, int? offset, int? pagesize, string filter, 
            string projectCd,string buildCd, string buildZone,int floorNumber, string cardId) : base(clientid, userid, offset, pagesize, filter,0)
        {
            this.ProjectCd = projectCd;
            this.BuildingCd = buildCd;
            this.BuildZone = buildZone;
            this.FloorNumber = floorNumber;
            this.cardId = cardId;
        }
    }
    public class FilterServiceReceivables : FilterBase
    {
        public string ProjectCd { get; set; }
        public string ToDate { get; set; }
        public bool? isDateFilter { get; set; }
        public int StatusPayed { get; set; }
        public bool? IsBill { get; set; }
        public bool? IsPush { get; set; }

        public FilterServiceReceivables(string clientid, string userid, int? offset, int? pagesize, string filter, int gridwidth,
            string projectCd, string toDate, bool? isdateFilter, int statusPayed,bool? isBill, bool? isPush) : base(clientid, userid, offset, pagesize, filter, gridwidth)
        {
            this.ProjectCd = projectCd;
            this.ToDate = toDate;
            this.isDateFilter = isdateFilter;
            this.IsBill = isBill;
            this.StatusPayed = statusPayed;
            this.IsPush = isPush;
        }
    }

    public class FilterServiceReceipt : FilterBase
    {
        public string ProjectCd { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public bool? isDateFilter { get; set; }
        public int isExpected { get; set; }
        public int isResident { get; set; }
        public int status { get; set; } // 0 - all, 1 - paid, 2 - unpaid
        public FilterServiceReceipt(string clientid, string userid, int? offset, int? pagesize, string filter, int gridwidth,
            string objKey, long objId, int objSt, int isexpected, int isresident, bool isdateFilter, string fromdate, string todate) : base(clientid, userid, offset, pagesize, filter, gridwidth)
        {
            this.isExpected = isexpected;
            this.isResident = isresident;
            this.isDateFilter = isdateFilter;
            this.FromDate = fromdate;
            this.ToDate = todate;
        }
    }
}

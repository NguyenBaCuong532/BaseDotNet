using UNI.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Utils;
using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model.Notification
{
    //public class RoomNotifyPushImport : BaseImportSet<RoomNotifyPushImportItem>
    //{

    //}
    //public class RoomNotifyPushImportItem
    //{
    //    [Excel(ExcelCol = "A")]
    //    public string Seq { get; set; }
    //    [Excel(ExcelCol = "B")]
    //    public string RoomCode { get; set; }
    //}
    //public class ImportRoomNotifyPushListPage : viewDataPage<object>
    //{
    //    public bool valid { get; set; }
    //    public string messages { get; set; }
    //    public bool accept { get; set; }
    //    public long recordsFail { get; set; }
    //    public long recordsAccepted { get; set; }
    //    public uImportFile importFile { get; set; }
    //    public List<RoomModel> roomModels { get; set; }
    //}
    public class RoomModel
    {
        public string ProjectName { get; set; }
        public string ProjectCd { get; set; }
        public int ApartmentId { get; set; }
        public string BuildingName { get; set; }
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string AvatarUrl { get; set; }
        public int Floor { get; set; }
        public float WaterwayArea { get; set; }
        public string UserLogin { get; set; }
        public string Cif_No { get; set; }
        public string CustId { get; set; }
        public string BuildingCd { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public bool IsReceived { get; set; }
        public string ReceiveDate { get; set; }
        public bool IsRent { get; set; }
        public bool isMain { get; set; }
        
    }
}

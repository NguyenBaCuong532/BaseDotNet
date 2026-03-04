using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomProjectInfo : viewBaseInfo
    {
        public string projectCd { get; set; }
        //public string investorName { get; set; }
        //public string projectName { get; set; }
        //public string address { get; set; }
        //public string bank_acc_no { get; set; }
        //public string bank_acc_name { get; set; }
        //public string bank_branch { get; set; }
        //public string bank_name { get; set; }
        //public string timeWorking { get; set; }
        //public string mailSender { get; set; }
    }
    public class HomBuilding
    {
        public string ProjectCd { get; set; }
        public string ProjectName { get; set; }
        public string BuildingCd { get; set; }
        public string BuildingName { get; set; }
    }
    public class HomFloor
    {
        public string BuildingCd { get; set; }
        public string floor { get; set; }
        public string floorNo { get; set; }
    }
    public class HomRoom
    {
        public string roomCode { get; set; }
        public string buildingName { get; set; }
        public string floorNo { get; set; }

    }
    public class HomRoomCodeView
    {
        public string roomCode { get; set; }
        public string buildingCd { get; set; }
        public string roomCodeView { get; set; }
    }
}

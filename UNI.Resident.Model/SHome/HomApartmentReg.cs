using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomApartmentReg
    {
        public long id { get; set; }
        public string roomCode { get; set; }
        public string contractNo { get; set; }
        public int relationId { get; set; }
    }
    public class HomApartmentRegGet
    {
        public long id { get; set; }
        public string roomCode { get; set; }
        public string contractNo { get; set; }
        public string projectCd { get; set; }
        public string projectName { get; set; }
        public string buildingCd { get; set; }
        public string buildingName { get; set; }
        public string floorNo { get; set; }
        public string reg_date { get; set; }
        public bool reg_st { get; set; }
        public int reg_status { get; set; }
        public int relationId { get; set; }
        public string relationName { get; set; }
    }
}

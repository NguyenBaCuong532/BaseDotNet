using UNI.Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model.Resident
{
    //public class Vehicle
    //{
        
    //}
    // Phương tiện thuộc căn hộ
    //public class VehiclePage : viewBasePage<object>
    //{

    //}
    public class VehicleRequestModel : FilterBase
    {
        public int? ApartmentId { get; set; }  // giữ nguyên tham số cũ
        public string Oid { get; set; }  // thêm Oid (UUID)
    }
    public class ApartmentVehicleInfo : viewBaseInfo
    {
        public Guid? Id { get; set; }
        public List<viewGridFlex> gridflexs { get; set; }
        public ResponseList<List<object>> dataList { get; set; }

    }
}

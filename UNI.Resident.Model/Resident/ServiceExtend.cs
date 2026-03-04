using UNI.Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model.Resident
{
    // dv internet - truyền hình
    public class ServiceExtend
    {
    }
    //public class ServiceExtendPage : viewBasePage<object>
    //{

    //}
    public class ServiceExtendInfo : viewBaseInfo
    {
        public int? LivingId { get; set; }
    }

    public class ServiceExtendRequestModel : FilterBase
    {
        public string ApartmentId { get; set; }
    }
}

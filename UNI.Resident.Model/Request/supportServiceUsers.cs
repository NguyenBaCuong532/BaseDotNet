using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Request
{
    public class SupportServiceUsersFilter : FilterBase
    {
        public Guid? ServiceTypeOid { get; set; }
    }
}
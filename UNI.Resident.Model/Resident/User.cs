using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.Model.Resident
{
    public class User
    {
    }
    public class UsersInfo : viewBaseInfo
    {
        public string userId { get; set; }
        public string Oid { get; set; }
    }
    public class UserFilter : FilterBase
    {

        public string ApiName { get; set; }
        public string ControllerName { get; set; }
        public string Filter { get; set; }
        public string fullName { get; set; }
        public string phone { get; set; }
        public string email { get; set; }
        public UserFilter(string clientid, string userid, int? offset, int? pagesize, string filter, int gridWidth)
            : base(clientid, userid, offset, pagesize, filter, gridWidth)
        {
            this.Filter = filter;       
        }
    }

}

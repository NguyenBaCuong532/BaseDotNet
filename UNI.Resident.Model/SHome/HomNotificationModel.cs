
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomNotiCommentCount
    {
        public long NotiId { get; set; }
        public int countComment { get; set; }
    }
    
    
    
    
    public class HomTakeActionEmail
    {
        public string UserName { get; set; }
        public int RequestType { get; set; }
        public string lastMessage { get; set; }
    }
    
}

using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomRequestAttach
    {
        public long id { get; set; }
        public long requestId { get; set; }
        public long processId { get; set; }
        public string attachUrl { get; set; }
        public string attachType { get; set; }
        public string attachFileName { get; set; }
        public bool used { get; set; }
    }
}

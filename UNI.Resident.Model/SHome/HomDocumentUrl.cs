using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace UNI.Resident.Model
{
    public class HomDocumentUrlSet
    {
        public string ProjectCd { get; set; }
        public string DocumentTitle { get; set; }
        public string DocumentUrl { get; set; }
    }
    public class HomDocumentUrlGet
    {
        public int DocId { get; set; }
        public string DocumentTitle { get; set; }
        public string DocumentUrl { get; set; }
        public string InputDate { get; set; }
    }
}

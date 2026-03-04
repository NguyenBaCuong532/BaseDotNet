using System;
using UNI.Model;

namespace UNI.Resident.Model.Resident
{
    public class ProjectApp
    {
        public string projectCd { get; set; }
        public string projectName { get; set; }
    }
    public class ProjectInfo : viewBaseInfo
    {
        public string projectCd { get; set; }
        public Guid? Oid { get; set; } // Hỗ trợ migration từ projectCd sang Oid
    }
    public class ProjectBase
    {
        public string project_cd { get; set; }
        public string project_name { get; set; }
        public string projectCd { get; set; }
        public string projectName { get; set; }
    }
}

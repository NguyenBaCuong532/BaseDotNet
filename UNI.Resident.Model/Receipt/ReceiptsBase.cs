using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Receipt
{
    public class ReceiptsBase
    {
        public string projectCd { get; set; }
        public List<long> receiveIds { get; set; }
    }

    public class ReceiptsBaseViewInfo : CommonViewInfo
    {
        public string projectCd { get; set; }

        public List<long> receiveIds { get; set; }
    }
}

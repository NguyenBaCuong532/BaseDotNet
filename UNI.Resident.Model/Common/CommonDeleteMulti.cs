using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.Model.Common
{
    public class CommonDeleteMulti
    {
        public string TableName { get; set; } = string.Empty;
        public List<int?> Ids { get; set; }
    }
    public class DeleteMultiServiceLivingMeter : CommonDeleteMulti
    {
        public int? LivingTypeId { get; set; }
    }
}

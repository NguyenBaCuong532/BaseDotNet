using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServicePriceTypeService : IUniBaseService
    {
        Task<List<CommonValue>> GetServicePriceTypeForDropdownList(string filter);
    }
}
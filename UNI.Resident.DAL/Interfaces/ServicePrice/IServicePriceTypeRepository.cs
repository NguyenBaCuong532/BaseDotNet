using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceTypeRepository : IResidentBaseRepository
    {
        Task<List<CommonValue>> GetServicePriceTypeForDropdownList(string filter);
    }
}
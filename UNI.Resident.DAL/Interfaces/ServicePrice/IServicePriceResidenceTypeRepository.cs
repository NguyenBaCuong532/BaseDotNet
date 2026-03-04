using System;
using System.Threading.Tasks;
using UNI.Model;
using System.Collections.Generic;
using UNI.Common.CommonBase;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceResidenceTypeRepository : IUniBaseRepository
    {
        Task<List<CommonValue>> GetServicePriceResidenceTypeNameValue(string filter);
    }
}
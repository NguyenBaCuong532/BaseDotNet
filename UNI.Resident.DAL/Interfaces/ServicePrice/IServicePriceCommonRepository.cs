using System;
using System.Threading.Tasks;
using UNI.Model;
using System.Collections.Generic;
using UNI.Common.CommonBase;

namespace UNI.Resident.DAL.Interfaces.ServicePrice
{
    public interface IServicePriceCommonRepository : IUniBaseRepository
    {
        Task<CommonViewInfo> GetServicePriceCommonFilter();

        Task<CommonDataPage> GetServicePriceCommonPage(FilterBase filter);

        Task<viewBaseInfo> GetServicePriceCommonFields(Guid? oid);

        Task<BaseValidate> SetServicePriceCommon(CommonViewInfo inputData);

        Task<BaseValidate> SetServicePriceCommonDelete(List<Guid> arrOid);
    }
}
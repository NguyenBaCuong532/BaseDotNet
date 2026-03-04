using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IInvoicePeriodsService : IUniBaseService
    {
        Task<CommonViewInfo> GetInvoicePeriodsFilter();

        Task<CommonDataPage> GetInvoicePeriodsPage(InvoicePeriodsFilter filter);

        Task<viewBaseInfo> GetInvoicePeriodsFields(Guid? oid);

        Task<BaseValidate> SetInvoicePeriods(CommonViewInfo inputData);

        Task<BaseValidate> SetInvoicePeriodsDelete(List<Guid> arrOid);
    }
}
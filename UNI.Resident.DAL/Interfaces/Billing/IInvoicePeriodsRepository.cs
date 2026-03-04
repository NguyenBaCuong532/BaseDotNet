using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IInvoicePeriodsRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetInvoicePeriodsFilter();

        Task<CommonDataPage> GetInvoicePeriodsPage(InvoicePeriodsFilter filter);

        Task<viewBaseInfo> GetInvoicePeriodsFields(Guid? oid);

        Task<BaseValidate> SetInvoicePeriods(CommonViewInfo inputData);

        Task<BaseValidate> SetInvoicePeriodsDelete(List<Guid> arrOid);
    }
}
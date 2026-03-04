using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.Model.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Billing
{
    public interface IInvoicePeriodsDetailRepository : IResidentBaseRepository
    {
        Task<CommonViewInfo> GetInvoicePeriodsDetailFilter();

        Task<CommonDataPage> GetInvoicePeriodsDetailPage(ServiceReceivableRequestModel filter);

        Task<viewBaseInfo> GetInvoicePeriodsDetailFields(Guid? oid);

        Task<BaseValidate> SetInvoicePeriodsDetail(CommonViewInfo inputData);

        Task<BaseValidate> SetInvoicePeriodsDetailDelete(List<Guid> arrOid);

        Task<CommonViewInfo> GetCreateInvoiceFields();

        Task<BaseValidate> SetCreateInvoiceFields(CommonViewInfo inputData);
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Billing
{
    public interface IInvoicePeriodsDetailService : IUniBaseService
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
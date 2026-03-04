using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.BLL.BusinessService.Billing
{
    /// <summary>
    /// Kỳ hóa đơn
    /// </summary>
    public class InvoicePeriodsService : UniBaseService, IInvoicePeriodsService
    {
        private readonly IInvoicePeriodsRepository _repository;

        public InvoicePeriodsService(IInvoicePeriodsRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetInvoicePeriodsFilter()
            => _repository.GetInvoicePeriodsFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetInvoicePeriodsPage(InvoicePeriodsFilter filter)
            => _repository.GetInvoicePeriodsPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetInvoicePeriodsFields(Guid? oid)
            => _repository.GetInvoicePeriodsFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetInvoicePeriods(CommonViewInfo inputData)
            => _repository.SetInvoicePeriods(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetInvoicePeriodsDelete(List<Guid> arrOid)
            => _repository.SetInvoicePeriodsDelete(arrOid);
    }
}
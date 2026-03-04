using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Billing
{
    /// <summary>
    /// Chi tiết kỳ hóa đơn
    /// </summary>
    public class InvoicePeriodsDetailService : UniBaseService, IInvoicePeriodsDetailService
    {
        private readonly IInvoicePeriodsDetailRepository _repository;

        public InvoicePeriodsDetailService(IInvoicePeriodsDetailRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetInvoicePeriodsDetailFilter()
            => _repository.GetInvoicePeriodsDetailFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetInvoicePeriodsDetailPage(ServiceReceivableRequestModel filter)
            => _repository.GetInvoicePeriodsDetailPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetInvoicePeriodsDetailFields(Guid? oid)
            => _repository.GetInvoicePeriodsDetailFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetInvoicePeriodsDetail(CommonViewInfo inputData)
            => _repository.SetInvoicePeriodsDetail(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetInvoicePeriodsDetailDelete(List<Guid> arrOid)
            => _repository.SetInvoicePeriodsDetailDelete(arrOid);

        public async Task<CommonViewInfo> GetCreateInvoiceFields()
            => await _repository.GetCreateInvoiceFields();

        public Task<BaseValidate> SetCreateInvoiceFields(CommonViewInfo inputData)
            => _repository.SetCreateInvoiceFields(inputData);
    }
}
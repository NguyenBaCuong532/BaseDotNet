using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.BLL.BusinessService.ServicePrice
{
    /// <summary>
    /// Cấu hình thứ tự ưu tiên thanh toán dịch vụ căn hộ
    /// </summary>
    public class PaymentPriorityConfigsService : UniBaseService, IPaymentPriorityConfigsService
    {
        private readonly IPaymentPriorityConfigsRepository _repository;

        public PaymentPriorityConfigsService(IPaymentPriorityConfigsRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetPaymentPriorityConfigsFilter()
            => _repository.GetPaymentPriorityConfigsFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetPaymentPriorityConfigsPage(FilterBase filter)
            => _repository.GetPaymentPriorityConfigsPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetPaymentPriorityConfigsFields(Guid? oid)
            => _repository.GetPaymentPriorityConfigsFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetPaymentPriorityConfigs(CommonViewInfo inputData)
            => _repository.SetPaymentPriorityConfigs(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetPaymentPriorityConfigsDelete(List<Guid> arrOid)
            => _repository.SetPaymentPriorityConfigsDelete(arrOid);
    }
}
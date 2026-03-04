using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Billing
{
    /// <summary>
    /// Dự thu các căn hộ trước khi xuất hóa đơn
    /// </summary>
    public class RevenuePeriodsDetailService : UniBaseService, IRevenuePeriodsDetailService
    {
        private readonly IRevenuePeriodsDetailRepository _repository;

        public RevenuePeriodsDetailService(IRevenuePeriodsDetailRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServiceReceivableFilter()
            => _repository.GetServiceReceiveEntryFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServiceReceivablePage(ServiceExpectedRequestModel filter)
            => _repository.GetServiceReceivablePage(filter);

        /// <summary>
        /// Lấy chi tiết dự thu
        /// </summary>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        public async Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId)
            => await _repository.GetServiceExpectedDetailsInfo(receiveId);

        /// <summary>
        /// Form tính dự thu
        /// </summary>
        /// <param name="apartmentId"> id căn hộ</param>
        /// <returns></returns>
        public async Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? apartmentId, Guid? revenuePeriodId = null, ServiceExpectedCalculatorInfo info = null)
            => await _repository.GetServiceExpectedCalculatorInfo(apartmentId, revenuePeriodId, info);

        /// <summary>
        /// Thông tin tính dự thu
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info)
            => await _repository.SetServiceExpectedCalculatorInfo(info);
    }
}
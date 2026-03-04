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
    /// Kỳ thanh toán - Dự thu
    /// </summary>
    public class BillingEstimatesService : UniBaseService, IBillingEstimatesService
    {
        private readonly IBillingEstimatesRepository _repository;

        public BillingEstimatesService(IBillingEstimatesRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingEstimatesFilter()
            => _repository.GetBillingEstimatesFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingEstimatesPage(ServiceExpectedRequestModel query)
            => _repository.GetBillingEstimatesPage(query);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetBillingEstimatesFields(int? receiveId)
            => _repository.GetBillingEstimatesFields(receiveId);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingEstimates(CommonViewInfo inputData)
            => _repository.SetBillingEstimates(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingEstimatesDelete(List<Guid> arrOid)
            => _repository.SetBillingEstimatesDelete(arrOid);

        public Task<ServiceExpectedCalculatorInfo> GetBillingEstimatesCalculatorFields(Guid periodsOid, int? apartmentId)
            => _repository.GetBillingEstimatesCalculatorFields(periodsOid, apartmentId);

        public Task<BaseValidate> SetBillingEstimatesCalculatorFields(ServiceExpectedCalculatorInfo info)
            => _repository.SetBillingEstimatesCalculatorFields(info);

        /// <summary>
        /// Chi tiết dịch vụ chung
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingEstimatesExpectedFeePage(ServiceExpectedFeeRequestModel query)
            => _repository.GetBillingEstimatesExpectedFeePage(query);

        /// <summary>
        /// Chi tiết điện/nước
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<ServiceExpectedLivingPage> GetBillingEstimatesExpectedLivingPage(ServiceExpectedLivingRequestModel query)
            => await _repository.GetBillingEstimatesExpectedLivingPage(query);

        /// <summary>
        /// Phí gửi xe
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingEstimatesExpectedVehiclePage(ServiceExpectedVehicleRequestModel query)
            => await _repository.GetBillingEstimatesExpectedVehiclePage(query);

        public async Task<CommonDataPage> GetBillingEstimatesExpectedExtendPage(ServiceExpectedExtendRequestModel query)
            => await _repository.GetBillingEstimatesExpectedExtendPage(query);

        public Task<viewBaseInfo> GetBillingEstimatesExpectedExtendFields(int receiveId)
            => _repository.GetBillingEstimatesExpectedExtendFields(receiveId);

        public Task<BaseValidate> SetBillingEstimatesExpectedExtendFields(CommonViewInfo inputData)
            => _repository.SetBillingEstimatesExpectedExtendFields(inputData);

        public async Task<CommonDataPage> GetBillingEstimatesExpectedDebtPage(ServiceExpectedExtendRequestModel query)
            => await _repository.GetBillingEstimatesExpectedDebtPage(query);
    }
}
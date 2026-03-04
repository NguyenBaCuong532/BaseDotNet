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
    /// Kỳ thanh toán (dự thu/hóađơn)
    /// </summary>
    public class BillingPeriodsService : UniBaseService, IBillingPeriodsService
    {
        private readonly IBillingPeriodsRepository _repository;

        public BillingPeriodsService(IBillingPeriodsRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingPeriodsFilter()
            => _repository.GetBillingPeriodsFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingPeriodsPage(BillingPeriodsFilter filter)
            => _repository.GetBillingPeriodsPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetBillingPeriodsFields(Guid? oid, CommonViewInfo inputData = null)
            => _repository.GetBillingPeriodsFields(oid, inputData);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriods(CommonViewInfo inputData)
            => _repository.SetBillingPeriods(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriodsDelete(List<Guid> arrOid)
            => _repository.SetBillingPeriodsDelete(arrOid);

        public async Task<List<CommonValue>> GetBillingPeriodsStatusList()
            => await _repository.GetBillingPeriodsStatusList();

        /// <summary>
        /// Khóa/mở khóa kỳ thanh toán
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsLock(BillingPeriods_SetLocked inputParam)
            => await _repository.SetBillingPeriodsLock(inputParam);
    }
}
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
    /// Kỳ tính dự thu
    /// </summary>
    public class RevenuePeriodsService : UniBaseService, IRevenuePeriodsService
    {
        private readonly IRevenuePeriodsRepository _repository;

        public RevenuePeriodsService(IRevenuePeriodsRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetRevenuePeriodsFilter()
            => _repository.GetRevenuePeriodsFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetRevenuePeriodsPage(RevenuePeriodsFilter filter)
            => _repository.GetRevenuePeriodsPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetRevenuePeriodsFields(Guid? oid, CommonViewInfo inputData = null)
            => _repository.GetRevenuePeriodsFields(oid, inputData);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetRevenuePeriods(CommonViewInfo inputData)
            => _repository.SetRevenuePeriods(inputData);

        /// <summary>
        /// Khóa kỳ tính dự thu
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetRevenuePeriodsLocked(RevenuePeriodsSetLocked inputParam)
            => _repository.SetRevenuePeriodsLocked(inputParam);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetRevenuePeriodsDelete(List<Guid> arrOid)
            => _repository.SetRevenuePeriodsDelete(arrOid);
    }
}
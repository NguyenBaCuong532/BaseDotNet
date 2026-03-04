using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.DAL.Interfaces.ServicePrice;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.BLL.BusinessService.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Nước - Chi tiết
    /// </summary>
    public class ServicePriceWaterDetailService : UniBaseService, IServicePriceWaterDetailService
    {
        private readonly IServicePriceWaterDetailRepository _repository;

        public ServicePriceWaterDetailService(IServicePriceWaterDetailRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceWaterDetailFilter()
            => _repository.GetServicePriceWaterDetailFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceWaterDetailPage(ServicePriceWaterDetailFilter filter)
            => _repository.GetServicePriceWaterDetailPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceWaterDetailFields(Guid waterOid, Guid? oid, CommonViewInfo inputData = null)
            => _repository.GetServicePriceWaterDetailFields(waterOid, oid, inputData);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceWaterDetail(CommonViewInfo inputData)
            => _repository.SetServicePriceWaterDetail(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceWaterDetailDelete(List<Guid> arrOid)
            => _repository.SetServicePriceWaterDetailDelete(arrOid);
    }
}
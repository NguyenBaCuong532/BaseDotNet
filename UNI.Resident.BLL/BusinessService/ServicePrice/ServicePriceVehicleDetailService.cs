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
    /// Cấu hình giá dịch vụ - Gửi xe tháng - chi tiết
    /// </summary>
    public class ServicePriceVehicleDetailService : UniBaseService, IServicePriceVehicleDetailService
    {
        private readonly IServicePriceVehicleDetailRepository _repository;

        public ServicePriceVehicleDetailService(IServicePriceVehicleDetailRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceVehicleDetailFilter()
            => _repository.GetServicePriceVehicleDetailFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceVehicleDetailPage(ServicePriceVehicleDetailFilter filter)
            => _repository.GetServicePriceVehicleDetailPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceVehicleDetailFields(Guid vehicleOid, Guid? oid)
            => _repository.GetServicePriceVehicleDetailFields(vehicleOid, oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDetail(CommonViewInfo inputData)
            => _repository.SetServicePriceVehicleDetail(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDetailDelete(List<Guid> arrOid)
            => _repository.SetServicePriceVehicleDetailDelete(arrOid);
    }
}
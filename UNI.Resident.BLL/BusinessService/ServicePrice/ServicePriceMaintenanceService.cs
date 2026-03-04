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
    /// Cấu hình giá dịch vụ - sửa chữa
    /// </summary>
    public class ServicePriceMaintenanceService : UniBaseService, IServicePriceMaintenanceService
    {
        private readonly IServicePriceMaintenanceRepository _repository;

        public ServicePriceMaintenanceService(IServicePriceMaintenanceRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao cho danh sách dữ liệu phần trang dạng lưới
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceMaintenanceFilter()
            => _repository.GetServicePriceMaintenanceFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị dạng lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceMaintenancePage(FilterBase filter)
            => _repository.GetServicePriceMaintenancePage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceMaintenanceFields(Guid? oid)
            => _repository.GetServicePriceMaintenanceFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceMaintenance(CommonViewInfo inputData)
            => _repository.SetServicePriceMaintenance(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceMaintenanceDelete(List<Guid> arrOid)
            => _repository.SetServicePriceMaintenanceDelete(arrOid);
    }
}
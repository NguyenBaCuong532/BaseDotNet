using Microsoft.AspNetCore.Mvc;
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
    /// Cấu hình giá dịch vụ gửi xe
    /// </summary>
    public class ServicePriceVehicleService : UniBaseService, IServicePriceVehicleService
    {
        private readonly IServicePriceVehicleRepository _repository;

        public ServicePriceVehicleService(IServicePriceVehicleRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao cho danh sách dữ liệu phần trang dạng lưới
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceVehicleFilter()
            => _repository.GetServicePriceVehicleFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị dạng lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceVehiclePage(FilterBase filter)
            => _repository.GetServicePriceVehiclePage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceVehicleFields(Guid? oid)
            => _repository.GetServicePriceVehicleFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicle(CommonViewInfo inputData)
            => _repository.SetServicePriceVehicle(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDelete(List<Guid> arrOid)
            => _repository.SetServicePriceVehicleDelete(arrOid);

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<List<CommonValue>> GetServicePriceVehicleTypeForDropdownList([FromQuery] string filter)
            => _repository.GetServicePriceVehicleTypeForDropdownList(filter);

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<List<CommonValue>> GetServicePriceVehicleDailyTypeForDropdownList([FromQuery] string filter)
            => _repository.GetServicePriceVehicleDailyTypeForDropdownList(filter);
    }
}
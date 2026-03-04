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
    /// Cấu hình giá dịch vụ - Gửi xe ngày
    /// </summary>
    public class ServicePriceVehicleDailyService : UniBaseService, IServicePriceVehicleDailyService
    {
        private readonly IServicePriceVehicleDailyRepository _repository;

        public ServicePriceVehicleDailyService(IServicePriceVehicleDailyRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceVehicleDailyFilter()
            => _repository.GetServicePriceVehicleDailyFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceVehicleDailyPage(FilterBase filter)
            => _repository.GetServicePriceVehicleDailyPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceVehicleDailyFields(Guid? oid)
            => _repository.GetServicePriceVehicleDailyFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDaily(CommonViewInfo inputData)
            => _repository.SetServicePriceVehicleDaily(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDailyDelete(List<Guid> arrOid)
            => _repository.SetServicePriceVehicleDailyDelete(arrOid);
    }
}
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
    /// Cấu hình giá dịch vụ - Gửi xe ngày chi tiết
    /// </summary>
    public class ServicePriceVehicleDailyDetailService : UniBaseService, IServicePriceVehicleDailyDetailService
    {
        private readonly IServicePriceVehicleDailyDetailRepository _repository;

        public ServicePriceVehicleDailyDetailService(IServicePriceVehicleDailyDetailRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceVehicleDailyDetailFilter()
            => _repository.GetServicePriceVehicleDailyDetailFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceVehicleDailyDetailPage(ServicePriceVehicleDailyDetailTypeFilter filter)
            => _repository.GetServicePriceVehicleDailyDetailPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceVehicleDailyDetailFields(Guid vehicleDailyOid, Guid? oid)
            => _repository.GetServicePriceVehicleDailyDetailFields(vehicleDailyOid, oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDailyDetail(CommonViewInfo inputData)
            => _repository.SetServicePriceVehicleDailyDetail(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDailyDetailDelete(List<Guid> arrOid)
            => _repository.SetServicePriceVehicleDailyDetailDelete(arrOid);
    }
}
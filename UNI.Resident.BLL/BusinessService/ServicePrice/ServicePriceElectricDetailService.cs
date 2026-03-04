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
    /// Cấu hình giá dịch vụ - Điện - Chi tiết
    /// </summary>
    public class ServicePriceElectricDetailService : UniBaseService, IServicePriceElectricDetailService
    {
        private readonly IServicePriceElectricDetailRepository _repository;

        public ServicePriceElectricDetailService(IServicePriceElectricDetailRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceElectricDetailFilter()
            => _repository.GetServicePriceElectricDetailFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceElectricDetailPage(ServicePriceElectricDetailFilter filter)
            => _repository.GetServicePriceElectricDetailPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceElectricDetailFields(Guid electricOid, Guid? oid, CommonViewInfo inputData = null)
            => _repository.GetServicePriceElectricDetailFields(electricOid, oid, inputData);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceElectricDetail(CommonViewInfo inputData)
            => _repository.SetServicePriceElectricDetail(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceElectricDetailDelete(List<Guid> arrOid)
            => _repository.SetServicePriceElectricDetailDelete(arrOid);
    }
}
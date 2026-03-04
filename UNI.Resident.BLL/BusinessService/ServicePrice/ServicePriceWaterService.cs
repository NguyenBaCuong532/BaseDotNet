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
    /// Cấu hình giá dịch vụ - Nước
    /// </summary>
    public class ServicePriceWaterService : UniBaseService, IServicePriceWaterService
    {
        private readonly IServicePriceWaterRepository _repository;

        public ServicePriceWaterService(IServicePriceWaterRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceWaterFilter()
            => _repository.GetServicePriceWaterFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceWaterPage(FilterBase filter)
            => _repository.GetServicePriceWaterPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceWaterFields(Guid? oid, bool? isCopy = null)
            => _repository.GetServicePriceWaterFields(oid, isCopy);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceWater(CommonViewInfo inputData)
            => _repository.SetServicePriceWater(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceWaterDelete(List<Guid> arrOid)
            => _repository.SetServicePriceWaterDelete(arrOid);
    }
}
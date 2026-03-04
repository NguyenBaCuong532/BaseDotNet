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
    /// Cấu hình giá dịch vụ - Điện
    /// </summary>
    public class ServicePriceElectricService : UniBaseService, IServicePriceElectricService
    {
        private readonly IServicePriceElectricRepository _repository;

        public ServicePriceElectricService(IServicePriceElectricRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceElectricFilter()
            => _repository.GetServicePriceElectricFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceElectricPage(FilterBase filter)
            => _repository.GetServicePriceElectricPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceElectricFields(Guid? oid, bool? isCopy = null)
            => _repository.GetServicePriceElectricFields(oid, isCopy);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceElectric(CommonViewInfo inputData)
            => _repository.SetServicePriceElectric(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceElectricDelete(List<Guid> arrOid)
            => _repository.SetServicePriceElectricDelete(arrOid);
    }
}
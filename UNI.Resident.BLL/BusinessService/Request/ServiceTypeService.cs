using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.DAL.Interfaces.Request;

namespace UNI.Resident.BLL.BusinessService.Request
{
    /// <summary>
    /// Loại dịch vụ cung cấp cho cư dân
    /// </summary>
    public class ServiceTypeService : UniBaseService, IServiceTypeService
    {
        private readonly IServiceTypeRepository _repository;

        public ServiceTypeService(IServiceTypeRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServiceTypeFilter()
            => _repository.GetServiceTypeFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServiceTypePage(FilterBase filter)
            => _repository.GetServiceTypePage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServiceTypeFields(Guid? oid)
            => _repository.GetServiceTypeFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServiceType(CommonViewInfo inputData)
            => _repository.SetServiceType(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServiceTypeDelete(List<Guid> arrOid)
            => _repository.SetServiceTypeDelete(arrOid);
    }
}
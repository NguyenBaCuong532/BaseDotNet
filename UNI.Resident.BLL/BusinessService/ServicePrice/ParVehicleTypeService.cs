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
    /// Gom nhóm các loại xe để cấu hình tính số lượng
    /// </summary>
    public class ParVehicleTypeService : UniBaseService, IParVehicleTypeService
    {
        private readonly IParVehicleTypeRepository _repository;

        public ParVehicleTypeService(IParVehicleTypeRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetParVehicleTypeFilter()
            => _repository.GetParVehicleTypeFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetParVehicleTypePage(FilterBase filter)
            => _repository.GetParVehicleTypePage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetParVehicleTypeFields(Guid? oid)
            => _repository.GetParVehicleTypeFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetParVehicleType(CommonViewInfo inputData)
            => _repository.SetParVehicleType(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetParVehicleTypeDelete(List<Guid> arrOid)
            => _repository.SetParVehicleTypeDelete(arrOid);

        /// <summary>
        /// Danh sách các loại phương tiện chưa được cấu hình theo từng dự án
        /// </summary>
        /// <returns></returns>
        public Task<List<CommonValue>> GetParVehicleTypeIdForDropdownList(Guid? oid)
            => _repository.GetParVehicleTypeIdForDropdownList(oid);
    }
}
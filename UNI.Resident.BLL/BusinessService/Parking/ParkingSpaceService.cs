using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Parking;
using UNI.Resident.DAL.Interfaces.Parking;

namespace UNI.Resident.BLL.BusinessService.Parking
{
    /// <summary>
    /// Quản lý số lượng chỗ đỗ xe
    /// </summary>
    public class ParkingSpaceService : UniBaseService, IParkingSpaceService
    {
        private readonly IParkingSpaceRepository _repository;

        public ParkingSpaceService(IParkingSpaceRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetParkingSpaceFilter()
            => _repository.GetParkingSpaceFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetParkingSpacePage(FilterBase filter)
            => _repository.GetParkingSpacePage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetParkingSpaceFields(Guid? oid)
            => _repository.GetParkingSpaceFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetParkingSpace(CommonViewInfo inputData)
            => _repository.SetParkingSpace(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetParkingSpaceDelete(List<Guid> arrOid)
            => _repository.SetParkingSpaceDelete(arrOid);
    }
}
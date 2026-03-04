using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Parking;

namespace UNI.Resident.DAL.Repositories.Parking
{
    /// <summary>
    /// Quản lý số lượng chỗ đỗ xe
    /// </summary>
    public class ParkingSpaceRepository : ResidentBaseRepository, IParkingSpaceRepository
    {
        public ParkingSpaceRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetParkingSpaceFilter()
            => this.GetTableFilter("config_sp_res_parking_space_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetParkingSpacePage(FilterBase filter)
            => base.GetDataListPageAsync("sp_res_parking_space_page", filter, objParams: null);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetParkingSpaceFields(Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_parking_space_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetParkingSpace(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_parking_space_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetParkingSpaceDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_parking_space_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
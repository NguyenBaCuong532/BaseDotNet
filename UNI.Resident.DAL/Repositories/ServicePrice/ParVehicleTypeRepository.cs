using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Gom nhóm các loại xe để cấu hình tính số lượng
    /// </summary>
    public class ParVehicleTypeRepository : ResidentBaseRepository, IParVehicleTypeRepository
    {
        public ParVehicleTypeRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetParVehicleTypeFilter()
            => this.GetTableFilter("config_sp_res_par_vehicle_type_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetParVehicleTypePage(FilterBase filter)
            => base.GetDataListPageAsync("sp_res_par_vehicle_type_page", filter, objParams: null);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetParVehicleTypeFields(Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_par_vehicle_type_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetParVehicleType(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_par_vehicle_type_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetParVehicleTypeDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_par_vehicle_type_del", new { ArrOid = string.Join(",", arrOid) });

        /// <summary>
        /// Danh sách các loại phương tiện chưa được cấu hình theo từng dự án
        /// </summary>
        /// <returns></returns>
        public async Task<List<CommonValue>> GetParVehicleTypeIdForDropdownList(Guid? oid)
            => await base.GetListAsync<CommonValue>("sp_res_par_vehicle_type_get_code_name", new { oid });
    }
}
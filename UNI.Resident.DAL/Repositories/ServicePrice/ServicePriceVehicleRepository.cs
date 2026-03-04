using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Gửi xe tháng
    /// </summary>
    public class ServicePriceVehicleRepository : ResidentBaseRepository, IServicePriceVehicleRepository
    {
        public ServicePriceVehicleRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceVehicleFilter()
            => this.GetTableFilter("sp_res_service_price_vehicle_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceVehiclePage(FilterBase filter)
            => base.GetDataListPageAsync("sp_res_service_price_vehicle_page", filter, objParams: null);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceVehicleFields(Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_service_price_vehicle_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicle(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_vehicle_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServicePriceVehicleDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_vehicle_del", new { ArrOid = string.Join(",", arrOid) });

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<List<CommonValue>> GetServicePriceVehicleTypeForDropdownList([FromQuery] string filter)
            => await base.GetListAsync<CommonValue>("sp_res_service_price_vehicle_type_get_name_value", new { filter });

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<List<CommonValue>> GetServicePriceVehicleDailyTypeForDropdownList([FromQuery] string filter)
            => await base.GetListAsync<CommonValue>("sp_res_service_price_vehicle_daily_type_get_name_value", new { filter });
    }
}
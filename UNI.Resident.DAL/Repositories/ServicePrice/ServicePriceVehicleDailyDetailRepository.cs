using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;
using UNI.Resident.Model.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Gửi xe ngày chi tiết
    /// </summary>
    public class ServicePriceVehicleDailyDetailRepository : ResidentBaseRepository, IServicePriceVehicleDailyDetailRepository
    {
        public ServicePriceVehicleDailyDetailRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceVehicleDailyDetailFilter()
            => this.GetTableFilter("config_sp_res_service_price_vehicle_daily_detail_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceVehicleDailyDetailPage(ServicePriceVehicleDailyDetailTypeFilter filter)
            => base.GetDataListPageAsync("sp_res_service_price_vehicle_daily_detail_page",
                filter,
                objParams: new
                {
                    filter.VehicleDailyOid,
                    filter.par_vehicle_daily_type_oid,
                });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceVehicleDailyDetailFields(Guid vehicleDailyOid, Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_service_price_vehicle_daily_detail_field",
                dynamicParam: null,
                new
                {
                    vehicleDailyOid,
                    oid
                });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceVehicleDailyDetail(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_vehicle_daily_detail_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServicePriceVehicleDailyDetailDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_vehicle_daily_detail_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
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
    /// Cấu hình giá dịch vụ - Nước - Chi tiết
    /// </summary>
    public class ServicePriceWaterDetailRepository : ResidentBaseRepository, IServicePriceWaterDetailRepository
    {
        public ServicePriceWaterDetailRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceWaterDetailFilter()
            => this.GetTableFilter("config_sp_res_service_price_water_detail_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceWaterDetailPage(ServicePriceWaterDetailFilter filter)
            => base.GetDataListPageAsync("sp_res_service_price_water_detail_page",
                filter,
                objParams: new
                {
                    par_water_oid = filter.WaterOid,
                    filter.par_service_price_type_oid
                });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceWaterDetailFields(Guid waterOid, Guid? oid, CommonViewInfo inputData = null)
        {
            var objParams = inputData != null
                ? inputData.ToObject()
                : new { par_water_oid = waterOid, oid };
            return this.GetFieldsAsync<viewBaseInfo>("sp_res_service_price_water_detail_field",
                dynamicParam: null,
                objParams);
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceWaterDetail(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_water_detail_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServicePriceWaterDetailDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_water_detail_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Điện
    /// </summary>
    public class ServicePriceElectricRepository : ResidentBaseRepository, IServicePriceElectricRepository
    {
        public ServicePriceElectricRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceElectricFilter()
            => this.GetTableFilter("sp_res_service_price_electric_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceElectricPage(FilterBase filter)
            => base.GetDataListPageAsync("sp_res_service_price_electric_page", filter, objParams: null);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceElectricFields(Guid? oid, bool? isCopy = null)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_service_price_electric_field",
                dynamicParam: null,
                objParams: new
                {
                    oid,
                    is_copy = isCopy
                });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceElectric(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_electric_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServicePriceElectricDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_price_electric_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
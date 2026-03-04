using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Cấu hình thứ tự ưu tiên thanh toán dịch vụ căn hộ
    /// </summary>
    public class PaymentPriorityConfigsRepository : ResidentBaseRepository, IPaymentPriorityConfigsRepository
    {
        public PaymentPriorityConfigsRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetPaymentPriorityConfigsFilter()
            => this.GetTableFilter("config_sp_res_payment_priority_configs_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetPaymentPriorityConfigsPage(FilterBase filter)
            => base.GetDataListPageAsync("sp_res_payment_priority_configs_page", filter, objParams: null);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetPaymentPriorityConfigsFields(Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_payment_priority_configs_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetPaymentPriorityConfigs(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_payment_priority_configs_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetPaymentPriorityConfigsDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_payment_priority_configs_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
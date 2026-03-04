using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Billing;

namespace UNI.Resident.DAL.Repositories.Billing
{
    /// <summary>
    /// Kỳ thanh toán (dự thu/hóađơn)
    /// </summary>
    public class BillingPeriodsRepository : ResidentBaseRepository, IBillingPeriodsRepository
    {
        public BillingPeriodsRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public async Task<CommonViewInfo> GetBillingPeriodsFilter()
        {
            var resGetTableFilter = await this.GetTableFilter("billing_periods_filter");
            
            var resGetTableFilterItem = await this.GetFieldsAsync<viewBaseInfo>("sp_res_billing_periods_tabs_filter", dynamicParam: null, objParams: null);
            resGetTableFilter.TabsFilter = resGetTableFilterItem.group_fields;

            return resGetTableFilter;
        }

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingPeriodsPage(BillingPeriodsFilter filter)
            => base.GetDataListPageAsync("sp_res_billing_periods_page", filter, objParams: new { filter.reference_date, filter.status });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetBillingPeriodsFields(Guid? oid, CommonViewInfo inputData = null)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_billing_periods_field",
                dynamicParam: inputData?.ConvertToParam(),
                objParams: inputData == null ? new { oid } : null);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriods(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_periods_set",
                dynamicParam: null,
                objParams: inputData.ToObject());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_periods_del", new { ArrOid = string.Join(",", arrOid) });

        public async Task<List<CommonValue>> GetBillingPeriodsStatusList()
            => await GetListAsync<CommonValue>("sp_res_billing_periods_status_list");

        /// <summary>
        /// Khóa/mở khóa kỳ thanh toán
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsLock(BillingPeriods_SetLocked inputParam)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_periods_set_locked", inputParam);
    }
}
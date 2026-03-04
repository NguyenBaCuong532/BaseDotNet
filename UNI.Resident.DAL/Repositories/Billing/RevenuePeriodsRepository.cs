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
    /// Kỳ tính dự thu
    /// </summary>
    public class RevenuePeriodsRepository : ResidentBaseRepository, IRevenuePeriodsRepository
    {
        public RevenuePeriodsRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetRevenuePeriodsFilter()
            => this.GetTableFilter("config_sp_res_RevenuePeriods_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetRevenuePeriodsPage(RevenuePeriodsFilter filter)
            => base.GetDataListPageAsync("sp_res_RevenuePeriods_page",
                filter,
                objParams: new
                {
                    filter.from_month,
                    filter.to_month
                });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetRevenuePeriodsFields(Guid? oid, CommonViewInfo inputData = null)
        {
            object objParams = oid != null ? new { oid } : inputData?.ConvertToParam();
            return this.GetFieldsAsync<viewBaseInfo>("sp_res_RevenuePeriods_field", dynamicParam: null, objParams);
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetRevenuePeriods(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_RevenuePeriods_set", inputData.ConvertToParam());

        /// <summary>
        /// Khóa kỳ tính dự thu
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetRevenuePeriodsLocked(RevenuePeriodsSetLocked inputParam)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_RevenuePeriods_locked",
                dynamicParam: null,
                new
                {
                    inputParam.Oid,
                    set_unlocked = inputParam.SetUnlocked
                });

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetRevenuePeriodsDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_RevenuePeriods_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
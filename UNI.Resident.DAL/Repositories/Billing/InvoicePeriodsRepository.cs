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
    /// Kỳ hóa đơn
    /// </summary>
    public class InvoicePeriodsRepository : ResidentBaseRepository, IInvoicePeriodsRepository
    {
        public InvoicePeriodsRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetInvoicePeriodsFilter()
            => this.GetTableFilter("config_sp_res_mas_invoice_periods_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetInvoicePeriodsPage(InvoicePeriodsFilter filter)
            => base.GetDataListPageAsync("sp_res_mas_invoice_periods_page",
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
        public Task<viewBaseInfo> GetInvoicePeriodsFields(Guid? oid)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_mas_invoice_periods_field", dynamicParam: null, new { oid });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetInvoicePeriods(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_mas_invoice_periods_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetInvoicePeriodsDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_mas_invoice_periods_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
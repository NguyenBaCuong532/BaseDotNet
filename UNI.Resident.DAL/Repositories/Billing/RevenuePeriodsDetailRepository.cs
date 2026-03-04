using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Billing
{
    /// <summary>
    /// Dự thu các căn hộ trước khi xuất hóa đơn
    /// </summary>
    public class RevenuePeriodsDetailRepository : ResidentBaseRepository, IRevenuePeriodsDetailRepository
    {
        public RevenuePeriodsDetailRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServiceReceiveEntryFilter()
            => this.GetTableFilter("config_sp_res_service_receive_entry_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServiceReceivablePage(ServiceExpectedRequestModel query)
        {
            return GetDataListPageAsync(
                //storedProcedure: "sp_res_service_receive_entry_page",
                storedProcedure: "sp_res_service_expected_page_new",
                filter: query,
                objParams: new
                {
                    revenue_periods_oid = query.RevenuePeriodId,
                    query.ProjectCd,
                    query.ToDate,
                    query.IsCalculated
                });
        }

        /// <summary>
        /// Lấy chi tiết dự thu
        /// </summary>
        /// <param name="receiveId"></param>
        /// <returns></returns>
        public async Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            const string storedProcedure = "sp_res_service_expected_details_field";
            return await GetFieldsAsync<ServiceExpectedDetailsInfo>(storedProcedure, new { receiveId });
        }

        /// <summary>
        /// Form tính dự thu
        /// </summary>
        /// <param name="apartmentId"> id căn hộ</param>
        /// <returns></returns>
        public async Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? apartmentId, Guid? revenuePeriodId = null, ServiceExpectedCalculatorInfo info = null)
        {
            const string storedProcedure = "sp_res_service_expected_calculator_field_v2";
            return await GetFieldsAsync<ServiceExpectedCalculatorInfo>(storedProcedure,
               objParams: info != null ? info.ToObject() : new { apartmentId, revenuePeriodId },
               readerHandler: async (data, result) =>
               {
                   if (data != null)
                   {
                       data.apartment_gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
                       var apartment = result.Read<object>().ToList();
                       data.apartment_dataList = new ResponseList<List<object>>(apartment, 100, 100);
                   }
                   return data;
               });
        }

        /// <summary>
        /// Thông tin tính dự thu
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info)
        {
            //const string storedProcedure = "sp_res_service_expectable_calculate_set";
            const string storedProcedure = "sp_res_service_expected_calculate_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.Apartments });
        }
    }
}
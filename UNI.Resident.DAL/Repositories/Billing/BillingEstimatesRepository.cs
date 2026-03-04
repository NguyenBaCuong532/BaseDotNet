using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Billing
{
    /// <summary>
    /// Kỳ thanh toán - Dự thu
    /// </summary>
    public class BillingEstimatesRepository : ResidentBaseRepository, IBillingEstimatesRepository
    {
        public BillingEstimatesRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingEstimatesFilter()
            => this.GetTableFilter("service_expected_filterX");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingEstimatesPage(ServiceExpectedRequestModel query)
            => await GetDataListPageAsync("sp_res_service_expected_page_new", query,
                new
                {
                    periods_oid = query.PeriodsOid,
                    query.ProjectCd,
                    query.ToDate,
                    query.IsCalculated
                });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<viewBaseInfo> GetBillingEstimatesFields(int? receiveId)
        {
            const string storedProcedure = "sp_res_service_expected_details_field";
            return await GetFieldsAsync<ServiceExpectedDetailsInfo>(storedProcedure, new { receiveId });
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingEstimates(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_estimates_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingEstimatesDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_billing_estimates_del", new { ArrOid = string.Join(",", arrOid) });

        /// <summary>
        /// Form cấu hình tính dự thu
        /// </summary>
        /// <param name="periodsOid"></param>
        /// <param name="ApartmentId"></param>
        /// <returns></returns>
        public async Task<ServiceExpectedCalculatorInfo> GetBillingEstimatesCalculatorFields(Guid periodsOid, int? apartmentId)
        {
            const string storedProcedure = "sp_res_service_expected_calculator_field";
            return await GetFieldsAsync<ServiceExpectedCalculatorInfo>(storedProcedure,
                new
                {
                    periods_oid = periodsOid,
                    apartmentId
                },
                async (data, result) =>
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
        /// 
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingEstimatesCalculatorFields(ServiceExpectedCalculatorInfo info)
        {
            const string storedProcedure = "sp_res_service_expected_calculate_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.Apartments });
        }

        /// <summary>
        /// Chi tiết dịch vụ chung
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingEstimatesExpectedFeePage(ServiceExpectedFeeRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_fee_page_new";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
        }

        /// <summary>
        /// Chi tiết điện/nước
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<ServiceExpectedLivingPage> GetBillingEstimatesExpectedLivingPage(ServiceExpectedLivingRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_living_page";
            var param = new DynamicParameters();
            param.Add("@filter", query.filter);
            param.Add("@receiveId", query.ReceiveId);

            param.Add("@gridWidth", query.gridWidth);
            param.Add("@Offset", query.offSet);
            param.Add("@PageSize", query.pageSize);
            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
            param.Add("@GridKey", "", DbType.String, ParameterDirection.InputOutput);
            var rs = await base.GetMultipleAsync(storedProcedure,
            param,
            async result =>
            {
                var data = new ServiceExpectedLivingPage();
                if (query.offSet == null || query.offSet == 0)
                {
                    data.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
                    data.gridflexLivingDetails = result.Read<viewGridFlex>().ToList();
                }
                var livingList = result.Read<ServiceExpectedLiving>().ToList();
                var livingDetailsList = result.Read<ServiceExpectedLivingDetail>().ToList();

                foreach (var liv in livingList)
                {
                    liv.livingDetails = livingDetailsList.Where(a => a.TrackingId == liv.TrackingId).ToList();
                }
                data.dataList = new ResponseList<List<object>>(livingList != null ? livingList.Cast<object>().ToList() : new List<object>(), param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"), param.Get<string>("@GridKey"));
                return data;
            });
            return rs;
        }

        /// <summary>
        /// Phí gửi xe
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingEstimatesExpectedVehiclePage(ServiceExpectedVehicleRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_vehicle_page_new";
            return await GetDataListPageAsync(storedProcedure, query, new
            {
                query.ReceiveId,
                ProjectCd = base.ProjectCode
            });
        }

        /// <summary>
        /// Dịch vụ khác
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingEstimatesExpectedExtendPage(ServiceExpectedExtendRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_extend_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
        }

        /// <summary>
        /// Thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetBillingEstimatesExpectedExtendFields(int receiveId)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_service_expected_extend_field", dynamicParam: null, new { receiveId });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingEstimatesExpectedExtendFields(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_expected_extend_set", inputData.ConvertToParam());

        /// <summary>
        /// Công nợ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingEstimatesExpectedDebtPage(ServiceExpectedExtendRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_debt_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
        }
    }
}
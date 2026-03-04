using DocumentFormat.OpenXml.EMMA;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Billing
{
    /// <summary>
    /// Kỳ thanh toán điện
    /// </summary>
    public class BillingPeriodsElectricRepository : ResidentBaseRepository, IBillingPeriodsElectricRepository
    {
        public BillingPeriodsElectricRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingPeriodsElectricFilter()
            => this.GetTableFilter("service_living_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingPeriodsElectricPage(ServiceLivingMeterRequestModel query)
            => GetDataListPageAsync("sp_res_service_living_meter_page",
                filter: query,
                objParams: new
                {
                    query.livingType,
                    query.projectCd,
                    query.month,
                    query.year,
                    periods_oid = query.PeriodsOid
                });

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<viewBaseInfo> GetBillingPeriodsElectricFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null)
        {
            var objParam = info != null
                ? info.ToObject()
                : new
                {
                    periods_oid = periodsOid,
                    livingId,
                    trackingId
                };
            return await GetFieldsAsync<ServiceLivingMeterInfo>("sp_res_service_living_meter_field", objParam);
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsElectric(ServiceLivingMeterInfo info)
            => await SetInfoAsync<BaseValidate>("sp_service_living_meter_set", info, new { info.LivingId, info.TrackingId });

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsElectricDelete(DeleteMultiServiceLivingMeter inputParam)
        {
            const string storedProcedure = "sp_res_service_living_meter_multi_del";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new
                {
                    TrackingIds = string.Join(",", inputParam.Ids)
                });
        }

        /// <summary>
        /// Import chỉ số điện
        /// </summary>
        /// <param name="importSet"></param>
        /// <param name="check"></param>
        /// <returns></returns>
        public async Task<ImportListPage> SetBillingPeriodsElectricImport(LivingImportSet importSet, bool? check)
        {
            const string storedProcedure = "sp_res_service_living_imports";
            return await base.SetImport<LivingImportItem, LivingImportSet>(storedProcedure,
                importSet, "livingImport", "LivingImportType",
                new
                {
                    check,
                    importSet.livingTypeId,
                    periods_oid = importSet.PeriodsOid
                });
        }

        /// <summary>
        /// Form thông tin tính toán tiền điện
        /// </summary>
        /// <param name="trackingId"></param>
        /// <returns></returns>
        public async Task<ServiceLivingMeterCalculatorInfo> GetBillingPeriodsElectricCalculatorFields(Guid periodsOid, int trackingId)
            => await GetFieldsAsync<ServiceLivingMeterCalculatorInfo>("sp_res_service_living_meter_calculator_field2",
                new
                {
                    periods_oid = periodsOid,
                    trackingId
                });

        /// <summary>
        /// Tính chỉ giá từng căn hộ
        /// </summary>
        /// <param name="trackingId"></param>
        /// <param name="projectCd"></param>
        /// <param name="livingType"></param>
        /// <param name="periodMonth"></param>
        /// <param name="periodYear"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsElectricCalculate(int trackingId, string projectCd, int livingType, int periodMonth, int periodYear)
            => await GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_living_meter_electric_calculate", new { trackingId, projectCd, livingType, periodMonth, periodYear });

        /// <summary>
        /// Tính chỉ giá các căn hộ theo bộ lọc
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsElectricCalculateAll(ServiceLivingMeterCalculatorInfo info)
             => await GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_living_meter_electric_calculate",
                 objParams: info.ToObject(),
                 parametersHandler: param =>
                 {
                     param.Add("TrackingId", info.TrackingId);
                     param.Add("LivingType", 1);
                     return param;
                 },
                 commandTimeout: 300);
    }
}
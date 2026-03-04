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
    /// Kỳ thanh toán nước
    /// </summary>
    public class BillingPeriodsWaterRepository : ResidentBaseRepository, IBillingPeriodsWaterRepository
    {
        public BillingPeriodsWaterRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingPeriodsWaterFilter()
            => this.GetTableFilter("service_living_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<CommonDataPage> GetBillingPeriodsWaterPage(ServiceLivingMeterRequestModel query)
            => await GetDataListPageAsync("sp_res_service_living_meter_page",
                query,
                new
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
        public Task<ServiceLivingMeterInfo> GetBillingPeriodsWaterFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null)
        {
            var objParam = info != null
                ? info.ToObject()
                : new
                {
                    periods_oid = periodsOid,
                    livingId,
                    trackingId
                };
            return GetFieldsAsync<ServiceLivingMeterInfo>("sp_res_service_living_meter_field", objParam);
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriodsWater(ServiceLivingMeterInfo info)
            => SetInfoAsync<BaseValidate>("sp_service_living_meter_set", info, new { info.LivingId, info.TrackingId });

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsWaterDelete(DeleteMultiServiceLivingMeter inputParam)
        {
            const string storedProcedure = "sp_res_service_living_meter_multi_del";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new
                {
                    TrackingIds = string.Join(",", inputParam.Ids)
                });
        }

        /// <summary>
        /// Kiểm tra và xác nhận thực hiện import
        /// </summary>
        /// <param name="organizes"></param>
        /// <param name="check"></param>
        /// <returns></returns>
        public Task<ImportListPage> SetBillingPeriodsWaterImport(LivingImportSet importSet, bool? check)
            => base.SetImport<LivingImportItem, LivingImportSet>("sp_res_service_living_imports", importSet, "livingImport", "LivingImportType", new { check, importSet.livingTypeId });

        /// <summary>
        /// Tính toán tiền nước từng căn hộ
        /// </summary>
        /// <param name="trackingId"></param>
        /// <param name="projectCd"></param>
        /// <param name="livingType"></param>
        /// <param name="periodMonth"></param>
        /// <param name="periodYear"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsWaterCalculate(int trackingId, string projectCd, int livingType, int periodMonth, int periodYear)
        {
            const string storedProcedure = "sp_res_service_living_meter_water_calculate";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { trackingId, projectCd, livingType, periodMonth, periodYear });
        }

        /// <summary>
        /// Tính toán tiền nước các căn hộ theo tham số
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsWaterCalculateAll(ServiceLivingMeterCalculatorInfo info)
        {
            return await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_living_meter_water_calculate",
                 objParams: info.ToObject(),
                 parametersHandler: param =>
                 {
                     param.Add("TrackingId", info.TrackingId);
                     param.Add("LivingType", 2);
                     return param;
                 });
        }
    }
}
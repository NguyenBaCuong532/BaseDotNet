using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Billing;
using UNI.Resident.DAL.Interfaces.Billing;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Billing
{
    /// <summary>
    /// Kỳ thanh toán nước
    /// </summary>
    public class BillingPeriodsWaterService : UniBaseService, IBillingPeriodsWaterService
    {
        private readonly IBillingPeriodsWaterRepository _repository;

        public BillingPeriodsWaterService(IBillingPeriodsWaterRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingPeriodsWaterFilter()
            => _repository.GetBillingPeriodsWaterFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingPeriodsWaterPage(ServiceLivingMeterRequestModel filter)
            => _repository.GetBillingPeriodsWaterPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<ServiceLivingMeterInfo> GetBillingPeriodsWaterFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null)
            => _repository.GetBillingPeriodsWaterFields(periodsOid, livingId, trackingId, info);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriodsWater(ServiceLivingMeterInfo inputData)
            => _repository.SetBillingPeriodsWater(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriodsWaterDelete(DeleteMultiServiceLivingMeter inputParam)
            => _repository.SetBillingPeriodsWaterDelete(inputParam);

        /// <summary>
        /// File mẫu import chỉ số nước
        /// </summary>
        /// <param name="livingTypeId"></param>
        /// <returns></returns>
        public async Task<BaseValidate<Stream>> GetBillingPeriodsWaterImportTemp(int livingTypeId)
        {
            try
            {
                var r = new FlexcellUtils();
                var template = await System.IO.File.ReadAllBytesAsync($"templates/living/import_living.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, new DataSet(), p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        /// <summary>
        /// Kiểm tra và xác nhận thực hiện import
        /// </summary>
        /// <param name="organizes"></param>
        /// <param name="check"></param>
        /// <returns></returns>
        public async Task<ImportListPage> SetBillingPeriodsWaterImport(LivingImportSet organizes, bool? check)
            => await _repository.SetBillingPeriodsWaterImport(organizes, check);

        /// <summary>
        /// Tính toán tiền nước từng căn hộ
        /// </summary>
        /// <param name="trackingId"></param>
        /// <param name="projectCd"></param>
        /// <param name="livingType"></param>
        /// <param name="periodMonth"></param>
        /// <param name="periodYear"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsWaterCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
            => await _repository.SetBillingPeriodsWaterCalculate(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);

        /// <summary>
        /// Tính toán tiền nước các căn hộ theo tham số
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsWaterCalculateAll(ServiceLivingMeterCalculatorInfo info)
            => await _repository.SetBillingPeriodsWaterCalculateAll(info);
    }
}
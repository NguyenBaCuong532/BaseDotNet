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
    /// Kỳ thanh toán điện
    /// </summary>
    public class BillingPeriodsElectricService : UniBaseService, IBillingPeriodsElectricService
    {
        private readonly IBillingPeriodsElectricRepository _repository;

        public BillingPeriodsElectricService(IBillingPeriodsElectricRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetBillingPeriodsElectricFilter()
            => _repository.GetBillingPeriodsElectricFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetBillingPeriodsElectricPage(ServiceLivingMeterRequestModel filter)
            => _repository.GetBillingPeriodsElectricPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetBillingPeriodsElectricFields(Guid periodsOid, int livingId, int trackingId, ServiceLivingMeterInfo info = null)
            => _repository.GetBillingPeriodsElectricFields(periodsOid, livingId, trackingId, info);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriodsElectric(ServiceLivingMeterInfo info)
            => _repository.SetBillingPeriodsElectric(info);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetBillingPeriodsElectricDelete(DeleteMultiServiceLivingMeter inputParam)
            => _repository.SetBillingPeriodsElectricDelete(inputParam);

        /// <summary>
        /// Mẫu import chỉ số điện
        /// </summary>
        /// <param name="livingTypeId"></param>
        /// <returns></returns>
        public async Task<BaseValidate<Stream>> GetBillingPeriodsElectricImportTemp(int livingTypeId)
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
        /// Import chỉ số điện
        /// </summary>
        /// <param name="organizes"></param>
        /// <param name="check"></param>
        /// <returns></returns>
        public async Task<ImportListPage> SetBillingPeriodsElectricImport(LivingImportSet organizes, bool? check)
            => await _repository.SetBillingPeriodsElectricImport(organizes, check);

        /// <summary>
        /// Form thông tin tính toán tiền điện
        /// </summary>
        /// <param name="trackingId"></param>
        /// <returns></returns>
        public async Task<ServiceLivingMeterCalculatorInfo> GetBillingPeriodsElectricCalculatorFields(Guid periodsOid, int trackingId)
            => await _repository.GetBillingPeriodsElectricCalculatorFields(periodsOid, trackingId);

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
            => await _repository.SetBillingPeriodsElectricCalculate(trackingId, projectCd, livingType, periodMonth, periodYear);

        /// <summary>
        /// Tính chỉ giá các căn hộ theo bộ lọc
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetBillingPeriodsElectricCalculateAll(ServiceLivingMeterCalculatorInfo info)
            => await _repository.SetBillingPeriodsElectricCalculateAll(info);
    }
}
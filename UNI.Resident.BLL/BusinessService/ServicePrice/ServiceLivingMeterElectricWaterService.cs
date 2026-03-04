using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.DAL.Interfaces.ServicePrice;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Điện
    /// </summary>
    public class ServiceLivingMeterElectricWaterService : IServiceLivingMeterElectricWaterService
    {
        private readonly IServiceLivingMeterElectricWaterRepository _repository;
        private readonly IFeeServiceService _serviceOld;

        public ServiceLivingMeterElectricWaterService(IServiceLivingMeterElectricWaterRepository repository,
            IFeeServiceService serviceOld)
        {
            _repository = repository;
            _serviceOld = serviceOld;
        }

        #region electric-water -- Điện nước
        public CommonViewInfo GetServiceLivingMeterElectricWaterFilter(string userId)
        {
            return _repository.GetServiceLivingMeterElectricWaterFilter(userId);
        }
        public async Task<CommonDataPage> GetServiceLivingMeterElectricWaterPage(ServiceLivingMeterRequestModel query)
        {
            return await _repository.GetServiceLivingMeterElectricWaterPage(query);
        }

        public async Task<ServiceLivingMeterInfo> GetServiceLivingMeterElectricWaterInfo(int LivingId, int TrackingId)
        {
            return await _repository.GetServiceLivingMeterElectricWaterInfo(LivingId, TrackingId);
        }

        public async Task<BaseValidate> SetServiceLivingMeterElectricWaterInfo(ServiceLivingMeterInfo info)
        {
            return await _repository.SetServiceLivingMeterElectricWaterInfo(info);
        }

        public async Task<BaseValidate> DeleteServiceLivingElectricWaterMeter(int trackingId)
        {
            return await _repository.DeleteServiceLivingElectricWaterMeter(trackingId);
        }

        public async Task<BaseValidate> SetServiceLivingMeterElectricCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
        {
            return await _repository.SetServiceLivingMeterElectricCalculate(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
        }
        public async Task<BaseValidate> SetServiceLivingMeterElectricCalculateAll(ServiceLivingMeterCalculatorInfo info)
        {
            return await _repository.SetServiceLivingMeterElectricCalculateAll(info);
        }
        public async Task<BaseValidate> SetServiceLivingMeterWaterCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
        {
            return await _repository.SetServiceLivingMeterWaterCalculate(trackingId, projectCd, LivingType, PeriodMonth, PeriodYear);
        }
        public async Task<BaseValidate> SetServiceLivingMeterWaterCalculateAll(ServiceLivingMeterCalculatorInfo info)
        {
            return await _repository.SetServiceLivingMeterWaterCalculateAll(info);
        }
        public async Task<ServiceLivingMeterCalculatorInfo> GetServiceLivingMeterElectricWaterCalculatorInfo(int trackingId)
        {
            return await _repository.GetServiceLivingMeterElectricWaterCalculatorInfo(trackingId);
        }
        public async Task<BaseValidate> DelMultiServiceLivingElectricWaterMeter(DeleteMultiServiceLivingMeter deleteMultiService)
        {
            return await _repository.DelMultiServiceLivingElectricWaterMeter(deleteMultiService);
        }
        #endregion

        #region expected -- Dự thu
        public CommonViewInfo GetServiceExpectedFilter(string userId)
        {
            return _repository.GetServiceExpectedFilter(userId);
        }

        public async Task<CommonDataPage> GetServiceExpectedPage(ServiceExpectedRequestModel query)
        {
            return await _repository.GetServiceExpectedPage(query);
        }

        public async Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? ApartmentId, string projectCd)
        {
            return await _repository.GetServiceExpectedCalculatorInfo(ApartmentId, projectCd);
        }

        /// <summary>
        /// Tính dự thu
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info)
        {
            var runOldVersion = false; // Chạy phiên bản cũ từ dịch vụ FeeService
            if (runOldVersion)
                return await _serviceOld.SetServiceExpectedCalculatorInfo(info);

            return await _repository.SetServiceExpectedCalculatorInfo(info);
        }

        public async Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            return await _repository.GetServiceExpectedDetailsInfo(receiveId);
        }

        public async Task<CommonDataPage> GetServiceExpectedFeePage(ServiceExpectedFeeRequestModel query)
        {
            return await _repository.GetServiceExpectedFeePage(query);
        }

        public async Task<CommonDataPage> GetServiceExpectedVehiclePage(ServiceExpectedVehicleRequestModel query)
        {
            return await _repository.GetServiceExpectedVehiclePage(query);
        }

        public async Task<ServiceExpectedLivingPage> GetServiceExpectedLivingPage(ServiceExpectedLivingRequestModel query)
        {
            return await _repository.GetServiceExpectedLivingPage(query);
        }

        public async Task<CommonDataPage> GetServiceExpectedExtendPage(ServiceExpectedExtendRequestModel query)
        {
            return await _repository.GetServiceExpectedExtendPage(query);
        }

        /// <summary>
        /// Thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServiceExpectedExtendFields(int receiveId)
            => _repository.GetServiceExpectedExtendFields(receiveId);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServiceExpectedExtendFields(CommonViewInfo inputData)
            => _repository.SetServiceExpectedExtendFields(inputData);

        public async Task<BaseValidate> DeleteServiceExpected(int receivableId)
        {
            return await _repository.DeleteServiceExpected(receivableId);
        }

        public async Task<ServiceExpectedReceivableExtendInfo> GetServiceExpectedReceivableExtendInfo(int receiveId)
        {
            return await _repository.GetServiceExpectedReceivableExtendInfo(receiveId);
        }

        public async Task<BaseValidate> SetServiceExpectedReceivableExtendInfo(ServiceExpectedReceivableExtendInfo info)
        {
            return await _repository.SetServiceExpectedReceivableExtendInfo(info);
        }

        public async Task<CommonDataPage> GetServiceExpectedDebtPage(ServiceExpectedExtendRequestModel query)
        {
            return await _repository.GetServiceExpectedDebtPage(query);
        }

        #endregion
    }
}
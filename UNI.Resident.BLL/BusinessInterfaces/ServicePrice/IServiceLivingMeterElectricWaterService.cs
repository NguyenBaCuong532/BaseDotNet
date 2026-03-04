using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.ServicePrice
{
    public interface IServiceLivingMeterElectricWaterService
    {
        #region electric-water -- Điện nước
        CommonViewInfo GetServiceLivingMeterElectricWaterFilter(string userId);
        Task<CommonDataPage> GetServiceLivingMeterElectricWaterPage(ServiceLivingMeterRequestModel query);
        Task<ServiceLivingMeterInfo> GetServiceLivingMeterElectricWaterInfo(int LivingId, int TrackingId);
        Task<BaseValidate> SetServiceLivingMeterElectricWaterInfo(ServiceLivingMeterInfo info);
        Task<BaseValidate> DeleteServiceLivingElectricWaterMeter(int trackingId);
        Task<BaseValidate> SetServiceLivingMeterElectricCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear);
        Task<BaseValidate> SetServiceLivingMeterElectricCalculateAll(ServiceLivingMeterCalculatorInfo info);
        Task<BaseValidate> SetServiceLivingMeterWaterCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear);
        Task<BaseValidate> SetServiceLivingMeterWaterCalculateAll(ServiceLivingMeterCalculatorInfo info);
        Task<ServiceLivingMeterCalculatorInfo> GetServiceLivingMeterElectricWaterCalculatorInfo(int trackingId);
        Task<BaseValidate> DelMultiServiceLivingElectricWaterMeter(DeleteMultiServiceLivingMeter deleteMultiService);
        #endregion

        #region expected -- Dự thu
        CommonViewInfo GetServiceExpectedFilter(string userId);
        Task<CommonDataPage> GetServiceExpectedPage(ServiceExpectedRequestModel query);
        Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? ApartmentId, string projectCd);
        Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info);
        Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId); 
        Task<CommonDataPage> GetServiceExpectedFeePage(ServiceExpectedFeeRequestModel query);
        Task<CommonDataPage> GetServiceExpectedVehiclePage(ServiceExpectedVehicleRequestModel query);
        Task<ServiceExpectedLivingPage> GetServiceExpectedLivingPage(ServiceExpectedLivingRequestModel query);
        Task<CommonDataPage> GetServiceExpectedExtendPage(ServiceExpectedExtendRequestModel query);

        Task<viewBaseInfo> GetServiceExpectedExtendFields(int receiveId);

        Task<BaseValidate> SetServiceExpectedExtendFields(CommonViewInfo inputData);

        Task<BaseValidate> DeleteServiceExpected(int receivableId);
        
        Task<ServiceExpectedReceivableExtendInfo> GetServiceExpectedReceivableExtendInfo(int receiveId);
        
        Task<BaseValidate> SetServiceExpectedReceivableExtendInfo(ServiceExpectedReceivableExtendInfo info);

        Task<CommonDataPage> GetServiceExpectedDebtPage(ServiceExpectedExtendRequestModel query);
        #endregion
    }
}
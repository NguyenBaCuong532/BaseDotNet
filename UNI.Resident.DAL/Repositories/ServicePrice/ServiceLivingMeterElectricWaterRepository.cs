using Dapper;
using DapperParameters;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.DAL.Interfaces.ServicePrice;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Invoice;
using UNI.Resident.Model.Resident;
using UNI.Utils;
using IHostingEnvironment = Microsoft.AspNetCore.Hosting.IHostingEnvironment;


namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Điện
    /// </summary>
    public class ServiceLivingMeterElectricWaterRepository : ResidentBaseRepository, IServiceLivingMeterElectricWaterRepository
    {
        //protected string _connectionString;
        protected ILogger<ServiceLivingMeterElectricWaterRepository> _logger;
        private IHostingEnvironment _environment;
        private FlexcellUtils flexcellUtils;

        public ServiceLivingMeterElectricWaterRepository(IResidentCommonBaseRepository common, IConfiguration configuration,
            ILogger<ServiceLivingMeterElectricWaterRepository> logger,
            IHostingEnvironment environment) : base(common, false)
        {
            //_connectionString = configuration.GetConnectionString("SHomeConnection");
            _environment = environment;
            _logger = logger;
            flexcellUtils = new FlexcellUtils();
        }

        #region electric-water -- Điện nước
        public CommonViewInfo GetServiceLivingMeterElectricWaterFilter(string userId)
        {
            const string storedProcedure = "sp_res_service_living_meter_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { }).Result;
        }
        public async Task<CommonDataPage> GetServiceLivingMeterElectricWaterPage(ServiceLivingMeterRequestModel query)
        {
            const string storedProcedure = "sp_res_service_living_meter_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.livingType, query.projectCd, query.month, query.year });
        }
        public async Task<ServiceLivingMeterInfo> GetServiceLivingMeterElectricWaterInfo(int LivingId, int TrackingId)
        {
            const string storedProcedure = "sp_res_service_living_meter_field";
            return await GetFieldsAsync<ServiceLivingMeterInfo>(storedProcedure, new { LivingId, TrackingId });
        }
        public async Task<BaseValidate> SetServiceLivingMeterElectricWaterInfo(ServiceLivingMeterInfo info)
        {
            const string storedProcedure = "sp_service_living_meter_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.LivingId, info.TrackingId });
        }
        public async Task<BaseValidate> DeleteServiceLivingElectricWaterMeter(int trackingId)
        {
            const string storedProcedure = "sp_res_service_living_meter_del";
            return await DeleteAsync(storedProcedure, new { trackingId });
        }
        public async Task<BaseValidate> SetServiceLivingMeterElectricCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
        {
            const string storedProcedure = "sp_res_service_living_meter_electric_calculate";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { trackingId, projectCd, LivingType, PeriodMonth, PeriodYear });
        }
        public async Task<BaseValidate> SetServiceLivingMeterElectricCalculateAll(ServiceLivingMeterCalculatorInfo info)
        {
            const string storedProcedure = "sp_res_service_living_meter_electric_calculate";
            return await SetInfoAsync<BaseValidate>(storedProcedure, null, new
            {
                info.TrackingId,
                ProjectCd = info.GetValueByFieldName("ProjectCd"),
                LivingType = 1,
                PeriodMonth = int.Parse(info.GetValueByFieldName("PeriodMonth")),
                PeriodYear = int.Parse(info.GetValueByFieldName("PeriodYear"))
            });
        }
        public async Task<BaseValidate> SetServiceLivingMeterWaterCalculate(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
        {
            const string storedProcedure = "sp_res_service_living_meter_water_calculate";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { trackingId, projectCd, LivingType, PeriodMonth, PeriodYear });
        }
        public async Task<BaseValidate> SetServiceLivingMeterWaterCalculateAll(ServiceLivingMeterCalculatorInfo info)
        {
            const string storedProcedure = "sp_res_service_living_meter_water_calculate";
            return await SetInfoAsync<BaseValidate>(storedProcedure, null, new
            {
                info.TrackingId,
                ProjectCd = info.GetValueByFieldName("ProjectCd"),
                LivingType = 2,
                PeriodMonth = int.Parse(info.GetValueByFieldName("PeriodMonth")),
                PeriodYear = int.Parse(info.GetValueByFieldName("PeriodYear"))
            });
        }
        public async Task<ServiceLivingMeterCalculatorInfo> GetServiceLivingMeterElectricWaterCalculatorInfo(int trackingId)
        {
            const string storedProcedure = "sp_res_service_living_meter_calculator_field2";
            return await GetFieldsAsync<ServiceLivingMeterCalculatorInfo>(storedProcedure, new { trackingId });
        }
        public async Task<BaseValidate> DelMultiServiceLivingElectricWaterMeter(DeleteMultiServiceLivingMeter deleteMultiService)
        {
            const string storedProcedure = "sp_res_service_living_meter_multi_del";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { TrackingIds = string.Join(",", deleteMultiService.Ids) });
            //    new {livingId =string.Join(",", deleteMultiService.Ids.ToArray()), tableName="MAS_Apartment_Service_Living",deleteMultiService.LivingTypeId });
        }
        #endregion

        #region expected -- Dự thu
        public CommonViewInfo GetServiceExpectedFilter(string userId)
        {
            const string storedProcedure = "sp_res_service_expected_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId }).Result;
        }

        public async Task<CommonDataPage> GetServiceExpectedPage(ServiceExpectedRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_page_new";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.ToDate, query.IsCalculated });
        }
        public async Task<ServiceExpectedCalculatorInfo> GetServiceExpectedCalculatorInfo(int? ApartmentId, string projectCd)
        {
            const string storedProcedure = "sp_res_service_expected_calculator_field";
            return await GetFieldsAsync<ServiceExpectedCalculatorInfo>(storedProcedure, new { ApartmentId, projectCd }
            , async (data, result) =>
            {
                if (data != null)
                {
                    data.apartment_gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
                    var apartment = result.Read<object>().ToList();
                    data.apartment_dataList = new ResponseList<List<object>>(apartment, 100, 100);
                }
                return data;
            }
            );
        }

        public async Task<BaseValidate> SetServiceExpectedCalculatorInfo(ServiceExpectedCalculatorInfo info)
        {
            const string storedProcedure = "sp_res_service_expected_calculate_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.Apartments });
        }

        public async Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            const string storedProcedure = "sp_res_service_expected_details_field";
            return await GetFieldsAsync<ServiceExpectedDetailsInfo>(storedProcedure, new { receiveId });
        }

        public async Task<CommonDataPage> GetServiceExpectedFeePage(ServiceExpectedFeeRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_fee_page_new";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
        }

        public async Task<CommonDataPage> GetServiceExpectedVehiclePage(ServiceExpectedVehicleRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_vehicle_page_new";
            return await GetDataListPageAsync(storedProcedure, query, new
            {
                query.ReceiveId,
                ProjectCd = base.ProjectCode
            });
        }

        public async Task<ServiceExpectedLivingPage> GetServiceExpectedLivingPage(ServiceExpectedLivingRequestModel query)
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

        public async Task<CommonDataPage> GetServiceExpectedExtendPage(ServiceExpectedExtendRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_extend_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
        }

        /// <summary>
        /// Thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServiceExpectedExtendFields(int receiveId)
            => this.GetFieldsAsync<viewBaseInfo>("sp_res_service_expected_extend_field", dynamicParam: null, new { receiveId });

        /// <summary>
        /// Lưu thông tin Thêm/Sửa dịch vụ khác
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServiceExpectedExtendFields(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_service_expected_extend_set", inputData.ConvertToParam());

        public async Task<BaseValidate> DeleteServiceExpected(int receivableId)
        {
            const string storedProcedure = "sp_res_service_expected_del";
            return await DeleteAsync(storedProcedure, new { receivableId });
        }

        public async Task<ServiceExpectedReceivableExtendInfo> GetServiceExpectedReceivableExtendInfo(int receiveId)
        {
            const string storedProcedure = "sp_res_service_expected_receivable_extend_field";
            return await GetFieldsAsync<ServiceExpectedReceivableExtendInfo>(storedProcedure, new { ReceivedId = receiveId });
        }

        public async Task<BaseValidate> SetServiceExpectedReceivableExtendInfo(ServiceExpectedReceivableExtendInfo info)
        {
            const string storedProcedure = "sp_res_service_expected_receivable_extend_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.ReceiveId });
        }

        public async Task<CommonDataPage> GetServiceExpectedDebtPage(ServiceExpectedExtendRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_debt_page";
            return await GetDataListPageAsync(storedProcedure, query, new {query.ReceiveId});
        }
       
        #endregion
    }
}
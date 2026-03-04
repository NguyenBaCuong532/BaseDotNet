using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Settings;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Invoice;
using UNI.Resident.Model.Resident;
using UNI.Utils;
using IHostingEnvironment = Microsoft.AspNetCore.Hosting.IHostingEnvironment;

namespace UNI.Resident.DAL.Repositories.Invoice
{
    public class FeeServiceRepository : UniBaseRepository, IFeeServiceRepository
    {
        //protected string _connectionString;
        protected ILogger<FeeServiceRepository> _logger;
        private IHostingEnvironment _environment;
        private FlexcellUtils flexcellUtils;
        private readonly IProjectConfigRepository _projectConfRepo;

        public FeeServiceRepository(IUniCommonBaseRepository common, IConfiguration configuration, ILogger<FeeServiceRepository> logger,
            IHostingEnvironment environment, IProjectConfigRepository projectConfRepo) : base(common)
        {
            //_connectionString = configuration.GetConnectionString("SHomeConnection");
            _environment = environment;
            _logger = logger;
            flexcellUtils = new FlexcellUtils();
            _projectConfRepo = projectConfRepo;
        }

        #region web-FeeService

        public async Task<ApartmentFeeInfo> GetApartmentFeeInfo(string ApartmentId)
        {
            const string storedProcedure = "sp_res_apartment_fee_field";
            return await GetFieldsAsync<ApartmentFeeInfo>(storedProcedure, new { ApartmentId });
        }
        public async Task<ApartmentFeeInfo> SetApartmentFeeInfoDraft(ApartmentFeeInfo info)
        {
            const string storedProcedure = "sp_res_apartment_fee_field_draft";
            return await SetInfoAsync<ApartmentFeeInfo>(storedProcedure, info, param =>
            {
                param.Add("@apartmentId", info.Id);
                return param;
            });
        }
        public async Task<BaseValidate> SetApartmentFeeInfo(ApartmentFeeInfo info)
        {
            const string storedProcedure = "sp_res_apartment_fee_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new
            {
                ApartmentId = info.GetValueByFieldName("ApartmentId"),
                IsFeeStart = info.GetValueByFieldName("isFeeStart"),
                FeeStart = info.GetValueByFieldName("FeeStart"),
                IsFree = info.GetValueByFieldName("IsFree"),
                IsRent = info.GetValueByFieldName("IsRent"),
                FreeMonth = info.GetValueByFieldName("FreeMonth"),
                FreeToDate = info.GetValueByFieldName("FreeToDate"),
                FeeNote = info.GetValueByFieldName("FeeNote"),
                IsReceived = info.GetValueByFieldName("IsReceived"),
                DebitAmt = info.GetValueByFieldName("DebitAmt"),
                ReceiveDate = info.GetValueByFieldName("ReceiveDate")
            });
        }
        public async Task<CommonDataPage> GetServiceLivingPage(ServiceLivingRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_service_living_page_byid";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }
        public async Task<ServiceLivingInfo> GetServiceLivingInfo(int? LivingId)
        {
            const string storedProcedure = "sp_res_apartment_service_living_field";
            return await GetFieldsAsync<ServiceLivingInfo>(storedProcedure, new { LivingId });
        }
        public async Task<BaseValidate> SetServiceLivingInfo(ServiceLivingInfo info)
        {
            const string storedProcedure = "sp_res_apartment_service_living_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new
            {
                info.LivingId,
                CustId = info.GetValueByFieldName("CustId"),
                CustPhone = info.GetValueByFieldName("CustPhone"),
                ApartmentId = info.GetValueByFieldName("ApartmentId"),
                ContractNo = info.GetValueByFieldName("ContractNo"),
                ContractDate = info.GetValueByFieldName("ContractDate"),
                MeterSerial = info.GetValueByFieldName("MeterSerial"),
                MeterNumber = info.GetValueByFieldName("MeterNumber"),
                StartDate = info.GetValueByFieldName("StartDate"),
                DeliverName = info.GetValueByFieldName("DeliverName"),
                LivingType = info.GetValueByFieldName("LivingType"),
                ProviderCd = info.GetValueByFieldName("ProviderCd"),
                Note = info.GetValueByFieldName("Note"),
                EmployeeCd = info.GetValueByFieldName("EmployeeCd"),
                NumPersonWater = info.GetValueByFieldName("NumPersonWater")
            });
        }
        public async Task<BaseValidate> DeleteServiceLiving(int? LivingId)
        {
            const string storedProcedure = "sp_res_apartment_service_living_del";
            return await DeleteAsync(storedProcedure, new { LivingId });
        }

        public async Task<CommonDataPage> GetServiceCutHistoryPage(ServiceCutHistoryFilterModel query)
        {
            const string storedProcedure = "sp_res_apartment_service_cut_history_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }
        public async Task<ServiceCutHistoryInfo> GetServiceCutHistoryInfo(string Id, string ApartmentId)
        {
            const string storedProcedure = "sp_res_apartment_service_cut_history_field";
            return await GetFieldsAsync<ServiceCutHistoryInfo>(storedProcedure, new { Id, ApartmentId });
        }
        public async Task<BaseValidate> SetServiceCutHistoryInfo(ServiceCutHistoryInfo info)
        {
            const string storedProcedure = "sp_res_apartment_service_cut_history_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new
            {
                info.ApartmentId,
                info.Id,
                CutType = info.GetValueByFieldName("CutType"),
                CutStartDate = info.GetValueByFieldName("CutStartDate"),
                CutEndDate = info.GetValueByFieldName("CutEndDate"),
                Reason = info.GetValueByFieldName("Reason")
            });
        }
        public async Task<BaseValidate> DeleteServiceCutHistory(string Id)
        {
            const string storedProcedure = "sp_res_apartment_service_cut_history_del";
            return await DeleteAsync(storedProcedure, new { Id });
        }


        public async Task<CommonDataPage> GetServiceExtendPage(ServiceExtendRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_service_extend_page_byid";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }

        public Task<ServiceExtendInfo> GetServiceExtendInfo(int? extendId)
        {
            throw new NotImplementedException();
        }

        public Task<BaseValidate> SetServiceExtendInfo(ServiceExtendInfo info)
        {
            throw new NotImplementedException();
        }

        public Task<BaseValidate> DeleteServiceExtend(int? extendId)
        {
            throw new NotImplementedException();
        }
        public CommonViewInfo GetServiceLivingMeterFilter(string userId)
        {
            const string storedProcedure = "sp_res_service_living_meter_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { }).Result;
        }
        public async Task<CommonDataPage> GetServiceLivingMeterPage(ServiceLivingMeterRequestModel query)
        {
            const string storedProcedure = "sp_res_service_living_meter_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.livingType, query.projectCd, query.month, query.year });
        }

        public async Task<ServiceLivingMeterInfo> GetServiceLivingMeterInfo(int LivingId, int TrackingId)
        {
            const string storedProcedure = "sp_res_service_living_meter_field";
            return await GetFieldsAsync<ServiceLivingMeterInfo>(storedProcedure, new { LivingId, TrackingId });
        }

        public async Task<BaseValidate> SetServiceLivingMeterInfo(ServiceLivingMeterInfo info)
        {
            const string storedProcedure = "sp_service_living_meter_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.LivingId, info.TrackingId });
        }

        public async Task<BaseValidate> DeleteServiceLivingMeter(int trackingId)
        {
            const string storedProcedure = "sp_res_service_living_meter_del";
            return await DeleteAsync(storedProcedure, new { trackingId });
        }

        public async Task<BaseValidate> SetServiceLivingMeterCalculates(int trackingId, string projectCd, int LivingType, int PeriodMonth, int PeriodYear)
        {
            const string storedProcedure = "sp_res_service_living_meter_calculate";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { trackingId, projectCd, LivingType, PeriodMonth, PeriodYear });
        }

        public async Task<ServiceLivingMeterCalculatorInfo> GetServiceLivingMeterCalculatorInfo(int trackingId)
        {
            const string storedProcedure = "sp_res_service_living_meter_calculator_field2";
            return await GetFieldsAsync<ServiceLivingMeterCalculatorInfo>(storedProcedure, new { trackingId });
        }

        public async Task<BaseValidate> SetServiceLivingMeterCalculates2(ServiceLivingMeterCalculatorInfo info)
        {
            const string storedProcedure = "sp_res_service_living_meter_calculate";
            return await SetInfoAsync<BaseValidate>(storedProcedure, null, new
            {
                info.TrackingId,
                ProjectCd = info.GetValueByFieldName("ProjectCd"),
                LivingType = 1,
                PeriodMonth = int.Parse(info.GetValueByFieldName("PeriodMonth")),
                PeriodYear = int.Parse(info.GetValueByFieldName("PeriodYear"))
            });
        }
        public async Task<BaseValidate> SetServiceLivingMeterCalculates3(ServiceLivingMeterCalculatorInfo info)
        {
            const string storedProcedure = "sp_res_service_living_meter_calculate";
            return await SetInfoAsync<BaseValidate>(storedProcedure, null, new
            {
                info.TrackingId,
                ProjectCd = info.GetValueByFieldName("ProjectCd"),
                LivingType = 2,
                PeriodMonth = int.Parse(info.GetValueByFieldName("PeriodMonth")),
                PeriodYear = int.Parse(info.GetValueByFieldName("PeriodYear"))
            });
        }
        public async Task<BaseValidate> DelMultiServiceLivingMeter(DeleteMultiServiceLivingMeter deleteMultiService)
        {
            const string storedProcedure = "sp_res_service_living_meter_multi_del";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { TrackingIds = string.Join(",", deleteMultiService.Ids) });
            //    new {livingId =string.Join(",", deleteMultiService.Ids.ToArray()), tableName="MAS_Apartment_Service_Living",deleteMultiService.LivingTypeId });
        }

        public CommonViewInfo GetServiceExpectedFilter(string userId)
        {
            const string storedProcedure = "sp_res_service_expected_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId }).Result;
        }

        public async Task<CommonDataPage> GetServiceExpectedPage(ServiceExpectedRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_page";
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
            const string storedProcedure = "sp_res_service_expectable_calculate_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.Apartments });
        }

        public async Task<ServiceExpectedDetailsInfo> GetServiceExpectedDetailsInfo(int? receiveId)
        {
            const string storedProcedure = "sp_res_service_expected_details_field";
            return await GetFieldsAsync<ServiceExpectedDetailsInfo>(storedProcedure, new { receiveId });
        }

        public async Task<CommonDataPage> GetServiceExpectedFeePage(ServiceExpectedFeeRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_fee_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
        }

        public async Task<CommonDataPage> GetServiceExpectedVehiclePage(ServiceExpectedVehicleRequestModel query)
        {
            const string storedProcedure = "sp_res_service_expected_vehicle_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ReceiveId });
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

        public CommonViewInfo GetServiceReceivableFilter(string userId)
        {
            const string storedProcedure = "sp_res_service_receivable_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { }).Result;
        }

        public async Task<CommonDataPage> GetServiceReceivablePage(ServiceReceivableRequestModel query)
        {
            const string storedProcedure = "sp_res_service_receivable_page";
            return await GetDataListPageAsync(storedProcedure,
                query,
                new
                {
                    query.ProjectCd,
                    query.isDateFilter,
                    query.ToDate,
                    StatusPayed = query.StatusPayed,
                    query.IsBill,
                    query.IsPush
                });
        }

        public async Task<ServiceReceivableInfo> GetServiceReceivableInfo(int? receiveId)
        {
            const string storedProcedure = "sp_res_service_receivable_field";
            return await GetFieldsAsync<ServiceReceivableInfo>(storedProcedure, new { receiveId },
            async (data, reader) =>
            {
                if (data != null)
                {
                    var bankCode = data.GetValueByFieldName("bank_code");
                    var totalAmt = decimal.Parse(data.GetValueByFieldName("TotalAmt"));
                    var content = data.GetValueByFieldName("tran_content");

                    var paymentInfo = new appPaymentInfo
                    {
                        isKlb = true,
                        prefix = data.GetValueByFieldName("prefix"),
                        virtualPartNum = data.GetValueByFieldName("virtualPartNum"),
                        bank_code = bankCode,
                        trans_amt = totalAmt,
                        tran_content = content,
                        coop_acc_no_ic = data.GetValueByFieldName("coop_acc_no_ic")
                    };

                    //data.QrPayment = VietQrHelpers.GenerateVietQR(bankCode, paymentInfo.coop_acc_no, totalAmt, content);
                }
                return data;
            }
            );
        }
        public async Task<int> SetServiceReceivableBill(ServiceReceivableBill bill)
        {
            const string storedProcedure = "sp_res_service_receivable_bill_set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { bill.ReceiveId, bill.BillUrl, bill.BillViewUrl });
        }
        public async Task<ggDriverFileStream> ApartmentFeeStreamNew(ReportType reportType, long receiveId)
        {
            string? tempTemplatePath = null;
            try
            {
                var resGetTemplateUrl = await _projectConfRepo.GetProjectConfigValue("file_mau_thong_bao_phi", receiveId);
                var templateUrl = resGetTemplateUrl.valid ? resGetTemplateUrl.Data : string.Empty;

                // Tải file template từ URL về file tạm
                using (var http = new HttpClient())
                {
                    http.Timeout = TimeSpan.FromSeconds(60);
                    var bytes = await http.GetByteArrayAsync(templateUrl);

                    var ext = Path.GetExtension(new Uri(templateUrl).AbsolutePath);
                    if (string.IsNullOrWhiteSpace(ext)) ext = ".tmp";

                    tempTemplatePath = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}{ext}");
                    await File.WriteAllBytesAsync(tempTemplatePath, bytes);
                }

                const string storedProcedure = "sp_res_get_payment_report_byId_new_center";
                //string pathFile = _environment.ContentRootPath + "\\" + FolderResServiceReport.FOLDER_TEMPLATE + "\\" + ResServiceReport.BILL_TEMPLATE;
                //const string storedProcedure = "sp_res_get_payment_report_byId";
                Dictionary<string, object> p = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                using (var conn = new SqlConnection(CommonInfo.ConnectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.AddWithValue("@userId", (object)userId ?? DBNull.Value);
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@receiveId", SqlDbType.Int).Value = receiveId;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                }
                p.Add("StrDate", string.Concat(" Ngày ", DateTime.Now.Day.ToString(), " tháng ", DateTime.Now.Month.ToString(), " năm ", DateTime.Now.Year.ToString()));
                // Đếm số dòng bảng 6, nếu bảng không tồn tại hoặc không có dòng thì = 0
                int cntElec = 0;
                if (ds.Tables.Count > 6 && ds.Tables[6] != null && ds.Tables[6].Rows.Count > 0)
                {
                    cntElec = ds.Tables[6].Rows.Count;
                }
                p.Add("CntElec", cntElec);

                // Đếm số dòng bảng 9, nếu bảng không tồn tại hoặc không có dòng thì = 0
                int cntWater = 0;
                if (ds.Tables.Count > 9 && ds.Tables[9] != null && ds.Tables[9].Rows.Count > 0)
                {
                    cntWater = ds.Tables[9].Rows.Count;
                }
                p.Add("CntWater", cntWater);

                //// Tag thời gian theo config (điện)
                p.Add("ElecDt", BuildRangeText(ds, 5)); // bảng 5
                p.Add("ElecDt1", BuildRangeText(ds, 6)); // bảng 6

                //// Tag thời gian theo config (nước)
                p.Add("WaterDt", BuildRangeText(ds, 8)); // bảng 8
                p.Add("WaterDt1", BuildRangeText(ds, 9)); // bảng 9

                var paymentInfo = new appPaymentInfo
                {
                    Oid = (Guid)ds.Tables[0].Rows[0]["entryId"],
                    isKlb = true,
                    prefix = ds.Tables[0].Rows[0]["prefix"].ToString(),
                    virtualPartNum = ds.Tables[0].Rows[0]["virtualPartNum"].ToString(),
                    bank_code = ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
                    trans_amt = Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
                    tran_content = ds.Tables[0].Rows[0]["TransContent"].ToString(),
                    coop_acc_no_ic = ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
                };

                p.Add("QrPayment", QrCodeHelpers.GenerateAsBytes(VietQrHelpers.GenerateVietQR(ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
                                                               ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
                                                               //paymentInfo.coop_acc_no,
                                                               Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
                                                               ds.Tables[0].Rows[0]["TransContent"].ToString()
                                                               )));
                //p.Add("StrMonthLiving", "");
                //p.Add("StrMonthVehicle", "");
                //p.Add("StrMonthFee", "")
                await SetVirtualAccount(new appVirtualAccSet { Oid = paymentInfo.Oid, virtualAcc = paymentInfo.coop_acc_no });


                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count != 0)
                {
                    serviceStream.stream = flexcellUtils.CreateReport(tempTemplatePath, reportType, ds, p);
                    serviceStream.fileName = "[" + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["RoomCode"].ToString()) + "]-["
                                            + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["Remarks"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["Remarks"].ToString()) + "]";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.folderName = DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString();
                    serviceStream.dDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["tDate"]);
                }
                return serviceStream;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                return null;
                //throw ex;
            }

        }


        private string BuildRangeText(DataSet ds, int tableIndex)
        {
            if (ds == null || ds.Tables.Count <= tableIndex)
                return string.Empty;

            var table = ds.Tables[tableIndex];
            if (table == null || table.Rows.Count == 0)
                return string.Empty;

            var firstRow = table.Rows[0];
            var lastRow = table.Rows[table.Rows.Count - 1];

            DateTime? fromDate = firstRow["from_dt"] == DBNull.Value
                ? (DateTime?)null
                : Convert.ToDateTime(firstRow["from_dt"]);

            DateTime? toDate = lastRow["to_dt"] == DBNull.Value
                ? (DateTime?)null
                : Convert.ToDateTime(lastRow["to_dt"]);

            if (!fromDate.HasValue && !toDate.HasValue)
                return string.Empty;

            string fromText = fromDate.HasValue ? fromDate.Value.ToString("dd/MM/yyyy") : "...";
            string toText = toDate.HasValue ? toDate.Value.ToString("dd/MM/yyyy") : "...";

            return string.Format(
                "Chi tiết theo đơn giá từ ngày {0} đến ngày {1}\n" +
                "Details according to unit price from date {0} to date {1}",
                fromText, toText);
        }


        public async Task<ggDriverFileStream> ApartmentFeeStream(ReportType reportType, long receiveId)
        {
            string? tempTemplatePath = null;
            try
            {
                var resGetTemplateUrl = await _projectConfRepo.GetProjectConfigValue("file_mau_thong_bao_phi", receiveId);
                var templateUrl = resGetTemplateUrl.valid ? resGetTemplateUrl.Data : string.Empty;

                // Tải file template từ URL về file tạm
                using (var http = new HttpClient())
                {
                    http.Timeout = TimeSpan.FromSeconds(60);
                    var bytes = await http.GetByteArrayAsync(templateUrl);

                    var ext = Path.GetExtension(new Uri(templateUrl).AbsolutePath);
                    if (string.IsNullOrWhiteSpace(ext)) ext = ".tmp";

                    tempTemplatePath = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}{ext}");
                    await File.WriteAllBytesAsync(tempTemplatePath, bytes);
                }

                const string storedProcedure = "sp_res_get_payment_report_byId_new";
                Dictionary<string, object> p = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                using (var conn = new SqlConnection(CommonInfo.ConnectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.AddWithValue("@userId", (object)userId ?? DBNull.Value);
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@receiveId", SqlDbType.Int).Value = receiveId;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                }
                p.Add("StrDate", string.Concat(" Ngày ", DateTime.Now.Day.ToString(), " tháng ", DateTime.Now.Month.ToString(), " năm ", DateTime.Now.Year.ToString()));

                var paymentInfo = new appPaymentInfo
                {
                    Oid = (Guid)ds.Tables[0].Rows[0]["entryId"],
                    isKlb = true,
                    prefix = ds.Tables[0].Rows[0]["prefix"].ToString(),
                    virtualPartNum = ds.Tables[0].Rows[0]["virtualPartNum"].ToString(),
                    bank_code = ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
                    trans_amt = Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
                    tran_content = ds.Tables[0].Rows[0]["TransContent"].ToString(),
                    coop_acc_no_ic = ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
                };
                p.Add("QrPayment", QrCodeHelpers.GenerateAsBytes(VietQrHelpers.GenerateVietQR(ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
                                                               ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
                                                               Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
                                                               ds.Tables[0].Rows[0]["TransContent"].ToString()
                                                               )));
                //p.Add("QrPayment", QrCodeHelpers.GenerateAsBytes(VietQrHelpers.GenerateVietQR(ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
                //                                               //ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
                //                                               paymentInfo.coop_acc_no,
                //                                               Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
                //                                               ds.Tables[0].Rows[0]["TransContent"].ToString()
                //                                               )));
                //p.Add("StrMonthLiving", "");
                //p.Add("StrMonthVehicle", "");
                //p.Add("StrMonthFee", "")
                await SetVirtualAccount(new appVirtualAccSet { Oid = paymentInfo.Oid, virtualAcc = paymentInfo.coop_acc_no });

                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count != 0)
                {
                    serviceStream.stream = flexcellUtils.CreateReport(tempTemplatePath, reportType, ds, p);
                    serviceStream.fileName = "[" + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["RoomCode"].ToString()) + "]-["
                                            + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["Remarks"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["Remarks"].ToString()) + "]";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.folderName = DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString();
                    serviceStream.dDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["tDate"]);
                }
                return serviceStream;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                return null;
                //throw ex;
            }
        }
        //public async Task<ggDriverFileStream> ApartmentFeeStreamNew(ReportType reportType, long receiveId)
        //{
        //    string? tempTemplatePath = null;
        //    try
        //    {
        //        string templateUrl = null;

        //        // Gọi stored procedure mới để lấy link file_url
        //        const string spTemplateConfig = "sp_res_ProjectConfig_get_template_url";
        //        using (var conn = new SqlConnection(CommonInfo.ConnectionString))
        //        {
        //            await conn.OpenAsync();

        //            using (var cmd = new SqlCommand(spTemplateConfig, conn))
        //            {
        //                cmd.CommandType = CommandType.StoredProcedure;
        //                cmd.Parameters.Add("@receiveId", SqlDbType.BigInt).Value = receiveId;

        //                var result = await cmd.ExecuteScalarAsync();
        //                if (result != null && result != DBNull.Value)
        //                    templateUrl = result.ToString();
        //            }
        //        }

        //        // Tải file template từ URL về file tạm
        //        using (var http = new HttpClient())
        //        {
        //            http.Timeout = TimeSpan.FromSeconds(60);
        //            var bytes = await http.GetByteArrayAsync(templateUrl);

        //            var ext = Path.GetExtension(new Uri(templateUrl).AbsolutePath);
        //            if (string.IsNullOrWhiteSpace(ext)) ext = ".tmp";

        //            tempTemplatePath = Path.Combine(Path.GetTempPath(), $"{Guid.NewGuid()}{ext}");
        //            await File.WriteAllBytesAsync(tempTemplatePath, bytes);
        //        }

        //        const string storedProcedure = "sp_res_get_payment_report_byId_new";
        //        Dictionary<string, object> p = new Dictionary<string, object>();
        //        DataSet ds = new DataSet();
        //        using (var conn = new SqlConnection(CommonInfo.ConnectionString))
        //        {
        //            conn.Open();
        //            SqlCommand cmd = new SqlCommand(storedProcedure, conn);
        //            cmd.CommandType = CommandType.StoredProcedure;
        //            cmd.CommandTimeout = 200;
        //            //cmd.Parameters.AddWithValue("@userId", (object)userId ?? DBNull.Value);
        //            //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
        //            cmd.Parameters.Add("@receiveId", SqlDbType.Int).Value = receiveId;
        //            SqlDataAdapter da = new SqlDataAdapter(cmd);
        //            da.Fill(ds);
        //        }
        //        p.Add("StrDate", string.Concat(" Ngày ", DateTime.Now.Day.ToString(), " tháng ", DateTime.Now.Month.ToString(), " năm ", DateTime.Now.Year.ToString()));

        //        var paymentInfo = new appPaymentInfo
        //        {
        //            Oid = (Guid)ds.Tables[0].Rows[0]["entryId"],
        //            isKlb = true,
        //            prefix = ds.Tables[0].Rows[0]["prefix"].ToString(),
        //            virtualPartNum = ds.Tables[0].Rows[0]["virtualPartNum"].ToString(),
        //            bank_code = ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
        //            trans_amt = Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
        //            tran_content = ds.Tables[0].Rows[0]["TransContent"].ToString(),
        //            coop_acc_no_ic = ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
        //        };

        //        p.Add("QrPayment", QrCodeHelpers.GenerateAsBytes(VietQrHelpers.GenerateVietQR(ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
        //                                                       //ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
        //                                                       paymentInfo.coop_acc_no,
        //                                                       Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
        //                                                       ds.Tables[0].Rows[0]["TransContent"].ToString()
        //                                                       )));
        //        //p.Add("StrMonthLiving", "");
        //        //p.Add("StrMonthVehicle", "");
        //        //p.Add("StrMonthFee", "")
        //        await SetVirtualAccount(new appVirtualAccSet { Oid = paymentInfo.Oid, virtualAcc = paymentInfo.coop_acc_no });

        //        ggDriverFileStream serviceStream = new ggDriverFileStream();
        //        if (ds.Tables[0].Rows.Count != 0)
        //        {
        //            serviceStream.stream = flexcellUtils.CreateReport(tempTemplatePath, reportType, ds, p);
        //            serviceStream.fileName = "[" + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["RoomCode"].ToString()) + "]-["
        //                                    + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["Remarks"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["Remarks"].ToString()) + "]";

        //            serviceStream.mimeType = "application/unknown";
        //            serviceStream.folderName = DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString();
        //            serviceStream.dDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["tDate"]);
        //        }
        //        return serviceStream;
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError($"{ex}");
        //        return null;
        //        //throw ex;
        //    }
        //}


        //public async Task<ggDriverFileStream> ApartmentFeeStream(ReportType reportType, long receiveId)
        //{
        //    try
        //    {

        //        //return await ApartmentFeeStreamNewQRCode(reportType, receiveId);

        //        string pathFile = this._environment.ContentRootPath + "\\" + FolderResServiceReport.FOLDER_TEMPLATE + "\\" + ResServiceReport.BILL_TEMPLATE;
        //        const string storedProcedure = "sp_res_get_payment_report_byId";
        //        Dictionary<String, Object> p = new Dictionary<string, object>();
        //        DataSet ds = new DataSet();
        //        using (var conn = new SqlConnection(CommonInfo.ConnectionString))
        //        {
        //            conn.Open();
        //            SqlCommand cmd = new SqlCommand(storedProcedure, conn);
        //            cmd.CommandType = System.Data.CommandType.StoredProcedure;
        //            cmd.CommandTimeout = 200;
        //            //cmd.Parameters.AddWithValue("@userId", ((object)userId) ?? DBNull.Value);
        //            //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
        //            cmd.Parameters.Add("@receiveId", SqlDbType.Int).Value = receiveId;
        //            SqlDataAdapter da = new SqlDataAdapter(cmd);
        //            da.Fill(ds);
        //        }
        //        p.Add("StrDate", string.Concat(" Ngày ", DateTime.Now.Day.ToString(), " tháng ", DateTime.Now.Month.ToString(), " năm ", DateTime.Now.Year.ToString()));
        //        p.Add("QrPayment", QrCodeHelpers.GenerateAsBytes(VietQrHelpers.GenerateVietQR(ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
        //                                                       ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
        //                                                       Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
        //                                                       ds.Tables[0].Rows[0]["TransContent"].ToString()
        //                                                       )));
        //        //p.Add("StrMonthLiving", "");
        //        //p.Add("StrMonthVehicle", "");
        //        //p.Add("StrMonthFee", "");
        //        ggDriverFileStream serviceStream = new ggDriverFileStream();
        //        if (ds.Tables[0].Rows.Count != 0)
        //        {
        //            serviceStream.stream = flexcellUtils.CreateReport(pathFile, reportType, ds, p);
        //            serviceStream.fileName = ds.Tables[0].Rows[0]["RoomCode"].ToString() + "_"
        //                                    + ds.Tables[0].Rows[0]["PeriodMonth"].ToString() + "_"
        //                                    + ds.Tables[0].Rows[0]["PeriodYear"].ToString();

        //            serviceStream.mimeType = "application/unknown";
        //            serviceStream.folderName = (DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString());
        //            serviceStream.dDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["tDate"]);
        //        }
        //        return serviceStream;
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError($"{ex}");
        //        return null;
        //        //throw ex;
        //    }

        //}

        public async Task<BaseValidate> SetVirtualAccount(appVirtualAccSet virtualAcc)
        {
            const string storedProcedure = "sp_res_virtual_acc_set";
            return await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new { entryId = virtualAcc.Oid, virtualAccount = virtualAcc.virtualAcc });

        }
        public ggDriverFileStream GetServiceReceivableStream(long receiptId, ReportType reportType)
        {
            const string storedProcedure = "sp_res_service_bill_receipt_get";
            //DateTime feeDate = DateTime.ParseExact(toDate, "dd/MM/yyyy", CultureInfo.InvariantCulture);

            try
            {
                string pathFile = _environment.ContentRootPath + "\\" + FolderResServiceReport.FOLDER_TEMPLATE + "\\" + ResServiceReport.RECEIVE_MONEY_TEMPLATE;
                Dictionary<string, object> p = new Dictionary<string, object>();


                DataSet ds = new DataSet();
                using (SqlConnection connection = new SqlConnection(CommonInfo.ConnectionString))
                {
                    connection.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, connection);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@receiptId", SqlDbType.BigInt).Value = receiptId;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                }

                p.Add("StrDate", string.Concat(" Ngày ", DateTime.Now.Day.ToString(), " tháng ", DateTime.Now.Month.ToString(), " năm ", DateTime.Now.Year.ToString()));

                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count != 0)
                {
                    //string moneyColumn = "TotalAmt";
                    p.Add("MoneyAmt", decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).Equals(0) ? "0" : double.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).ToString("#,###", CultureInfo.GetCultureInfo("vi-VN")));
                    p.Add("MoneyByString", (decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).Equals(0) ? 0 : decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString())).ConvertMoneyToText());
                    Stream streamresult = flexcellUtils.CreateReport(pathFile, reportType, ds, p);
                    if (streamresult != null)
                    {
                        serviceStream.stream = streamresult;

                        serviceStream.fileName = DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? Guid.NewGuid().ToString() : string.Concat("[" + ds.Tables[0].Rows[0]["RoomCode"].ToString(), "#", DateTime.Now.Day.ToString(), DateTime.Now.Month.ToString(), DateTime.Now.Year.ToString() + "]");
                        serviceStream.mimeType = "application/unknown";
                        serviceStream.documentType = 2;
                        serviceStream.folderName = DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString();
                        serviceStream.dDate = DateTime.Now;
                    }

                }
                return serviceStream;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                return null;
            }
        }

        #endregion
        #region import-reg
        public async Task<DataSet> GetLivingImportTemp(int livingTypeId)
        {
            const string storedProcedure = "sp_res_service_living_imports_temp";
            return await GetDataSetAsync(storedProcedure, new Dictionary<string, Dictionary<SqlDbType, object>>
            {
                //{ "userId", new Dictionary<SqlDbType, object> { { SqlDbType.NVarChar, userId } } },
                { "livingTypeId", new Dictionary<SqlDbType, object> { { SqlDbType.Int, livingTypeId } } }
            });
        }
        public async Task<ImportListPage> SetLivingImport(LivingImportSet importSet, bool? check)
        {
            const string storedProcedure = "sp_res_service_living_imports";
            return await base.SetImport<LivingImportItem, LivingImportSet>(storedProcedure,
                importSet, "livingImport", "LivingImportType", new { check, importSet.livingTypeId });
            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@check", check);
            //    param.Add("@accept", importSet.accept);
            //    param.Add("@livingTypeId", importSet.livingTypeId);
            //    if (importSet.importFile != null)
            //    {
            //        param.AddDynamicParams(importSet.importFile);
            //    }
            //    param.AddTable("@livingImport", "LivingImportType", importSet.imports);
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();
            //    page.importFile = importSet.importFile;
            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    var list = (await result.ReadAsync<object>()).ToList();
            //    page.dataList = list;
            //    return page;
            //});
        }

        public async Task<ImportListPage> SetDebitAmtImport(DebitAmtImportSet importSet, bool check)
        {
            const string storedProcedure = "sp_res_service_debitAmt_imports";
            return await base.SetImport<DebitAmtImportItem, DebitAmtImportSet>(storedProcedure,
                importSet, "debitAmtImport", "DebitAmtImportType", new { check });
            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@userId", userId);
            //    param.Add("@check", check);
            //    param.Add("@accept", importSet.accept);
            //    if (importSet.importFile != null)
            //    {
            //        param.AddDynamicParams(importSet.importFile);
            //    }
            //    param.AddTable("@debitAmtImport", "DebitAmtImportType", importSet.imports);
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();
            //    page.importFile = importSet.importFile;
            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    var list = (await result.ReadAsync<object>()).ToList();
            //    page.dataList = list;
            //    return page;
            //});            
        }

        public async Task<ImportListPage> SetPaymentImport(PaymentImportSet importSet, bool check)
        {
            const string storedProcedure = "sp_res_service_payment_imports";
            return await base.SetImport<PaymentImportItem, PaymentImportSet>(storedProcedure,
                importSet, "paymentImport", "PaymentImportType", new { check });
        }

        public async Task<ImportListPage> SetTotalAmtImport(TotalAmtImportSet importSet, bool check)
        {
            const string storedProcedure = "sp_res_service_TotalAmt_imports";
            return await base.SetImport<TotalAmtImportItem, TotalAmtImportSet>(storedProcedure,
                importSet, "totalAmtImport", "TotalAmtImportType", new { check });
            //return await GetMultipleAsync<ImportListPage>(storedProcedure, param =>
            //{
            //    param.Add("@userId", userId);
            //    param.Add("@check", check);
            //    param.Add("@accept", importSet.accept);
            //    if (importSet.importFile != null)
            //    {
            //        param.AddDynamicParams(importSet.importFile);
            //    }
            //    param.AddTable("@totalAmtImport", "TotalAmtImportType", importSet.imports);
            //    return param;
            //},
            //async result =>
            //{
            //    var page = await result.ReadFirstAsync<ImportListPage>();
            //    page.importFile = importSet.importFile;
            //    page.gridflexs = (await result.ReadAsync<viewGridFlex>()).ToList();
            //    var list = (await result.ReadAsync<object>()).ToList();
            //    page.dataList = list;
            //    return page;
            //});

        }

        public async Task<CommonDataPage> GetServiceLivingPricePage(FilterProjectliving flt)
        {
            const string storedProcedure = "sp_service_living_price_setting_page";
            return await GetDataListPageAsync(storedProcedure, flt, new { flt.ProjectCd, flt.livingTypeid });
        }

        #endregion import-reg
    }
}

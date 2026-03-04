using Dapper;
using Microsoft.AspNetCore.Hosting;
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
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.DAL.Repositories.Notify;
using UNI.Resident.Model;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="ISHomeRepository" />
    public class ReportRepository : UniBaseRepository, IReportRepository
    {
        protected string _connectionString;
        protected ILogger<ReportRepository> _logger;
        private IHostingEnvironment _environment;
        private FlexcellUtils flexcellUtils;
        //private readonly IFirebaseRepository _notifyRepository;
        //private readonly INotifyRepository _appRepository; //IAppManagerRepository

        public ReportRepository(IConfiguration configuration,
            ILogger<ReportRepository> logger,
            //IFirebaseRepository notifyRepository,
            //INotifyRepository appRepository,
            IHostingEnvironment environment, IUniCommonBaseRepository common) : base(common)
        {
            _connectionString = configuration.GetConnectionString("SHomeConnection");
            //_notifyRepository = notifyRepository;
            //_appRepository = appRepository;
            _environment = environment;
            _logger = logger;
            flexcellUtils = new FlexcellUtils();
        }
        
        public async Task<ResponseList<List<HomFollowDebit>>> GetPaymentList(FilterBasePayments filter)
        {
            const string storedProcedure = "sp_Hom_Get_Payment_List_ByManager";
            var param = new DynamicParameters();
            param.Add("@ProjectCd", filter.projectCd);
            param.Add("@BuildingCd", filter.buildingCd);
            param.Add("@Floor", filter.Floor);
            param.Add("@filter", filter.RoomCd);
            param.Add("@month", filter.Month);
            param.Add("@year", filter.Year);
            param.Add("@Offset", filter.offSet);
            param.Add("@PageSize", filter.pageSize);
            param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
            param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
            var dList = await base.GetListAsync<HomFollowDebit>(storedProcedure, param);
            return new ResponseList<List<HomFollowDebit>>(dList, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
            //try
            //{
            //    using (SqlConnection connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();
            //        param.Add("@ProjectCd", filter.projectCd);
            //        param.Add("@BuildingCd", filter.buildingCd);
            //        param.Add("@Floor", filter.Floor);
            //        param.Add("@filter", filter.RoomCd);

            //        param.Add("@month", filter.Month);
            //        param.Add("@year", filter.Year);

            //        param.Add("@Offset", filter.offSet);
            //        param.Add("@PageSize", filter.pageSize);

            //        param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
            //        param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);

            //        var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
            //        var productList = result.Read<HomFollowDebit>().ToList();
            //        return new ResponseList<List<HomFollowDebit>>(productList, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
            //    }
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}
        }
        
        #region report-reg
      
        private Stream ReportStream(string storedProcedure, string folder,
            List<Tuple<string, SqlDbType, object>> storeParams,
            List<Tuple<string, string>> flexParams,
            string template, ReportType reportType)
        {
            try
            {
                Dictionary<String, Object> p = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure; 
                    cmd.CommandTimeout = 200;
                    storeParams.ForEach(delegate (Tuple<string, SqlDbType, object> a)
                        {
                            cmd.Parameters.Add(a.Item1, a.Item2).Value = a.Item3;
                        });
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                }
                flexParams.ForEach(delegate (Tuple<string, string> a)
                    {
                        p.Add(a.Item1, a.Item2);
                    });
                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(template, reportType, ds, p);
                if (outStream != null)
                    r.SaveStreamToLocal(outStream, folder + "ReportStream", reportType);
                return outStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
        private string ReportFolder
        {
            get
            {
                return _environment.ContentRootPath + "\\Reports\\";
            }
        }

        private Stream ReportFile(string storedProcedure, 
            string template, string type,
           string projectCd, string projectName, string fromDate, string toDate)
        {
            string folder = ReportFolder;
            string pathFile = folder + template;
            return ReportStream(storedProcedure, folder,
                storeParams: new List<Tuple<string, SqlDbType, object>> {
                    //new Tuple<string, SqlDbType, object>("@userId", SqlDbType.NVarChar, userId),
                    new Tuple<string, SqlDbType, object>("@projectCd", SqlDbType.NVarChar, projectCd),
                    new Tuple<string, SqlDbType, object>("@fromDate", SqlDbType.NVarChar, fromDate),
                new Tuple<string, SqlDbType, object>("@toDate", SqlDbType.NVarChar, toDate)}
            , flexParams: new List<Tuple<string, string>> {
                new Tuple<string, string>("StrDate", Now),
                new Tuple<string, string>("DateFrom", fromDate),
                new Tuple<string, string>("DateTo", toDate),
                new Tuple<string, string>("projectName", projectName),
            }, pathFile, FlexcellUtils.ReportByType(type));
        }
        public async Task<ResponseList<List<HomRequestService>>> ServiceRequestReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Service_Request";
            var dList = await base.GetListAsync<HomRequestService>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<HomRequestService>>(dList, dList.Count, dList.Count);

            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();

            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<HomRequestService>("sp_Hom_Service_Request", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<HomRequestService>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        public async Task<ResponseList<List<HomCardVehicleGet>>> VehicleAddedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Vehicles_Added";
            var dList = await base.GetListAsync<HomCardVehicleGet>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<HomCardVehicleGet>>(dList, dList.Count, dList.Count);
                //try
                //{
                //    using (var connection = new SqlConnection(_connectionString))
                //    {
                //        connection.Open();
                //        var param = new DynamicParameters();
                //        param.Add("@userId", userId);
                //        param.Add("@projectCd", projectCd);
                //        param.Add("@fromDate", fromDate);
                //        param.Add("@toDate", toDate);
                //        param.Add("@Offset", offset);
                //        param.Add("@PageSize", pageSize);
                //        param.Add("@Filter", filter);
                //        var result = await connection.QueryAsync<HomCardVehicleGet>("sp_Hom_Vehicles_Added", param, commandType: CommandType.StoredProcedure);
                //        var res = result.ToList();
                //        var l = res.Any() ? res[0].TotRows : 0;
                //        return new ResponseList<List<HomCardVehicleGet>>(res, l, l, res.Count);
                //    }
                //}
                //catch (Exception ex)
                //{
                //    _logger.LogError($"{ex}");
                //    throw ex;
                //}
        }
        public async Task<ResponseList<List<HomCardVehicleGet>>> VehicleLockedReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Vehicles_Locked";
            var dList = await base.GetListAsync<HomCardVehicleGet>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<HomCardVehicleGet>>(dList, dList.Count, dList.Count);
            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();
            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<HomCardVehicleGet>("sp_Hom_Vehicles_Locked", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<HomCardVehicleGet>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        public async Task<ResponseList<List<HomCardVehicleGet>>> VehicleRemovedReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Vehicles_Removed";
            var dList = await base.GetListAsync<HomCardVehicleGet>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<HomCardVehicleGet>>(dList, dList.Count, dList.Count);
            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();

            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<HomCardVehicleGet>("sp_Hom_Vehicles_Removed", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<HomCardVehicleGet>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        public async Task<ResponseList<List<ApartmentReceived>>> HouseRentedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Apartment_Rent";
            var dList = await base.GetListAsync<ApartmentReceived>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<ApartmentReceived>>(dList, dList.Count, dList.Count);
            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();

            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<ApartmentReceived>("sp_Hom_Apartment_Rent", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<ApartmentReceived>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        public async Task<ResponseList<List<ApartmentReceived>>> HouseReceivedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Apartment_Received";
            var dList = await base.GetListAsync<ApartmentReceived>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<ApartmentReceived>>(dList, dList.Count, dList.Count);
            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();

            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<ApartmentReceived>("sp_Hom_Apartment_Received", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<ApartmentReceived>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        public async Task<ResponseList<List<ApartmentMember>>> HouseCardsPendingReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Apartment_Cards_Pending";
            var dList = await base.GetListAsync<ApartmentMember>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<ApartmentMember>>(dList, dList.Count, dList.Count);
            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();

            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<ApartmentMember>("sp_Hom_Apartment_Cards_Pending", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<ApartmentMember>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        public async Task<ResponseList<List<ApartmentELinked>>> HouseELinkedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize)
        {
            const string storedProcedure = "sp_Hom_Apartment_ELinked";
            var dList = await base.GetListAsync<ApartmentELinked>(storedProcedure, param =>
            {
                param.Add("@projectCd", projectCd);
                param.Add("@fromDate", fromDate);
                param.Add("@toDate", toDate);
                param.Add("@Offset", offset);
                param.Add("@PageSize", pageSize);
                param.Add("@Filter", filter);
                return param;
            });
            return new ResponseList<List<ApartmentELinked>>(dList, dList.Count, dList.Count);
            //try
            //{
            //    using (var connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();
                    
            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        param.Add("@fromDate", fromDate);
            //        param.Add("@toDate", toDate);
            //        param.Add("@Offset", offset);
            //        param.Add("@PageSize", pageSize);
            //        param.Add("@Filter", filter);
            //        var result = await connection.QueryAsync<ApartmentELinked>("sp_Hom_Apartment_ELinked", param, commandType: CommandType.StoredProcedure);
            //        var res = result.ToList();
            //        var l = res.Any() ? res[0].TotRows : 0;
            //        return new ResponseList<List<ApartmentELinked>>(res, l, l, res.Count);
            //    }
            //}
            //catch (Exception ex)
            //{
            //    _logger.LogError($"{ex}");
            //    throw ex;
            //}
        }
        //streams for xlsx
        public Stream ServiceRequestFile(string type,
            string projectCd, string projectName, string fromDate, string toDate)
        {
            return ReportFile("sp_Hom_Service_Request", 
                HomeReportModel.ServiceRequestTemplate, type, projectCd, projectName, fromDate, toDate);
        }
        public Stream VehiclesLockedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate)
        {
            return ReportFile("sp_Hom_Vehicles_Locked",
                HomeReportModel.VehiclesLockedTemplate, type, projectCd, projectName, fromDate, toDate);
        }
        public Stream HouseRentedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate)
        {
            return ReportFile("sp_Hom_Apartment_Rent",
                HomeReportModel.HouseRentedTemplate, type, projectCd, projectName, fromDate, toDate);
        }
        private string Now
        {
            get
            {
                var now = DateTime.Now;
                return "Ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString();
            }
        }
        #endregion

        public async Task<HomDashboard> GetHomeDashboard(string projectCd)
        {
            const string storedProcedure = "sp_Hom_Get_Dashboard_ByManager";
            return await base.GetMultipleAsync<HomDashboard>(storedProcedure, param =>
            {
                //param.Add("@userId", userId);
                param.Add("@projectCd", projectCd);
                return param;
            }, async (result) =>
            {
                var homDash = new HomDashboard
                {
                    Apartment = await result.ReadFirstOrDefaultAsync<hdbApartment>(),
                    Resident = await result.ReadFirstOrDefaultAsync<hdbResident>(),
                    ResidentCard = await result.ReadFirstOrDefaultAsync<hdbResidentCard>(),
                    InternalCard = await result.ReadFirstOrDefaultAsync<hdbInternalCard>(),
                    Request = await result.ReadFirstOrDefaultAsync<hdbRequest>(),
                    ElectricMeter = await result.ReadFirstOrDefaultAsync<hdbElectricMeter>(),
                    WaterMeter = await result.ReadFirstOrDefaultAsync<hdbWaterMeter>()
                };
                return homDash;
            }
            );
            //try
            //{
            //    using (SqlConnection connection = new SqlConnection(_connectionString))
            //    {
            //        connection.Open();
            //        var param = new DynamicParameters();
            //        param.Add("@userId", userId);
            //        param.Add("@projectCd", projectCd);
            //        var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
            //        var homDash = new HomDashboard();
            //        homDash.Apartment = result.ReadFirstOrDefault<hdbApartment>();
            //        homDash.Resident = result.ReadFirstOrDefault<hdbResident>();
            //        homDash.ResidentCard = result.ReadFirstOrDefault<hdbResidentCard>();
            //        homDash.InternalCard = result.ReadFirstOrDefault<hdbInternalCard>();
            //        homDash.Request = result.ReadFirstOrDefault<hdbRequest>();
            //        homDash.ElectricMeter = result.ReadFirstOrDefault<hdbElectricMeter>();
            //        homDash.WaterMeter = result.ReadFirstOrDefault<hdbWaterMeter>();
            //        return homDash;
            //    }
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}
        }

        #region reports
        public ggDriverFileStream ApartmentFeeStream(ReportType reportType, long receiveId)
        {
            try
            {
                string pathFile = this._environment.ContentRootPath + "\\" + FolderServiceReport.FOLDER_TEMPLATE + "\\" + HomServiceReport.BILL_TEMPLATE;
                const string storedProcedure = "sp_Hom_Get_Payment_Report_ById";
                Dictionary<String, Object> p = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.AddWithValue("@userId", ((object)userId) ?? DBNull.Value);
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@receiveId", SqlDbType.Int).Value = receiveId;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                }
                p.Add("StrDate", string.Concat(" Ngày ", DateTime.Now.Day.ToString(), " tháng ", DateTime.Now.Month.ToString(), " năm ", DateTime.Now.Year.ToString()));
                p.Add("QrPayment",QrCodeHelpers.GenerateAsBytes(VietQrHelpers.GenerateVietQR(ds.Tables[0].Rows[0]["Bank_Code"].ToString(),
                                                               ds.Tables[0].Rows[0]["Bank_Acc_Num"].ToString(),
                                                               Convert.ToDecimal(ds.Tables[0].Rows[0]["TransactionAmt"]),
                                                               ds.Tables[0].Rows[0]["TransContent"].ToString()
                                                               )));
                //p.Add("StrMonthLiving", "");
                //p.Add("StrMonthVehicle", "");
                //p.Add("StrMonthFee", "");
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count != 0)
                {
                    serviceStream.stream = flexcellUtils.CreateReport(pathFile, reportType, ds, p);
                    serviceStream.fileName = "[" + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["RoomCode"].ToString()) + "]-["
                                            + (DBNull.Value.Equals(ds.Tables[0].Rows[0]["Remarks"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["Remarks"].ToString()) + "]";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.folderName = (DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString());
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
        public ggDriverFileStream GetServiceReceivableStream(long receiptId, ReportType reportType)
        {
            const string storedProcedure = "sp_Hom_Service_Bill_Receipt_Get";
            //DateTime feeDate = DateTime.ParseExact(toDate, "dd/MM/yyyy", CultureInfo.InvariantCulture);

            try
            {
                string pathFile = this._environment.ContentRootPath + "\\" + FolderServiceReport.FOLDER_TEMPLATE + "\\" + HomServiceReport.RECEIVE_MONEY_TEMPLATE;
                Dictionary<String, Object> p = new Dictionary<string, object>();


                DataSet ds = new DataSet();
                using (SqlConnection connection = new SqlConnection(_connectionString))
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
                    p.Add("MoneyAmt", Decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).Equals(0) ? "0" : double.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).ToString("#,###", CultureInfo.GetCultureInfo("vi-VN")));
                    p.Add("MoneyByString", MoneyHelper.ConvertMoneyToText(Decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).Equals(0) ? 0 : Decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString())));
                    Stream streamresult = flexcellUtils.CreateReport(pathFile, reportType, ds, p);
                    if (streamresult != null)
                    {
                        serviceStream.stream = streamresult;

                        serviceStream.fileName = DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? Guid.NewGuid().ToString() : string.Concat("[" + ds.Tables[0].Rows[0]["RoomCode"].ToString(), "#", DateTime.Now.Day.ToString(), DateTime.Now.Month.ToString(), DateTime.Now.Year.ToString() + "]");
                        serviceStream.mimeType = "application/unknown";
                        serviceStream.documentType = 2;
                        serviceStream.folderName = (DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString());
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
        public async Task<int> SetReceiptBill(HomServiceReceiptBill bill)
        {
            const string storedProcedure = "sp_Hom_Service_Receipt_Bill_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    //param.Add("@UserID", userId);
                    param.Add("@ReceiptId", bill.ReceiptId);
                    param.Add("@ReceiptBillUrl", bill.ReceiptBillUrl);
                    param.Add("@ReceiptBillViewUrl", bill.ReceiptBillViewUrl);
                    var result = await connection.ExecuteAsync(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        //public List<housReportConfig> GetReportList(int report_type)
        //{
        //    const string storedProcedure = "sp_Hom_Report_List";
        //    try
        //    {
        //        using (SqlConnection connection = new SqlConnection(_connectionString))
        //        {
        //            connection.Open();
        //            var param = new DynamicParameters();
        //            param.Add("@userId", userId);
        //            param.Add("@report_type", report_type);
        //            var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
        //            var data = result.Read<housReportConfig>().ToList();
        //            if (data != null && data.Count > 0)
        //            {
        //                var pars = result.Read<housReportParam>().ToList();
        //                foreach (var d in data)
        //                {
        //                    d.paramaters = pars.Where(m => m.report_id == d.report_id).ToList();
        //                }
        //            }
        //            return data;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        private ReportType ReportByType(String type)
        {
            switch (type)
            {
                case "pdf":
                    return ReportType.pdf;
                case "docx":
                    return ReportType.docx;
                default:
                    return ReportType.xlsx;
            }
        }


        public ggDriverFileStream GetHouseRentedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\Reports\\";
            string pathFile = folder + "house_rented_report.xlsx";
            return GetHouseRentedList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetHouseRentedList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);

                const string storedProcedure = "sp_Hom_Apartment_Rent_report";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    //cmd.Parameters.Add("@Offset", SqlDbType.NVarChar).Value = 0;
                    //cmd.Parameters.Add("@PageSize", SqlDbType.NVarChar).Value = 1000000;
                    //cmd.Parameters.Add("@Filter", SqlDbType.NVarChar).Value = "";
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    string_header = ds.Tables[1].Rows[0][1].ToString().ToUpper();
                }

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "sipt_report_exchange_info";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
                // r.SaveStreamToPdf(outStream, folder + "investment_order_" + string.Concat(now.Day.ToString(), now.Month.ToString(), now.Year.ToString()) + ".pdf");
                //return outStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }


        public ggDriverFileStream GetVehicleLockedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\reports\\";
            string pathFile = folder + "vehicle_service_locked_report.xlsx";
            return GetVehicleLockedList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetVehicleLockedList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);


                //var string_header = "BẢNG KÊ ĐỐI CHIẾU BÁN HÀNG DỰ ÁN ";
                //var datereport = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);

                const string storedProcedure = "sp_Hom_Vehicles_Locked_report";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    //var barcode = new Barcode();
                    //var string_projectname = ;
                    string_header = string_header + ds.Tables[1].Rows[0][1].ToString().ToUpper();

                }

                //string_header = string_header + " THÁNG " + datereport.Month.ToString() + "/" + datereport.Year.ToString();
                //param.Add("StrHeader", string_header);

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "sipt_report_exchange_info";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
                // r.SaveStreamToPdf(outStream, folder + "investment_order_" + string.Concat(now.Day.ToString(), now.Month.ToString(), now.Year.ToString()) + ".pdf");
                //return outStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }


        public ggDriverFileStream GetRequestCustomerList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\reports\\";
            string pathFile = folder + "request_report.xlsx";
            return GetRequestCustomerList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetRequestCustomerList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);


                //var string_header = "BẢNG KÊ ĐỐI CHIẾU BÁN HÀNG DỰ ÁN ";
                //var datereport = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);

                const string storedProcedure = "sp_Hom_Service_Request_report";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    //var barcode = new Barcode();
                    //var string_projectname = ;
                    string_header = string_header + ds.Tables[1].Rows[0][1].ToString().ToUpper();

                }

                //string_header = string_header + " THÁNG " + datereport.Month.ToString() + "/" + datereport.Year.ToString();
                //param.Add("StrHeader", string_header);

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "sipt_report_exchange_info";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
                // r.SaveStreamToPdf(outStream, folder + "investment_order_" + string.Concat(now.Day.ToString(), now.Month.ToString(), now.Year.ToString()) + ".pdf");
                //return outStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }


        public ggDriverFileStream GetApartmentInforList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\reports\\";
            string pathFile = folder + "apartment_infor_report.xlsx";
            return GetApartmentInforList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetApartmentInforList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);


                //var string_header = "BẢNG KÊ ĐỐI CHIẾU BÁN HÀNG DỰ ÁN ";
                //var datereport = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);

                const string storedProcedure = "sp_Hom_Report_Infor_Apartment";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    //var barcode = new Barcode();
                    //var string_projectname = ;
                    string_header = string_header + ds.Tables[1].Rows[0][1].ToString().ToUpper();

                }

                //string_header = string_header + " THÁNG " + datereport.Month.ToString() + "/" + datereport.Year.ToString();
                //param.Add("StrHeader", string_header);

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "sipt_report_exchange_info";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
                // r.SaveStreamToPdf(outStream, folder + "investment_order_" + string.Concat(now.Day.ToString(), now.Month.ToString(), now.Year.ToString()) + ".pdf");
                //return outStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }


        public ggDriverFileStream GetApartmentCardsPendingList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\reports\\";
            string pathFile = folder + "pending_card_apartment_report.xlsx";
            return GetApartmentCardsPendingList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetApartmentCardsPendingList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);


                const string storedProcedure = "sp_Hom_Report_Apartment_Cards_Pending";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    string_header = string_header + ds.Tables[1].Rows[0][1].ToString().ToUpper();

                }

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "Hom_Report_Apartment_Cards_Pending";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public ggDriverFileStream GetReportVehiclesAddedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\reports\\";
            string pathFile = folder + "hom_report_vehicles_added_report.xlsx";
            return GetReportVehiclesAddedList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetReportVehiclesAddedList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);


                const string storedProcedure = "sp_Hom_Report_Vehicles_Added";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    string_header = string_header + ds.Tables[1].Rows[0][1].ToString().ToUpper();

                }

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "Hom_Report_Vehicles_Added";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }


        public ggDriverFileStream GetReportVehiclesRemovedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            string folder = this._environment.ContentRootPath + "\\reports\\";
            string pathFile = folder + "hom_report_vehicles_removed_report.xlsx";
            return GetReportVehiclesRemovedList(folder, pathFile, ReportByType(type), projectcd, sei_dt_begin, sei_dt_end);
        }

        private ggDriverFileStream GetReportVehiclesRemovedList(string folder, string templatePath, ReportType reportType, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            try
            {
                var string_header = "";
                Dictionary<String, Object> param = new Dictionary<string, object>();
                DataSet ds = new DataSet();
                CultureInfo provider = CultureInfo.InvariantCulture;

                param.Add("DateFrom", sei_dt_begin);
                param.Add("DateTo", sei_dt_end);


                const string storedProcedure = "sp_Hom_Report_Vehicles_Removed";
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(storedProcedure, conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = projectcd;
                    cmd.Parameters.Add("@fromDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_begin, "dd/MM/yyyy", provider);
                    cmd.Parameters.Add("@toDate", SqlDbType.DateTime).Value = DateTime.ParseExact(sei_dt_end, "dd/MM/yyyy", provider);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                    string_header = string_header + ds.Tables[1].Rows[0][1].ToString().ToUpper();

                }

                param.Add("projectName", string_header);
                var now = DateTime.Now;
                param.Add("StrDate", "Hà Nội, ngày " + now.Day.ToString() + " tháng " + now.Month.ToString() + " năm " + now.Year.ToString());

                FlexcellUtils r = new FlexcellUtils();
                Stream outStream = r.CreateReport(templatePath, reportType, ds, param);
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count >= 0)
                {
                    serviceStream.stream = outStream;
                    serviceStream.fileName = "Hom_Report_Vehicles_Added";

                    serviceStream.mimeType = "application/unknown";
                    serviceStream.fileName = "";
                    serviceStream.dDate = DateTime.Now;
                }
                return serviceStream;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        #region reports-reg       
        public List<resReportConfig> GetReportList(string userId, string acceptLanguage, int report_type)
        {
            const string storedProcedure = "sp_res_report_list";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@acceptLanguage", acceptLanguage);
                    param.Add("@report_type", report_type);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.Read<resReportConfig>().ToList();
                    if (data != null && data.Count > 0)
                    {
                        var groups = result.Read<viewGroup>().ToList();
                        var fields = result.Read<viewField>().ToList();
                        foreach (var d in data)
                        {
                            d.group_fields = groups.Where(m => m.group_key == d.groupKey && m.group_table == d.tableKey).ToList();
                            if (d.group_fields != null && d.group_fields.Count > 0)
                            {
                                foreach (var gr in d.group_fields)
                                {
                                    gr.fields = fields.Where(f => f.table_name == d.tableKey && f.group_cd == gr.group_cd).ToList();
                                }
                            }
                        }
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion

        #region BuildingNameList       
        public List<resBuildingConfig> BuildingNameList(string userId, string acceptLanguage)
        {
            const string storedProcedure = "sp_res_report_building_name_list";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@acceptLanguage", acceptLanguage);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.Read<resBuildingConfig>().ToList();
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion

        #region RoomCodeList       
        public List<resRoomConfig> RoomCodeList(string userId, string acceptLanguage, string roomCode)
        {
            const string storedProcedure = "sp_res_report_room_code_list";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@acceptLanguage", acceptLanguage);
                    param.Add("@RoomCode", roomCode);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.Read<resRoomConfig>().ToList();
                    
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion

        #region ProjectBuildingRoomList       
        public async Task<CommonListPage> ProjectBuildingRoomList(ReportBuildingRoomFilter filter, string userId, string acceptLanguage)
        {
            const string storedProcedure = "sp_res_report_resident_list_building";
            return await base.GetPageAsync(storedProcedure, filter, param =>
            {
                param.Add("@ProjectCd", filter.ProjectCd);
                return param;
             });
        }
        #endregion



        #region tonghopcongno
        public DataSet ReportResidentReceivablePayableSummary(ReportReceivablePayable query, string acceptLanguage)
        {
            const string storedProcedure = "sp_res_report_resident_receivable_payable_summary";
            using (var connection = new SqlConnection(_connectionString))
            {
                var ds = new DataSet();
                connection.Open();
                var cmd = new SqlCommand(storedProcedure, connection) { CommandType = CommandType.StoredProcedure };
                cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = query.UserId;
                cmd.Parameters.Add("@acceptLanguage", SqlDbType.NVarChar).Value = acceptLanguage;
                cmd.Parameters.Add("@FromDate", SqlDbType.DateTime).Value = query.GetFromDate();
                cmd.Parameters.Add("@ToDate", SqlDbType.DateTime).Value = query.GetToDate();
                
                cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = query.ProjectCd;
                cmd.Parameters.Add("@BuildingCd", SqlDbType.NVarChar).Value = query.BuildingCd;
                cmd.Parameters.Add("@RoomCode", SqlDbType.NVarChar).Value = query.RoomCode;
                cmd.CommandTimeout = 1000;
                var da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                return ds;
            }
        }
        #endregion tonghopcongno

        #region ChiTietCongNo
        public DataSet ReportResidentReceivablePayableDetail(ReportReceivablePayable query, string acceptLanguage)
        {
            const string storedProcedure = "sp_res_report_resident_receivable_payable_detail";
            using (var connection = new SqlConnection(_connectionString))
            {
                var ds = new DataSet();
                connection.Open();
                var cmd = new SqlCommand(storedProcedure, connection) { CommandType = CommandType.StoredProcedure };
                cmd.Parameters.Add("@userId", SqlDbType.NVarChar).Value = query.UserId;
                cmd.Parameters.Add("@acceptLanguage", SqlDbType.NVarChar).Value = acceptLanguage;
                cmd.Parameters.Add("@FromDate", SqlDbType.DateTime).Value = query.GetFromDate();
                cmd.Parameters.Add("@ToDate", SqlDbType.DateTime).Value = query.GetToDate();

                cmd.Parameters.Add("@ProjectCd", SqlDbType.NVarChar).Value = query.ProjectCd;
                cmd.Parameters.Add("@BuildingCd", SqlDbType.NVarChar).Value = query.BuildingCd;
                cmd.Parameters.Add("@RoomCode", SqlDbType.NVarChar).Value = query.RoomCode;
                cmd.CommandTimeout = 1000;
                var da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                return ds;
            }
        }
        #endregion ChiTietCongNo




        #endregion reports

    }
}

using Google.Apis.Drive.v3;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using UNI.Utils;
using UNI.Utils.Exceptions;

namespace UNI.Resident.BLL.BusinessService
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="IReportService" />
    public class ReportService : IReportService
    {
        private readonly IReportRepository _homeRepository;
        private readonly IReportRepository _service;
        private readonly IApiStorageService _storageService;
        //private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;

        public ReportService(IReportRepository repository, IApiStorageService storageService)
        {
            if (repository != null)
                _homeRepository = repository;
            _storageService = storageService;
            //_service = repository; // Assuming _service should reference the same repository
        
        }
        public async Task<ResponseList<List<HomFollowDebit>>> GetPaymentList(FilterBasePayments filter)
        {
            return await _homeRepository.GetPaymentList(filter);
        }

        public async Task<HomDashboard> GetHomeDashboard(string projectCd)
        {
            return await _homeRepository.GetHomeDashboard(projectCd);
        }
        
        #region reports
        public Task<ResponseList<List<HomRequestService>>> ServiceRequestReport(string userId,
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize)
        {
            return _homeRepository.ServiceRequestReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<HomCardVehicleGet>>> VehicleAddedReport(string userId,
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize)
        {
            return _homeRepository.VehicleAddedReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<HomCardVehicleGet>>> VehicleLockedReport(string userId,
          string projectCd, string fromDate, string toDate,
          string filter, int offset, int pageSize)
        {
            return _homeRepository.VehicleLockedReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<HomCardVehicleGet>>> VehicleRemovedReport(string userId,
          string projectCd, string fromDate, string toDate,
          string filter, int offset, int pageSize)
        {
            return _homeRepository.VehicleRemovedReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<ApartmentReceived>>> HouseRentedReport(string userId,
          string projectCd, string fromDate, string toDate,
          string filter, int offset, int pageSize)
        {
            return _homeRepository.HouseRentedReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<ApartmentReceived>>> HouseReceivedReport(string userId,
          string projectCd, string fromDate, string toDate,
          string filter, int offset, int pageSize)
        {
            return _homeRepository.HouseReceivedReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<ApartmentELinked>>> HouseELinkedReport(string userId,
          string projectCd, string fromDate, string toDate,
          string filter, int offset, int pageSize)
        {
            return _homeRepository.HouseELinkedReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public Task<ResponseList<List<ApartmentMember>>> HouseCardsPendingReport(string userId,
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize)
        {
            return _homeRepository.HouseCardsPendingReport(projectCd,
                fromDate, toDate, filter, offset, pageSize);
        }
        public void SetServiceBillGoogleDriver(int receiveId)
        {
            var data = _homeRepository.ApartmentFeeStream(ReportType.pdf, receiveId);
            if (data == null)
                return;

            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            GoogleDriverHomeBillService _googleDriverService = new GoogleDriverHomeBillService();
            var result = _googleDriverService.UploadBilFile(driveService, new ggDriverFileStream
            {
                documentType = 1,
                fileName = data.fileName,
                stream = data.stream,
                mimeType = data.mimeType,
                folderName = data.folderName,
                dDate = data.dDate
            });
            //if (result != null)
            //    _homeRepository.SetPayBill(new HomServiceBill { BillUrl = result.WebViewLink, ReceiveId = receiveId, overwrite = true });
        }
        public Stream ServiceRequestFile(string type,
            string projectCd, string projectName, string fromDate, string toDate)
        {
            return _homeRepository.ServiceRequestFile(type, projectCd, projectName, fromDate, toDate);
        }
        public Stream VehiclesLockedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate)
        {
            return _homeRepository.VehiclesLockedFile(type, projectCd, projectName, fromDate, toDate);
        }
        public Stream HouseRentedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate)
        {
            return _homeRepository.HouseRentedFile(type, projectCd, projectName, fromDate, toDate);
        }
        

        public ggDriverFileDownload GetHouseRentedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetHouseRentedList(type, projectcd, sei_dt_begin, sei_dt_end);
            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            if (data.stream != null)
            {
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }

        public ggDriverFileDownload GetVehicleLockedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetVehicleLockedList(type, projectcd, sei_dt_begin, sei_dt_end);
            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            if (data.stream != null)
            {
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }


        public ggDriverFileDownload GetRequestCustomerList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetRequestCustomerList(type, projectcd, sei_dt_begin, sei_dt_end);
            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            if (data.stream != null)
            {
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }


        public ggDriverFileDownload GetApartmentInforList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetApartmentInforList(type, projectcd, sei_dt_begin, sei_dt_end);
            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            if (data.stream != null)
            {
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }

        public ggDriverFileDownload GetApartmentCardsPendingList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetApartmentCardsPendingList(type, projectcd, sei_dt_begin, sei_dt_end);
            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            if (data.stream != null)
            {
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }

        public ggDriverFileDownload GetReportVehiclesAddedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetReportVehiclesAddedList(type, projectcd, sei_dt_begin, sei_dt_end);
            GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            DriveService driveService = baseService.GetService3();
            if (data.stream != null)
            {
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }
        //<#Aggregate(Sum;Data0;<#Data0.xcount>)>

        public ggDriverFileDownload GetReportVehiclesRemovedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end)
        {
            var data = _homeRepository.GetReportVehiclesRemovedList(type, projectcd, sei_dt_begin, sei_dt_end);
            if (data?.stream != null)
            {
                var baseService = new GoogleDriverBaseService();
                var driveService = baseService.GetService3();
                var result = baseService.UploadBilFile(driveService, new ggDriverFileStream
                {
                    documentType = 1,
                    fileName = data.fileName,
                    stream = data.stream,
                    mimeType = data.mimeType
                });
                return result;
            }
            else
            {
                return null;
            }
        }

        #region reports-reg
        public List<resReportConfig> GetReportList(string userId, string acceptLanguage, int report_type)
        {
            return _homeRepository.GetReportList(userId, acceptLanguage, report_type);
        }
        #endregion

        #region BuildingNameList
        public List<resBuildingConfig> BuildingNameList(string userId, string acceptLanguage)
        {
            return _homeRepository.BuildingNameList(userId, acceptLanguage);
        }
        #endregion

        #region RoomCodeList
        public List<resRoomConfig> RoomCodeList(string userId, string acceptLanguage, string roomCode)
        {
            return _homeRepository.RoomCodeList(userId, acceptLanguage, roomCode);
        }
        #endregion

        #region ProjectBuildingRoomList
        public async Task<CommonListPage> ProjectBuildingRoomList(ReportBuildingRoomFilter filter, string userId, string acceptLanguage)
        {
            return await _homeRepository.ProjectBuildingRoomList(filter, userId, acceptLanguage);
        }
        #endregion



        #region tonghopcongno
        public async Task<BaseValidate<Stream>> ReportResidentReceivablePayableSummary(ReportReceivablePayable query, string acceptLanguage)
        {
            var data = _homeRepository.ReportResidentReceivablePayableSummary(query, acceptLanguage);
            var r = new FlexcellUtils();
            var template = await File.ReadAllBytesAsync($"Reports/01.TongHopCongNoDanCu.xlsx");
            var p = new Dictionary<string, object>();
            var FDay    = $"{query.GetFromDate():dd}";
            var FMonth  = $"{query.GetFromDate():MM}";
            var FYear   = $"{query.GetFromDate():yyyy}";
            var Day     = $"{query.GetToDate():dd}";
            var Month   = $"{query.GetToDate():MM}";
            var Year    = $"{query.GetToDate():yyyy}";

            p.Add("FDay", FDay);
            p.Add("FMonth", FMonth);
            p.Add("FYear", FYear);
            p.Add("Day", Day);
            p.Add("Month", Month);
            p.Add("Year", Year);

            var orgEx = data.Tables[0].Copy();
            if (orgEx.Rows.Count < 1)
            {
                throw new ReportEmptyException();
            }
            var report = r.CreateReport(template, ReportType.xlsx, data, p);
            return new BaseValidate<Stream>(report);
        }
        #endregion tonghopcongno

        #region ChiTietCongNo
        public async Task<BaseValidate<Stream>> ReportResidentReceivablePayableDetail(ReportReceivablePayable query, string acceptLanguage)
        {
            var data = _homeRepository.ReportResidentReceivablePayableDetail(query, acceptLanguage);
            var r = new FlexcellUtils();
            var template = await File.ReadAllBytesAsync($"Reports/02.ChiTietCongNoDanCu.xlsx");
            var p = new Dictionary<string, object>();
            var FDay = $"{query.GetFromDate():dd}";
            var FMonth = $"{query.GetFromDate():MM}";
            var FYear = $"{query.GetFromDate():yyyy}";
            var Day = $"{query.GetToDate():dd}";
            var Month = $"{query.GetToDate():MM}";
            var Year = $"{query.GetToDate():yyyy}";

            p.Add("FDay", FDay);
            p.Add("FMonth", FMonth);
            p.Add("FYear", FYear);
            p.Add("Day", Day);
            p.Add("Month", Month);
            p.Add("Year", Year);

            var orgEx = data.Tables[0].Copy();
            if (orgEx.Rows.Count < 1)
            {
                throw new ReportEmptyException();
            }
            var report = r.CreateReport(template, ReportType.xlsx, data, p);
            return new BaseValidate<Stream>(report);
        }
        #endregion ChiTietCongNo






        #endregion reports

    }
}

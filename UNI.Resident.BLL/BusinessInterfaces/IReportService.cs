using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IReportService
    {
        

        #region report-reg
        Task<HomDashboard> GetHomeDashboard(string projectCd);
        Task<ResponseList<List<HomFollowDebit>>> GetPaymentList(FilterBasePayments filter);

        #endregion report-reg

        #region reports
        Task<ResponseList<List<HomRequestService>>> ServiceRequestReport(string userId,
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<HomCardVehicleGet>>> VehicleAddedReport(string userId,
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<HomCardVehicleGet>>> VehicleLockedReport(string userId,
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<HomCardVehicleGet>>> VehicleRemovedReport(string userId,
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentReceived>>> HouseRentedReport(string userId,
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentReceived>>> HouseReceivedReport(string userId,
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentELinked>>> HouseELinkedReport(string userId,
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentMember>>> HouseCardsPendingReport(string userId,
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Stream ServiceRequestFile(string type,
            string projectCd, string projectName, string fromDate, string toDate);
        Stream VehiclesLockedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate);

        Stream HouseRentedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate);
        //Task<BaseValidate> AddAction(EAction action);
        //Task<ResponseList<List<EActionGet>>> ActionsReport(string userId,
        //    string projectCd, string fromDate, string toDate,
        //    string filter, int offset, int pageSize, int? status);


        //List<housReportConfig> GetReportList(int report_type);

        ggDriverFileDownload GetHouseRentedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileDownload GetVehicleLockedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileDownload GetRequestCustomerList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileDownload GetApartmentInforList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileDownload GetApartmentCardsPendingList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileDownload GetReportVehiclesRemovedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileDownload GetReportVehiclesAddedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        #region reports-reg
        List<resReportConfig> GetReportList(string userId, string acceptLanguage, int report_type);
        #endregion

        #region BuildingNameList
        List<resBuildingConfig> BuildingNameList(string userId, string acceptLanguage);
        #endregion

        #region RoomCodeList
        List<resRoomConfig> RoomCodeList(string userId, string acceptLanguage, string roomCode);
        #endregion

        #region ProjectBuildingRoomList
        Task<CommonListPage> ProjectBuildingRoomList(ReportBuildingRoomFilter filter, string userId, string acceptLanguage);
        #endregion



        #region tonghopcongno
        Task<BaseValidate<Stream>> ReportResidentReceivablePayableSummary(ReportReceivablePayable query, string acceptLanguage);
        #endregion tonghopcongno

        #region ChiTietCongNo
        Task<BaseValidate<Stream>> ReportResidentReceivablePayableDetail(ReportReceivablePayable query, string acceptLanguage);
        #endregion ChiTietCongNo







        #endregion reports

        #region reports-reg
        void SetServiceBillGoogleDriver(int receiveId);
        #endregion reports-reg
    }
}

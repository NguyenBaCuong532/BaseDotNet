using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces
{
    public interface IReportRepository
    {

        Task<ResponseList<List<HomFollowDebit>>> GetPaymentList(FilterBasePayments filter);

        //HomServiceReceivableSearch HomServiceReceivableSearch(string projectCd, int status, string fromDt, string toDt);
        

        #region report-reg
        Task<HomDashboard> GetHomeDashboard(string projectCd);
        //SreAdmDashboard GetAdmDashboard(int projectType);
        ggDriverFileStream ApartmentFeeStream(ReportType reportType, long receiveId);
        ggDriverFileStream GetServiceReceivableStream(long receiptId, ReportType reportType);

       

        #endregion report-reg

        #region reports
        //HttpResponseMessage ApartmentFeeReport(string type, int receiveId);
        //Stream ApartmentFeeDocument(string type, int receiveId);
        Task<ResponseList<List<HomRequestService>>> ServiceRequestReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<HomCardVehicleGet>>> VehicleAddedReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<HomCardVehicleGet>>> VehicleLockedReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<HomCardVehicleGet>>> VehicleRemovedReport(
            string projectCd, string fromDate, string toDate,
            string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentReceived>>> HouseRentedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentReceived>>> HouseReceivedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentELinked>>> HouseELinkedReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Task<ResponseList<List<ApartmentMember>>> HouseCardsPendingReport(
           string projectCd, string fromDate, string toDate,
           string filter, int offset, int pageSize);
        Stream ServiceRequestFile(string type,
            string projectCd, string projectName, string fromDate, string toDate);
        Stream VehiclesLockedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate);
        Stream HouseRentedFile(string type,
            string projectCd, string projectName, string fromDate, string toDate);


        //List<housReportConfig> GetReportList(int report_type);

        ggDriverFileStream GetHouseRentedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileStream GetVehicleLockedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileStream GetRequestCustomerList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileStream GetApartmentInforList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileStream GetApartmentCardsPendingList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileStream GetReportVehiclesAddedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

        ggDriverFileStream GetReportVehiclesRemovedList(string type, string projectcd, string sei_dt_begin, string sei_dt_end);

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
        DataSet ReportResidentReceivablePayableSummary(ReportReceivablePayable query, string acceptLanguage);
        #endregion tonghopcongno

        #region ChiTietCongNo
        DataSet ReportResidentReceivablePayableDetail(ReportReceivablePayable query, string acceptLanguage);
        #endregion ChiTietCongNo

  



        #endregion reports

    }
}

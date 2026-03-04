using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Apartment
{
    public interface IApartmentService
    {
        #region web-apartment
        
        Task<List<HomApartment>> GetApartmentSearch(string projectCd, string buildingCd, string filter, Guid? buildingOid = null);
        Task<CommonViewInfo> GetApartmentFilter(string userId);
        Task<CommonDataPage> GetApartmentPage(ApartmentRequestModel1 flt);
        Task<BaseValidate> DeleteApartmentAsync(int? apartmentId, Guid? Oid = null); // Hỗ trợ cả ApartmentId và Oid (backward compatible)
        Task<ApartmentInfo> GetApartmentInfo(int? apartmentId, Guid? Oid);// thông tin chung

        Task<BaseValidate> SetApartmentInfo(ApartmentInfo info);

        Task<ApartmentInfo> GetApartmentAddInfo(string ApartmentId);// form thêm mới căn hộ
        Task<BaseValidate> SetApartmentAddInfo(ApartmentInfo info);// thêm mới căn hộ
        Task<BaseValidate<Stream>> GetApartmentImportTemp(string userId);
        Task<ImportListPage> ImportApartmentAsync(ApartmentImportSet apartments);
        // Đồi căn hộ
        Task<CommonViewOidInfo> GetApartmentChangeRoomCodeInfoAsync(Guid? Oid, string roomCode, string buildingCd, Guid? buildingOid = null);
        Task<BaseValidate> SetApartmentChangeRoomCodeInfoAsync(CommonViewOidInfo info);        
        
        // Lấy ra lịch sử thông báo, mail, sms cho căn hộ
        Task<CommonDataPage> GetHistoryNotifyByApartmentPage(SentNotifyHistoryRequestModel query);
        Task<CommonDataPage> GetHistoryEmailByApartmentPage(SentEmailHistoryRequestModel query);
        Task<CommonDataPage> GetHistorySmsByApartmentPage(SentSmsHistoryRequestModel query);

        #endregion

        #region ApartmentProfile
        Task<BaseValidate> DeleteApartmentProfile(string id);
        Task<BaseValidate> SetApartmentProfileInfo(ApartmentProfileInfo info);
        Task<ApartmentProfileInfo> GetApartmentProfileInfo(string id, Guid? Oid, int? apartmentId);
        Task<CommonDataPage> GetApartmentProfilePage(ApartmentProfileRequestModel query);
        #endregion

        #region ViolationHistory
        Task<BaseValidate> DeleteViolationHistory(Guid id);
        Task<BaseValidate> SetViolationHistoryInfo(ApartmentViolationHistoryInfo info);
        Task<ApartmentViolationHistoryInfo> GetViolationHistoryInfo(Guid? id, Guid? Oid, int? apartmentId);
        Task<CommonDataPage> GetViolationHistoryPage(ApartmentViolationHistoryRequestModel query);
        Task<ApartmentStatus> GetApartmentStatus(Guid aprtId);
        #endregion
    }
}

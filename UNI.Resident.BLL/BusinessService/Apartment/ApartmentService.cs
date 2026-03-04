using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Apartment
{
    public class ApartmentService : IApartmentService
    {
        private readonly IApartmentRepository _apartmentRepository;
        public ApartmentService(
            IApartmentRepository apartmentRepository)
        {
            if (apartmentRepository != null)
                _apartmentRepository = apartmentRepository;
        }
        // căn hộ
        //public Task<List<CommonValue>> GetObjectList(string objKey)
        //{
        //    return _apartmentRepository.GetObjectListAsync(objKey);
        //}
        public Task<List<HomApartment>> GetApartmentSearch(string projectCd, string buildingCd, string filter, Guid? buildingOid = null)
        {
            return _apartmentRepository.GetApartmentSearchAsync(projectCd, buildingCd, filter, buildingOid);
        }
        public Task<CommonViewInfo> GetApartmentFilter(string userId)
        {
            return _apartmentRepository.GetApartmentFilter(userId);
        }
        public Task<CommonDataPage> GetApartmentPage(ApartmentRequestModel1 flt)
        {
            return _apartmentRepository.GetApartmentPage(flt);
        }

        public Task<BaseValidate> DeleteApartmentAsync(int? apartmentId, Guid? Oid = null)
        {
            return _apartmentRepository.DeleteApartmentAsync(apartmentId, Oid);
        }
        public Task<ApartmentInfo> GetApartmentInfo(int? apartmentId, Guid? Oid)
        {
            return _apartmentRepository.GetApartmentInfo(apartmentId, Oid);
        }

        public Task<BaseValidate> SetApartmentInfo(ApartmentInfo info)
        {
            return _apartmentRepository.SetApartmentInfo(info);
        }
        public Task<ApartmentInfo> GetApartmentAddInfo(string ApartmentId)
        {
            return _apartmentRepository.GetApartmentAddInfo(ApartmentId);
        }

        public Task<BaseValidate> SetApartmentAddInfo(ApartmentInfo info)
        {
            return _apartmentRepository.SetApartmentAddInfo(info);
        }
        public Task<CommonViewOidInfo> GetApartmentChangeRoomCodeInfoAsync(Guid? Oid, string roomCode, string buildingCd, Guid? buildingOid = null)
        {
            return _apartmentRepository.GetApartmentChangeRoomCodeInfoAsync(Oid, roomCode, buildingCd, buildingOid);
        }

        public Task<BaseValidate> SetApartmentChangeRoomCodeInfoAsync(CommonViewOidInfo info)
        {
            return _apartmentRepository.SetApartmentChangeRoomCodeInfoAsync(info);
        }
        public async Task<BaseValidate<Stream>> GetApartmentImportTemp(string userId)
        {
            try
            {
                var ds = await _apartmentRepository.GetApartmentImportTemp(userId);
                var r = new FlexcellUtils();
                var template = await File.ReadAllBytesAsync($"templates/apartment/import_apartment.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, ds, p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> ImportApartmentAsync(ApartmentImportSet apartments)
        {
            return _apartmentRepository.ImportApartmentAsync(apartments);
        }
        // thành viên trong căn hộ 


        
        // Lịch sử gửi thông báo app, tin nhắn, email
        public Task<CommonDataPage> GetHistoryNotifyByApartmentPage(SentNotifyHistoryRequestModel query)
        {
            return _apartmentRepository.GetHistoryNotifyByApartmentPage(query);
        }

        public Task<CommonDataPage> GetHistoryEmailByApartmentPage(SentEmailHistoryRequestModel query)
        {
            return _apartmentRepository.GetHistoryEmailByApartmentPage(query);
        }

        public Task<CommonDataPage> GetHistorySmsByApartmentPage(SentSmsHistoryRequestModel query)
        {
            return _apartmentRepository.GetHistorySmsByApartmentPage(query);
        }

        #region ApartmentProfile
        public Task<BaseValidate> DeleteApartmentProfile(string id)
        {
            return _apartmentRepository.DeleteApartmentProfile(id);
        }

        public Task<BaseValidate> SetApartmentProfileInfo(ApartmentProfileInfo info)
        {
            return _apartmentRepository.SetApartmentProfileInfo(info);
        }

        public Task<ApartmentProfileInfo> GetApartmentProfileInfo(string id, Guid? Oid, int? apartmentId)
        {
            return _apartmentRepository.GetApartmentProfileInfo(id, Oid, apartmentId);
        }

        public Task<CommonDataPage> GetApartmentProfilePage(ApartmentProfileRequestModel query)
        {
            return _apartmentRepository.GetApartmentProfilePage(query);
        }
        #endregion

        #region ViolationHistory
        public Task<BaseValidate> DeleteViolationHistory(Guid id)
        {
            return _apartmentRepository.DeleteViolationHistory(id);
        }

        public Task<BaseValidate> SetViolationHistoryInfo(ApartmentViolationHistoryInfo info)
        {
            return _apartmentRepository.SetViolationHistoryInfo(info);
        }

        public Task<ApartmentViolationHistoryInfo> GetViolationHistoryInfo(Guid? id, Guid? Oid, int? apartmentId)
        {
            return _apartmentRepository.GetViolationHistoryInfo(id, Oid, apartmentId);
        }

        public Task<CommonDataPage> GetViolationHistoryPage(ApartmentViolationHistoryRequestModel query)
        {
            return _apartmentRepository.GetViolationHistoryPage(query);
        }
        #endregion
        public Task<ApartmentStatus> GetApartmentStatus(Guid apartId)
        {
            return _apartmentRepository.GetApartmentStatus(apartId);
        }
    }
}

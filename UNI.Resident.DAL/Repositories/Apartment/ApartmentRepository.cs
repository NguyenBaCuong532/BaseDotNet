using DapperParameters;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Apartment
{
    public class ApartmentRepository : UniBaseRepository, IApartmentRepository
    {
        protected ILogger<ApartmentRepository> _logger;

        public ApartmentRepository(IConfiguration configuration,
            ILogger<ApartmentRepository> logger,
            IHostingEnvironment environment, IUniCommonBaseRepository common) : base(common)
        {
            _logger = logger;
        }
        #region web-apartment

        public async Task<List<HomApartment>> GetApartmentSearchAsync(string projectCd, string buildingCd, string filter, Guid? buildingOid = null)
        {
            const string storedProcedure = "sp_res_apartment_search";
            return await GetListAsync<HomApartment>(storedProcedure, new { projectCd, buildingCd, filter, buildingOid });
        }
        public async Task<CommonViewInfo> GetApartmentFilter(string userId)
        {
            const string storedProcedure = "sp_res_apartment_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId });
        }
        public async Task<CommonDataPage> GetApartmentPage(ApartmentRequestModel1 flt)
        {
            const string storedProcedure = "sp_res_apartment_page";
            return await GetDataListPageAsync(storedProcedure, flt, new { flt.ProjectCd, flt.Rent, flt.setupStatus, flt.buildingCd, Received = flt.Receive });
        }

        public async Task<BaseValidate> DeleteApartmentAsync(int? apartmentId, Guid? Oid = null)
        {
            const string storedProcedure = "sp_res_apartment_del";
            // Truyền cả 2 tham số xuống store, store sẽ tự xử lý ưu tiên
            return await DeleteAsync(storedProcedure, new { apartmentId, Oid });
        }

        public async Task<ApartmentInfo> GetApartmentAddInfo(string ApartmentId)
        {
            const string storedProcedure = "sp_res_apartment_add_field";
            return await GetFieldsAsync<ApartmentInfo>(storedProcedure, new { ApartmentId });
        }

        public async Task<BaseValidate> SetApartmentAddInfo(ApartmentInfo info)
        {
            const string storedProcedure = "sp_res_apartment_add_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.ApartmentId });
        }
        public async Task<ApartmentInfo> GetApartmentInfo(int? apartmentId, Guid? Oid)
        {
            var storedProcedure = Oid != null && Oid != Guid.Empty ? "sp_res_apartment_field_v3" : "sp_res_apartment_field";
            // Truyền cả 2 tham số xuống store
            return await GetFieldsAsync<ApartmentInfo>(storedProcedure, new { Oid, ApartmentId = apartmentId });
        }
        public async Task<BaseValidate> SetApartmentInfo(ApartmentInfo info)
        {
            const string storedProcedure = "sp_res_apartment_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new { oid = info.apartOid, ApartmentId = info.GetValueByFieldName("ApartmentId"), WaterwayArea = info.GetValueByFieldName("WaterwayArea") });
        }
        public async Task<DataSet> GetApartmentImportTemp(string userId)
        {
            const string storedProcedure = "sp_res_apartment_imports_temp";
            return await GetDataSetAsync(storedProcedure, new Dictionary<string, Dictionary<System.Data.SqlDbType, object>>
            {
                { "userId", new Dictionary<System.Data.SqlDbType, object> { { System.Data.SqlDbType.NVarChar, userId } } }
            });
        }

        public async Task<ImportListPage> ImportApartmentAsync(ApartmentImportSet importSet)
        {
            const string storedProcedure = "sp_res_apartment_import";
            return await base.SetImport<ApartmentImportItem, ApartmentImportSet>(storedProcedure,
                importSet, "apartments", TableTypes.APARTMENT_IMPORT_TYPE, new { });
        }
        public async Task<CommonViewOidInfo> GetApartmentChangeRoomCodeInfoAsync(Guid? Oid, string roomCode, string buildingCd, Guid? buildingOid = null)
        {
            const string storedProcedure = "sp_res_apartment_changeRoomCode_field";
            return await GetFieldsAsync<CommonViewOidInfo>(storedProcedure, new { Oid, roomCode, buildingCd, buildingOid });
        }

        public async Task<BaseValidate> SetApartmentChangeRoomCodeInfoAsync(CommonViewOidInfo info)
        {
            const string storedProcedure = "sp_res_apartment_changeRoomCode_set";
            Guid? oid = info.Oid;
            string roomCode = info.GetValueByFieldName("roomCode") as string;
            string buildingCd = info.GetValueByFieldName("buildingCd") as string;
            string roomCodeView = info.GetValueByFieldName("roomCodeView") as string;

            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new { Oid = oid, roomCode, buildingCd, roomCodeView });
        }

        public async Task<CommonDataPage> GetHistoryNotifyByApartmentPage(SentNotifyHistoryRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_notify_sent_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.RoomCode });
        }

        public async Task<CommonDataPage> GetHistoryEmailByApartmentPage(SentEmailHistoryRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_email_sent_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }

        public async Task<CommonDataPage> GetHistorySmsByApartmentPage(SentSmsHistoryRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_message_sent_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }

        #endregion

        #region ApartmentProfile
        public async Task<BaseValidate> DeleteApartmentProfile(string id)
        {
            const string storedProcedure = "sp_res_apartment_profile_del";
            return await DeleteAsync(storedProcedure, new { id });
        }

        public async Task<BaseValidate> SetApartmentProfileInfo(ApartmentProfileInfo info)
        {
            const string storedProcedure = "sp_res_apartment_profile_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new
            {
                Oid = info.apartOid,
                info.ApartmentId,
                info.Id,
                Name = info.GetValueByFieldName("Name"),
                AttackFile = info.GetValueByFieldName("AttackFile")
            });
        }

        public async Task<ApartmentProfileInfo> GetApartmentProfileInfo(string id, Guid? Oid, int? apartmentId)
        {
            const string storedProcedure = "sp_res_apartment_profile_field";
            return await GetFieldsAsync<ApartmentProfileInfo>(storedProcedure, new { id, Oid, ApartmentId = apartmentId });
        }

        public async Task<CommonDataPage> GetApartmentProfilePage(ApartmentProfileRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_profile_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.Oid, query.ApartmentId });
        }
        #endregion

        #region ViolationHistory
        public async Task<BaseValidate> DeleteViolationHistory(Guid id)
        {
            const string storedProcedure = "sp_res_apartment_violation_history_del";
            return await DeleteAsync(storedProcedure, new { id });
        }

        public async Task<BaseValidate> SetViolationHistoryInfo(ApartmentViolationHistoryInfo info)
        {
            const string storedProcedure = "sp_res_apartment_violation_history_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new
            {
                apartOid = info.apartOid,
                info.ApartmentId,
                Id = info.Id,
                ViolationDate = info.GetValueByFieldName("ViolationDate"),
                ViolationContent = info.GetValueByFieldName("ViolationContent"),
                AttackFile = info.GetValueByFieldName("AttackFile")
            });
        }

        public async Task<ApartmentViolationHistoryInfo> GetViolationHistoryInfo(Guid? id, Guid? Oid, int? apartmentId)
        {
            const string storedProcedure = "sp_res_apartment_violation_history_field";
            return await GetFieldsAsync<ApartmentViolationHistoryInfo>(storedProcedure, new { Id = id, apartOid = Oid, ApartmentId = apartmentId });
        }

        public async Task<CommonDataPage> GetViolationHistoryPage(ApartmentViolationHistoryRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_violation_history_page";
            return await GetDataListPageAsync(storedProcedure, query, new { apartOid = query.Oid, query.ApartmentId });
        }
        #endregion
        public async Task<ApartmentStatus> GetApartmentStatus(Guid apartId)
        {
            const string storedProcedure = "sp_res_apartment_status_get";
            return await base.GetFirstOrDefaultAsync<ApartmentStatus>(storedProcedure, new { apartId });
        }
    }
}

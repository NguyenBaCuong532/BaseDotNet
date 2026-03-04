using UNI.Model;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.DAL.Interfaces.Settings;

namespace UNI.Resident.BLL.BusinessService.Settings
{
    public class CommonService : ICommonService
    {
        private readonly ICommonRepository _repository;
        public CommonService(
            ICommonRepository apartmentRepository)
        {
            if (apartmentRepository != null)
                _repository = apartmentRepository;
        }
        // căn hộ
        public Task<List<CommonValue>> GetObjectList(string objKey, string all)
        {
            return _repository.GetObjectList(objKey, all);
        }
        public Task<List<CommonValue>> GetObjectClass(string objKey, string all)
        {
            return _repository.GetObjectClass(objKey, all);
        }
        public Task<List<CommonValue>> GetBuildingList(string projectCd, bool? isAll)
        {
            return _repository.GetBuildingList(projectCd, isAll);
        }
        public Task<List<CommonValue>> GetAreaList(string buildingCd, string projectCd, bool? isAll)
        {
            return _repository.GetAreaList(buildingCd, projectCd, isAll);
        }
        public Task<List<CommonValue>> GetFloorList(string buildingCd, System.Guid? buildingOid = null)
        {
            return _repository.GetFloorList(buildingCd, buildingOid);
        }

        public Task<List<CommonValue>> GetRoomList(string buildingCd, string floorNo, System.Guid? buildingOid = null, System.Guid? floorOid = null)
        {
            return _repository.GetRoomList(buildingCd, floorNo, buildingOid, floorOid);
        }
        public Task<List<CommonValue>> GetRoomList2(string projectCd, string buildingCd, string floorNo, int? apartmentId = null, string filter = null, System.Guid? buildingOid = null, System.Guid? floorOid = null, System.Guid? apartOid = null)
        {
            return _repository.GetRoomList2(projectCd, buildingCd, floorNo, apartmentId, filter, buildingOid, floorOid, apartOid);
        }

        public Task<List<CommonValue>> GetCardTypes()
        {
            return _repository.GetCardTypes();
        }
        public Task<List<CommonValue>> GetNotifyList(string externalKey)
        {
            return _repository.GetNotifyList(externalKey);
        }
        public Task<CommonViewInfo> GetCommonFilterInfo(string tableKey)
        {
            return _repository.GetCommonFilterInfo(tableKey);
        }
        public Task<CommonViewInfo> SetCommonFilterDraft(CommonViewInfo draft)
        {
            return _repository.SetCommonFilterDraft(draft);
        }
        public Task<List<CommonValue>> GetProjectList(bool? isAll)
        {
            return _repository.GetProjectList(isAll);
        }
        public Task<List<CommonValue>> GetCommonList(bool isfilter, string tableName, string columnName, string columnId, string columnParent, string valueParent, string colSortOrder)
        {
            return _repository.GetCommonList(isfilter, tableName, columnName, columnId, columnParent, valueParent, colSortOrder);
        }
        public Task<List<CommonValue>> GetServiceProviderList(int? contractTypeId)
        {
            return _repository.GetServiceProviderList(contractTypeId);
        }
        public Task<List<CommonValue>> GetFamilyMemberList(int? apartmentId)
        {
            return _repository.GetFamilyMemberList(apartmentId);
        }
        public Task<List<CommonValue>> GetProjectList1(bool? isAll)
        {
            return _repository.GetProjectList1(isAll);
        }
        public Task<List<CommonValue>> GetProjectListForOutSide(bool? isAll)
        {
            return _repository.GetProjectListForOutSide(isAll);
        }

        public Task<List<CommonValue>> GetElevatorFloorList(string projectCd, string areaCd, string buildZone)
        {
            return _repository.GetElevatorFloorList(projectCd, areaCd, buildZone);
        }

        public async Task<List<CommonValue>> GetBankCodes(string filter = null)
            => await _repository.GetBankCodes(filter);
        public async Task<List<CommonValue>> GetRoomList3(string projectCd, string oids, string filter)
            => await _repository.GetRoomList3(projectCd, oids, filter);
    }
}
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.Settings
{
    public interface ICommonService
    {
        #region web-apartment
        
        // Căn hộ
        Task<List<CommonValue>> GetObjectList(string objKey, string all);
        Task<List<CommonValue>> GetObjectClass(string objKey, string all);

        #endregion
        Task<List<CommonValue>> GetCardTypes();
        Task<List<CommonValue>> GetNotifyList(string externalKey);
        Task<CommonViewInfo> GetCommonFilterInfo(string filterName);
        Task<CommonViewInfo> SetCommonFilterDraft(CommonViewInfo draft);
        Task<List<CommonValue>> GetProjectList(bool? isAll);
        Task<List<CommonValue>> GetCommonList(bool isfilter, string tableName, string columnName, string columnId, string columnParent, string valueParent, string colSortOrder);
        Task<List<CommonValue>> GetServiceProviderList(int? contractTypeId);
        Task<List<CommonValue>> GetFamilyMemberList(int? apartmentId);
        Task<List<CommonValue>> GetProjectList1(bool? isAll);
        Task<List<CommonValue>> GetProjectListForOutSide(bool? isAll);

        //Danh mục list
        Task<List<CommonValue>> GetBuildingList(string projectCd, bool? isAll);
        Task<List<CommonValue>> GetFloorList(string buildingCd, System.Guid? buildingOid = null);
        Task<List<CommonValue>> GetRoomList(string buildingCd, string floorNo, System.Guid? buildingOid = null, System.Guid? floorOid = null);
        Task<List<CommonValue>> GetRoomList2(string projectCd, string buildingCd, string floorNo, int? apartmentId = null, string filter = null, System.Guid? buildingOid = null, System.Guid? floorOid = null, System.Guid? apartOid = null);
        Task<List<CommonValue>> GetAreaList(string buildingCd,string projectCd, bool? isAll);
        Task<List<CommonValue>> GetElevatorFloorList(string projectCd, string areaCd, string buildZone);

        Task<List<CommonValue>> GetBankCodes(string filter = null);
        Task<List<CommonValue>> GetRoomList3(string projectCd, string oids, string filter);
    }
}

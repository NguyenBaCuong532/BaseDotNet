using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;

namespace UNI.Resident.DAL.Interfaces.Elevator
{
    public interface IElevatorBuildingRepository
    {
        #region elevator-reg
        
        Task<CommonDataPage> GetBuildAreaPage(FilterInputBuilding filter);
        Task<BuildAreaInfo> GetBuildAreaInfo(string projectCd, string buildingCd, string id);
        Task<BaseValidate> SetBuildAreaInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuildArea(string buildingCd, string id);
        Task<List<CommonValue>> GetBuildAreaList(string projectCd);

        Task<List<CommonValue>> GetBuildZoneList(string projectCd, string areaCd);
        Task<CommonDataPage> GetBuildZonePage(FilterElevatorZone flt);
        Task<BaseValidate> SetBuildZoneInfo(CommonViewInfo info);
        Task<CommonViewInfo> GetBuildZoneInfo(string buildCd, string buildZone, string projectCd);
        Task<BaseValidate> DelBuildZone(string buildCd, string buildZone);

        Task<CommonDataPage> GetBuildFloorPage(FilterElevatorFloor filter);
        Task<CommonViewInfo> GetBuildFloorInfo(string id, string id1);
        Task<BaseValidate> SetBuildFloorInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuildFloor(string id, string id1);
        Task<List<CommonValue>> GetBuildFloorList(string projectCd, string buildCd, string buildZone, System.Guid? buildingOid = null);
        
        
        #endregion elevator-reg
    }
}

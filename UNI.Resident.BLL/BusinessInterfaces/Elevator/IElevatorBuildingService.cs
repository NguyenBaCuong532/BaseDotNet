using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IElevatorBuildingService
    {

        #region elevator-reg
        
        Task<List<CommonValue>> GetBuildAreaList(string projectCd);
        Task<CommonDataPage> GetBuildAreaPage(FilterInputBuilding filter);
        Task<BuildAreaInfo> GetBuildAreaInfo(string projectCd, string buildingCd, string id);
        Task<BaseValidate> SetBuildAreaInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuildArea(string buildingCd, string id);

        Task<CommonDataPage> GetBuildZonePage(FilterElevatorZone flt);
        Task<CommonViewInfo> GetBuildZoneInfo(string buildCd, string buildZone, string projectCd);
        Task<BaseValidate> SetBuildZoneInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuildZone(string buildCd, string buildZone);
        Task<List<CommonValue>> GetBuildZoneList(string projectCd, string areaCd);

        Task<CommonDataPage> GetBuildFloorPage(FilterElevatorFloor filter);
        Task<CommonViewInfo> GetBuildFloorInfo(string id, string id1);
        Task<BaseValidate> SetBuildFloorInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuildFloor(string id, string id1);
        Task<List<CommonValue>> GetBuildFloorList(string projectCd, string buildCd, string buildZone, System.Guid? buildingOid = null);

        
        #endregion elevator-reg

    }
}

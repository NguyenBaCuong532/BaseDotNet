using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Apartment
{
    public interface IProjectRepository
    {
        #region web-apartment
       
        Task<ProjectInfo> GetProjectInfo(string projectCd, Guid? Oid = null); // Hỗ trợ cả projectCd và Oid (backward compatible)
        Task<BaseValidate> SetProjectInfo(ProjectInfo info);
        // tòa nhà
        Task<CommonDataPage> GetBuildingPage(FilterBaseProject query);
        Task<CommonViewInfo> GetBuildingInfo(string id, string projectCd, Guid? Oid = null); // Hỗ trợ cả id/buildingCd và Oid (backward compatible)
        Task<BaseValidate> SetBuildingInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuilding(string id, Guid? Oid = null); // Hỗ trợ cả id/buildingCd và Oid (backward compatible)
        #endregion
    }
}

using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Apartment
{
    public interface IProjectService
    {
        #region web-apartment
        //// Sửa thông tin dự án
        Task<ProjectInfo> GetProjectInfo(string projectCd, Guid? Oid = null); // Hỗ trợ cả projectCd và Oid (backward compatible)
        Task<BaseValidate> SetProjectInfo(ProjectInfo info);
        //// Thành viên trong căn hộ
        Task<CommonDataPage> GetBuildingPage(FilterBaseProject query);
        Task<CommonViewInfo> GetBuildingInfo(string id, string projectCd, Guid? Oid = null); // Hỗ trợ cả id/buildingCd và Oid (backward compatible)
        Task<BaseValidate> SetBuildingInfo(CommonViewInfo info);
        Task<BaseValidate> DelBuilding(string id, Guid? Oid = null); // Hỗ trợ cả id/buildingCd và Oid (backward compatible)
        
        #endregion
    }
}

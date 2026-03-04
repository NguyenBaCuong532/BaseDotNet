using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Apartment
{
    public class ProjectService : IProjectService
    {
        private readonly IProjectRepository _apartmentRepository;
        public ProjectService(
            IProjectRepository apartmentRepository)
        {
            if (apartmentRepository != null)
                _apartmentRepository = apartmentRepository;
        }

        public Task<ProjectInfo> GetProjectInfo(string projectCd, Guid? Oid = null)
        {
            return _apartmentRepository.GetProjectInfo(projectCd, Oid);
        }

        public Task<BaseValidate> SetProjectInfo(ProjectInfo info)
        {
            return _apartmentRepository.SetProjectInfo(info);
        }

        // thành viên trong căn hộ 

        public async Task<CommonDataPage> GetBuildingPage(FilterBaseProject query)
        {
            return await _apartmentRepository.GetBuildingPage(query);
        }
        public Task<CommonViewInfo> GetBuildingInfo(string id, string projectCd, Guid? Oid = null)
        {
            return _apartmentRepository.GetBuildingInfo(id, projectCd, Oid);
        }
        public Task<BaseValidate> SetBuildingInfo(CommonViewInfo info)
        {
            return _apartmentRepository.SetBuildingInfo(info);
        }
        public async Task<BaseValidate> DelBuilding(string id, Guid? Oid = null)
        {
            return await _apartmentRepository.DelBuilding(id, Oid);
        }
        
    }
}

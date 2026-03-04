using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Apartment
{
    public class ProjectRepository : UniBaseRepository, IProjectRepository
    {
        protected ILogger<ProjectRepository> _logger;

        public ProjectRepository(IConfiguration configuration,
            ILogger<ProjectRepository> logger,
            IHostingEnvironment environment, IUniCommonBaseRepository common) : base(common)
        {
            _logger = logger;
        }
        #region web-project

        public async Task<ProjectInfo> GetProjectInfo(string projectCd, Guid? Oid = null)
        {
            const string storedProcedure = "sp_res_project_field";
            // Truyền cả 2 tham số xuống store, store sẽ tự xử lý ưu tiên
            return await GetFieldsAsync<ProjectInfo>(storedProcedure, new { projectCd, Oid });
        }

        public async Task<BaseValidate> SetProjectInfo(ProjectInfo project)
        {
            const string storedProcedure = "sp_res_project_set";
            // Truyền cả projectCd và Oid (nếu có) xuống store, store sẽ tự xử lý ưu tiên
            return await SetInfoAsync<BaseValidate>(storedProcedure, project, new { project.projectCd, project.Oid });
        }

        public async Task<CommonDataPage> GetBuildingPage(FilterBaseProject query)
        {
            const string storedProcedure = "sp_res_building_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd });
        }

        public async Task<CommonViewInfo> GetBuildingInfo(string id, string projectCd, Guid? Oid = null)
        {
            const string storedProcedure = "sp_res_building_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id = id, projectCd, Oid });
        }
        public async Task<BaseValidate> SetBuildingInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_building_set";
            // Truyền cả id, buildingCd (cd), và Oid (gd) xuống store, store sẽ tự xử lý ưu tiên
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.id, buildingCd = info.cd, Oid = info.gd });
        }
        public async Task<BaseValidate> DelBuilding(string id, Guid? Oid = null)
        {
            const string storedProcedure = "sp_res_building_del";
            // Truyền cả id và Oid xuống store, store sẽ tự xử lý ưu tiên
            return await DeleteAsync(storedProcedure, new { id, Oid });
        }
        
        #endregion
    }
}

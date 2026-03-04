using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Aparment
{

    /// <summary>
    /// Apartment Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/project/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ProjectController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IProjectService _projectService;

        /// <summary>
        /// Initializes a new instance of the <see cref="ApartmentController"/> class.
        /// </summary>
        /// <param name="apartmentService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public ProjectController(IProjectService apartmentService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _projectService = apartmentService;
        }

        #region Project
        
        /// <summary>
        /// GetProjectInfo - Xem chi tiết dự án
        /// </summary>
        /// <param name="projectCd">Mã dự án (string) - backward compatible</param>
        /// <param name="Oid">Mã định danh dự án (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<ProjectInfo>> GetProjectInfo([FromQuery] string projectCd, [FromQuery] Guid? Oid)
        {
            try
            {
                var rs = await _projectService.GetProjectInfo(projectCd, Oid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<ProjectInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetProjectInfoAsync - Lưu thông tin dự án
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetProjectInfoAsync([FromBody] ProjectInfo info)
        {
            try
            {
                var rs = await _projectService.SetProjectInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        #endregion

        #region building
        /// <summary>
        /// GetBuildingPage - Danh sách tòa nhà
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetBuildingPage([FromQuery] string projectCd, [FromQuery] int? offSet, [FromQuery] int? pageSize, [FromQuery] string filter)
        {
            var flt = new FilterBaseProject(ClientId, UserId, offSet, pageSize, projectCd, filter);
            var rs = await _projectService.GetBuildingPage(flt);
            return GetResponse(ApiResult.Success, rs);
        }
        /// <summary>
        /// GetBuildingInfo - Xem chi tiết tòa nhà
        /// </summary>
        /// <param name="id">Mã tòa nhà (string - có thể là Id, buildingCd) - backward compatible</param>
        /// <param name="Oid">Mã định danh tòa nhà (UUID) - ưu tiên nếu có</param>
        /// <param name="projectCd">Mã dự án (string)</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetBuildingInfo([FromQuery] string id, [FromQuery] Guid? Oid, [FromQuery] string projectCd)
        {
            var rs = await _projectService.GetBuildingInfo(id, projectCd, Oid);
            return GetResponse(ApiResult.Success, rs);
        }
        /// <summary>
        ///     SetBuildingInfo - Lưu thông tin tòa nhà
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetBuildingInfo([FromBody] CommonViewInfo info)
        {
            var rs = await _projectService.SetBuildingInfo(info);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return rp;
        }
        /// <summary>
        /// DelBuilding - Xóa tòa nhà
        /// </summary>
        /// <param name="id">Mã tòa nhà (string - có thể là Id, buildingCd) - backward compatible</param>
        /// <param name="Oid">Mã định danh tòa nhà (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelBuilding([FromQuery] string id, [FromQuery] Guid? Oid)
        {
            var rs = await _projectService.DelBuilding(id, Oid);
            var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
            return rp;
        }

        #endregion


    }
}

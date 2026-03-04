using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.BLL.BusinessInterfaces.Employee;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Employee;

namespace UNI.Resident.API.Controllers.Version2.Employee
{
    /// <summary>
    /// EmployeeController - Quản lý nhân viên
    /// </summary>
    /// Author: System
    /// CreatedDate: 2024
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/employee/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class EmployeeController : UniController
    {
        /// <summary>
        /// Employee Service
        /// </summary>
        private readonly IEmployeeService _employeeService;

        /// <summary>
        /// Initializes a new instance of the <see cref="EmployeeController"/> class.
        /// </summary>
        /// <param name="employeeService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="storageService"></param>
        public EmployeeController(
            IEmployeeService employeeService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IApiStorageService storageService) : base(appSettings, logger, storageService)
        {
            _employeeService = employeeService ?? throw new ArgumentNullException(nameof(employeeService));
        }

        #region Employee Management

        /// <summary>
        /// GetInfoPage - Lấy danh sách nhân viên phân trang
        /// </summary>
        /// <param name="flt">Filter input</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetInfoPage(
            [FromQuery] FilterInpEmployee flt)
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _employeeService.GetEmployeePage(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetInfo - Lấy thông tin chi tiết nhân viên
        /// </summary>
        /// <param name="empId">Employee ID</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<EmployeeInfo>> GetInfo([FromQuery] Guid? empId)
        {
            var result = await _employeeService.GetEmployeeInfo(empId);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// DeleteEmployee - Xóa nhân viên
        /// </summary>
        /// <param name="empId">Employee ID</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<BaseValidate>> DeleteEmployee([FromQuery] Guid? empId)
        {
            try
            {
                var result = await _employeeService.DeleteEmployeeAsync(empId);
                var sCode = result != null && result.valid ? ApiResult.Success : ApiResult.Error;
                return GetResponse(sCode, result);
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<BaseValidate>(ApiResult.Error, e.Message);
                return rp;
            }
        }

        #endregion
    }
}


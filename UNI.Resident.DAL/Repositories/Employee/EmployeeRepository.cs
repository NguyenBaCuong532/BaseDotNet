using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Employee;
using UNI.Resident.Model.Employee;

namespace UNI.Resident.DAL.Repositories.Employee
{
    /// <summary>
    /// EmployeeRepository - Repository quản lý nhân viên
    /// </summary>
    public class EmployeeRepository : UniBaseRepository, IEmployeeRepository
    {
        public EmployeeRepository(IUniCommonBaseRepository commonInfo) : base(commonInfo)
        {
        }

        #region Employee Management

        public Task<CommonDataPage> GetEmployeePage(FilterInpEmployee flt)
        {
            const string storedProcedure = "sp_res_employee_page";
            return GetDataListPageAsync(storedProcedure, flt, new
            {
                flt.departmentName,
                flt.orgName,
                flt.companyName,
                flt.emp_st
            });
        }

        public async Task<EmployeeInfo> GetEmployeeInfo(Guid? empId)
        {
            const string storedProcedure = "sp_res_employee_field";
            return await GetFieldsAsync<EmployeeInfo>(storedProcedure, new { empId });
        }

        public async Task<BaseValidate> DeleteEmployeeAsync(Guid? empId)
        {
            const string storedProcedure = "sp_res_employee_del";
            return await DeleteAsync(storedProcedure, new { empId });
        }

        #endregion
    }
}


using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Employee;
using UNI.Resident.DAL.Interfaces.Employee;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Employee;

namespace UNI.Resident.BLL.BusinessService.Employee
{
    /// <summary>
    /// EmployeeService - Service quản lý nhân viên
    /// </summary>
    public class EmployeeService : IEmployeeService
    {
        private readonly IEmployeeRepository _employeeRepository;

        public EmployeeService(IEmployeeRepository employeeRepository)
        {
            _employeeRepository = employeeRepository ?? throw new ArgumentNullException(nameof(employeeRepository));
        }

        #region Employee Management

        public Task<CommonDataPage> GetEmployeePage(FilterInpEmployee flt)
        {
            return _employeeRepository.GetEmployeePage(flt);
        }

        public Task<EmployeeInfo> GetEmployeeInfo(Guid? empId)
        {
            return _employeeRepository.GetEmployeeInfo(empId);
        }

        public Task<BaseValidate> DeleteEmployeeAsync(Guid? empId)
        {
            return _employeeRepository.DeleteEmployeeAsync(empId);
        }

        #endregion
    }
}


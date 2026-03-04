using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Employee;

namespace UNI.Resident.DAL.Interfaces.Employee
{
    /// <summary>
    /// IEmployeeRepository - Interface cho repository quản lý nhân viên
    /// </summary>
    public interface IEmployeeRepository
    {
        #region Employee Management
        /// <summary>
        /// GetEmployeePage - Lấy danh sách nhân viên phân trang
        /// </summary>
        /// <param name="flt">Filter input</param>
        /// <returns></returns>
        Task<CommonDataPage> GetEmployeePage(FilterInpEmployee flt);

        /// <summary>
        /// GetEmployeeInfo - Lấy thông tin chi tiết nhân viên
        /// </summary>
        /// <param name="empId">Employee ID</param>
        /// <returns></returns>
        Task<EmployeeInfo> GetEmployeeInfo(Guid? empId);

        /// <summary>
        /// DeleteEmployeeAsync - Xóa nhân viên
        /// </summary>
        /// <param name="empId">Employee ID</param>
        /// <returns></returns>
        Task<BaseValidate> DeleteEmployeeAsync(Guid? empId);
        #endregion
    }
}


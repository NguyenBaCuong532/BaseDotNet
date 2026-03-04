using UNI.Model;

namespace UNI.Resident.Model.Employee
{
    /// <summary>
    /// FilterInpEmployee - Filter cho danh sách nhân viên
    /// </summary>
    public class FilterInpEmployee : FilterInput
    {
        public string departmentName { get; set; }
        public string orgName { get; set; }
        public string companyName { get; set; }
        public bool? emp_st { get; set; }
    }
}


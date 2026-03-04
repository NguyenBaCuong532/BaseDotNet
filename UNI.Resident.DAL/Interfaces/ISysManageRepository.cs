using UNI.Model;
using UNI.Resident.Model.Resident;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.DAL.Interfaces
{
    public interface ISysManageRepository
    {
        Task<CommonViewInfo> GetManagerFilter(string userId, string table_key);
        Task<List<CommonValue>> GetObjectsAsync(string userId, string objKey, bool? isAll);
        Task<List<CommonValue>> GetCommonListAsync(string userId, bool isFilter, string tableName, string columnName, string columnId);
        Task<List<CommonValue>> GetServiceProviderListAsync(string userId, int? ContractTypeId);
        Task<List<CommonValue>> GetFamilyMemberListAsync(string userId, int? ApartmentId);
        Task<List<ProjectListModel>> GetProjectListAsync(string userId, bool? isAll);
        Task<List<ProjectListModel>> GetProjectList1Async(string userId, bool? isAll);
        Task<List<CommonValue>> GetProjectListForOutSideAsync(bool? isAll);
        Task<List<CommonValue>> GetNotifyListAsync(string userId, string external_key);

    }
}

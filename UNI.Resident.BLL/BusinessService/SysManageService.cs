using DocumentFormat.OpenXml.Office2013.Drawing.ChartStyle;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Model;
using UNI.Resident.Model.Resident;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.BusinessService
{
    public class SysManageService : ISysManageService
    {
        private readonly ISysManageRepository _sysManageRepository;

        public SysManageService(ISysManageRepository coreserviceRepository)
        {
            if (coreserviceRepository != null)
                _sysManageRepository = coreserviceRepository;
        }
        public Task<CommonViewInfo> GetManagerFilter(string userId, string table_key)
        {
            return _sysManageRepository.GetManagerFilter(userId, table_key);
        }
        public async Task<List<CommonValue>> GetObjectsAsync(string userId, string objKey, bool? isAll)
        {
            return await _sysManageRepository.GetObjectsAsync(userId, objKey, isAll);
        }
        
        public async Task<List<CommonValue>> GetCommonListAsync(string userId, bool isFilter, string tableName, string columnName, string columnId)
        {
            return await _sysManageRepository.GetCommonListAsync(userId, isFilter, tableName, columnName, columnId);
        }
        public async Task<List<CommonValue>> GetServiceProviderListAsync(string userId, int? ContractTypeId)
        {
            return await _sysManageRepository.GetServiceProviderListAsync(userId, ContractTypeId);
        }
        public async Task<List<CommonValue>> GetFamilyMemberListAsync(string userId, int? ApartmentId)
        {
            return await _sysManageRepository.GetFamilyMemberListAsync(userId, ApartmentId);
        }
        public async Task<List<ProjectListModel>> GetProjectListAsync(string userId, bool? isAll)
        {
            return await _sysManageRepository.GetProjectListAsync(userId, isAll);
        }
        public async Task<List<ProjectListModel>> GetProjectList1Async(string userId, bool? isAll)
        {
            return await _sysManageRepository.GetProjectList1Async(userId, isAll);
        }
        public async Task<List<CommonValue>> GetProjectListForOutSideAsync(bool? isAll)
        {
            return await _sysManageRepository.GetProjectListForOutSideAsync(isAll);
        }

        public async Task<List<CommonValue>> GetNotifyListAsync(string userId, string external_key)
        {
            return await _sysManageRepository.GetNotifyListAsync(userId, external_key);
        }
    }
}

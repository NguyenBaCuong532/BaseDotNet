using System;
using System.Data;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Elevator;

namespace UNI.Resident.DAL.Repositories.Elevator
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IElevatorRepository" />
    public class ElevatorDeviceRepository : UniBaseRepository, IElevatorDeviceRepository
    {

        public ElevatorDeviceRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        #region elevator-reg
        
        public async Task<CommonViewInfo> GetElevatorDeviceFilter()
        {
            const string storedProcedure = "elevator_device_filter";
            return await GetTableFilterAsync(storedProcedure);
        }
        public async Task<CommonDataPage> GetElevatorDevicePage(FilterElevatorDevice filter)
        {
            const string storedProcedure = "sp_res_elevator_device_page";
            return await GetDataListPageAsync(storedProcedure, filter,
                new { filter.ProjectCd, filter.BuildingCd, filter.BuildZone, filter.FloorNumber });
        }
        public async Task<BaseValidate> SetElevatorDeviceInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_device_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.id });
        }
        public Task<BaseValidate> DelElevatorDeviceInfo(string ids)
        {
            const string storedProcedure = "sp_res_elevator_device_del";
            return base.DeleteAsync(storedProcedure, new { ids });
        }
        public async Task<CommonViewInfo> GetElevatorDeviceInfo(string id)
        {
            const string storedProcedure = "sp_res_elevator_device_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id });
        }
        #endregion
        public async Task<DataSet> GetElevatorDeviceImportTemp()
        {
            const string storedProcedure = "sp_res_elevator_device_imports_temp";
            return await GetDataSetAsync(storedProcedure);
        }
        public async Task<ImportListPage> SetElevatorDeviceImport(ElevatorDeviceImportSet importSet)
        {
            const string storedProcedure = "sp_res_elevator_device_import";
            return await base.SetImport<ElevatorDeviceImportItem, ElevatorDeviceImportSet>(storedProcedure,
                importSet, "ele_devices", TableTypes.ELEVATOR_DEVICE_IMPORT_TYPE, new { });
        }

        public async Task<CommonViewIdInfo> SetElevatorDeviceDraft(CommonViewIdInfo info)
        {
            const string storedProcedure = "sp_res_elevator_device_draft";
            return await SetInfoAsync<CommonViewIdInfo>(storedProcedure, info, param =>
            {
                param.Add("id", info.id);
                return param;
            });
        }

        // Danh mục loại thiết bị thang máy
        public async Task<CommonViewInfo> GetElevatorDeviceCategoryFilter()
        {
            const string storedProcedure = "elevator_device_category_filter";
            return await GetTableFilterAsync(storedProcedure);
        }

        public async Task<CommonDataPage> GetElevatorDeviceCategoryPage(FilterElevatorDevice filter)
        {
            const string storedProcedure = "sp_res_elevator_device_category_page";
            return await GetDataListPageAsync(storedProcedure, filter,
                new { filter.ProjectCd, filter.BuildingCd, filter.BuildZone, filter.FloorNumber });
        }

        public async Task<BaseValidate> SetElevatorDeviceCategoryInfo(CommonViewInfo info)
        {
            const string storedProcedure = "sp_res_elevator_device_category_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.id });
        }

        public Task<BaseValidate> DelElevatorDeviceCategoryInfo(string ids)
        {
            const string storedProcedure = "sp_res_elevator_device_category_del";
            return base.DeleteAsync(storedProcedure, new { ids });
        }

        public async Task<CommonViewInfo> GetElevatorDeviceCategoryInfo(string id)
        {
            const string storedProcedure = "sp_res_elevator_device_category_field";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { id });
        }

        public async Task<CommonViewIdInfo> SetElevatorDeviceCategoryDraft(CommonViewIdInfo info)
        {
            const string storedProcedure = "sp_res_elevator_device_category_draft";
            return await SetInfoAsync<CommonViewIdInfo>(storedProcedure, info, param =>
            {
                param.Add("id", info.id);
                return param;
            });
        }
    }
}

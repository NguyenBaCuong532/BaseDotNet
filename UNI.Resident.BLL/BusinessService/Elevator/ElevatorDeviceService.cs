using DocumentFormat.OpenXml.EMMA;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class ElevatorDeviceService : IElevatorDeviceService
    {
        private readonly IElevatorDeviceRepository _homeRepository;
        protected readonly ILogger _logger;
        public ElevatorDeviceService(
            IElevatorDeviceRepository homeRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        
        #region elevator-reg

        public async Task<CommonViewInfo> GetElevatorDeviceFilter()
        {
            return await _homeRepository.GetElevatorDeviceFilter();
        }
        public async Task<CommonDataPage> GetElevatorDevicePage(FilterElevatorDevice filter)
        {
            return await _homeRepository.GetElevatorDevicePage(filter);
        }
        public Task<BaseValidate> SetElevatorDeviceInfo(CommonViewInfo info)
        {
            return _homeRepository.SetElevatorDeviceInfo(info);
        }
        public Task<BaseValidate> DelElevatorDeviceInfo(string ids)
        {
            return _homeRepository.DelElevatorDeviceInfo(ids);
        }
        public async Task<CommonViewInfo> GetElevatorDeviceInfo(string id)
        {
            return await _homeRepository.GetElevatorDeviceInfo(id);
        }
        #endregion elevator-reg

        public async Task<BaseValidate<Stream>> GetElevatorDeviceImportTemp()
        {
            try
            {
                var ds = await _homeRepository.GetElevatorDeviceImportTemp();
                var r = new FlexcellUtils();
                var template = await File.ReadAllBytesAsync($"templates/elevator/import_elevator_device.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, ds, p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> SetElevatorDeviceImport(ElevatorDeviceImportSet eleDevice)
        {
            return _homeRepository.SetElevatorDeviceImport(eleDevice);
        }

        public Task<CommonViewIdInfo> SetElevatorDeviceDraft(CommonViewIdInfo info)
        {
            return _homeRepository.SetElevatorDeviceDraft(info);
        }


        // Danh mục thiết bị thang máy
        public async Task<CommonViewInfo> GetElevatorDeviceCategoryFilter()
        {
            return await _homeRepository.GetElevatorDeviceCategoryFilter();
        }

        public async Task<CommonDataPage> GetElevatorDeviceCategoryPage(FilterElevatorDevice filter)
        {
            return await _homeRepository.GetElevatorDeviceCategoryPage(filter);
        }

        public Task<BaseValidate> SetElevatorDeviceCategoryInfo(CommonViewInfo info)
        {
            return _homeRepository.SetElevatorDeviceCategoryInfo(info);
        }

        public Task<BaseValidate> DelElevatorDeviceCategoryInfo(string ids)
        {
            return _homeRepository.DelElevatorDeviceCategoryInfo(ids);
        }

        public async Task<CommonViewInfo> GetElevatorDeviceCategoryInfo(string oid)
        {
            return await _homeRepository.GetElevatorDeviceCategoryInfo(oid);
        }

        public Task<CommonViewIdInfo> SetElevatorDeviceCategoryDraft(CommonViewIdInfo info)
        {
            return _homeRepository.SetElevatorDeviceCategoryDraft(info);
        }
    }
}

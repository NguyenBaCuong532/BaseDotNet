using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IElevatorDeviceService
    {

        #region elevator-reg
        
        
        Task<CommonViewInfo> GetElevatorDeviceFilter();
        Task<CommonDataPage> GetElevatorDevicePage(FilterElevatorDevice filter);
        Task<BaseValidate> SetElevatorDeviceInfo(CommonViewInfo info);
        Task<BaseValidate> DelElevatorDeviceInfo(string ids);
        Task<CommonViewInfo> GetElevatorDeviceInfo(string oid);
        Task<BaseValidate<Stream>> GetElevatorDeviceImportTemp();
        Task<ImportListPage> SetElevatorDeviceImport(ElevatorDeviceImportSet eleDevice);
        Task<CommonViewIdInfo> SetElevatorDeviceDraft(CommonViewIdInfo info);
        

        // Danh mục thiết bị thang máy
        Task<CommonViewInfo> GetElevatorDeviceCategoryFilter();
        Task<CommonDataPage> GetElevatorDeviceCategoryPage(FilterElevatorDevice filter);
        Task<BaseValidate> SetElevatorDeviceCategoryInfo(CommonViewInfo info);
        Task<BaseValidate> DelElevatorDeviceCategoryInfo(string ids);
        Task<CommonViewInfo> GetElevatorDeviceCategoryInfo(string oid);
        Task<CommonViewIdInfo> SetElevatorDeviceCategoryDraft(CommonViewIdInfo info);

        #endregion elevator-reg

    }
}

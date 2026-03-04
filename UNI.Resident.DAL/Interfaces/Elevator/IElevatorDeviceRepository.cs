using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces.Elevator
{
    public interface IElevatorDeviceRepository
    {
        #region elevator-reg
        
        Task<CommonDataPage> GetElevatorDevicePage(FilterElevatorDevice filter);
        Task<CommonViewInfo> GetElevatorDeviceFilter();
        Task<BaseValidate> SetElevatorDeviceInfo(CommonViewInfo info);
        Task<BaseValidate> DelElevatorDeviceInfo(string ids);
        Task<CommonViewInfo> GetElevatorDeviceInfo(string id);
        Task<DataSet> GetElevatorDeviceImportTemp();
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

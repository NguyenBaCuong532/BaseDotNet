using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IAppElevatorService
    {
        
        #region elevator-reg
        Task SetAccessFloorAsync(HomAccessFloor floor);
        Task<HomAccessGet> GetAccessFloorsAsync(int mode);
        #endregion elevator-reg

    }
}

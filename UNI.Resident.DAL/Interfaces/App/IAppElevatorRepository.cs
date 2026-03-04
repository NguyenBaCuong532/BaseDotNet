using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces.App
{
    public interface IAppElevatorRepository
    {
        #region elevator-reg
        Task<List<FloorInfoGo>> GetFoorInfoGoAsync(FilterElevatorFloor filter);
        Task SetAccessFloorAsync(HomAccessFloor floor);
        Task<HomAccessGet> GetAccessFloorsAsync(int mode);
        #endregion elevator-reg
    }
}

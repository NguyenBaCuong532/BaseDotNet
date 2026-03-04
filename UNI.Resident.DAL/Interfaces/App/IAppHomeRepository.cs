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
    public interface IAppHomeRepository
    {
        #region app-home
        Task<PageHome> GetPageHomeAsync(string userId);
        Task<List<ProjectApp>> GetProjectsAsync(string userId);
        Task<List<HomBuilding>> GetBuildingsAsync(string projectCd);
        Task<List<HomFloor>> GetFloorListAsync(string buildingCd);
        Task<List<HomRoom>> GetRoomsAsync(string buildingCd, string floorNo);
        Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language);
        #endregion app-home
    }
}

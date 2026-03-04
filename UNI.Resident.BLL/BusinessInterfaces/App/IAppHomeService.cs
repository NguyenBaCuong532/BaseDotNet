using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IAppHomeService
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

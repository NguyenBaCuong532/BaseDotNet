using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class AppHomeService : IAppHomeService
    {
        private readonly IAppHomeRepository _homeRepository;
        public AppHomeService(
            IAppHomeRepository homeRepository)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
        }
        #region app-home
        
        public async Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language)
        {
            return await _homeRepository.GetApartmentPageHomeAsync(language);
        }
        public async Task<PageHome> GetPageHomeAsync(string userId)
        {
            return await _homeRepository.GetPageHomeAsync(userId);
        }
        public async Task<List<HomBuilding>> GetBuildingsAsync(string projectCd)
        {
            return await _homeRepository.GetBuildingsAsync(projectCd);
        }
        public async Task<List<HomFloor>> GetFloorListAsync(string buildingCd)
        {
            return await _homeRepository.GetFloorListAsync(buildingCd);
        }
        public async Task<List<HomRoom>> GetRoomsAsync(string buildingCd, string floorNo)
        {
            return await _homeRepository.GetRoomsAsync(buildingCd, floorNo);
        }
        public async Task<List<ProjectApp>> GetProjectsAsync(string userId)
        {
            return await _homeRepository.GetProjectsAsync(userId);
        }
        #endregion app-home
    }
}

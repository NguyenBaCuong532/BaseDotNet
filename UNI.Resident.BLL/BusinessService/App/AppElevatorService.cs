using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="IAppElevatorService" />
    public class AppElevatorService : IAppElevatorService
    {
        private readonly IAppElevatorRepository _homeRepository;
        protected readonly ILogger _logger;
        public AppElevatorService(
            IAppElevatorRepository homeRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        
        #region elevator-reg        
        public async Task SetAccessFloorAsync(HomAccessFloor floor)
        {
            await _homeRepository.SetAccessFloorAsync(floor);
        }
        public async Task<HomAccessGet> GetAccessFloorsAsync(int mode)
        {
            return await _homeRepository.GetAccessFloorsAsync(mode);
        }
        #endregion elevator-reg

    }
}

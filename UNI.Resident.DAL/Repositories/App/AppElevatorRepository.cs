using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IAppElevatorRepository" />
    public class AppElevatorRepository : UniBaseRepository, IAppElevatorRepository
    {

        public AppElevatorRepository(IUniCommonBaseRepository commonInfo) : base(commonInfo)
        {
        }

        #region elevator-reg
        public async Task<List<FloorInfoGo>> GetFoorInfoGoAsync(FilterElevatorFloor filter)
        {
            const string storedProcedure = "sp_Hom_ELE_Floor_View";
            return await base.GetListAsync<FloorInfoGo>(storedProcedure, filter);
        }
        public async Task SetAccessFloorAsync(HomAccessFloor floor)
        {
            const string storedProcedure = "sp_Hom_ELE_Access_Floor";
            await base.GetFirstOrDefaultAsync<int>(storedProcedure, floor);
        }
        public async Task<HomAccessGet> GetAccessFloorsAsync(int mode)
        {
            const string storedProcedure = "sp_Hom_ELE_Access_Last_Get";
            var rs = await base.GetMultipleAsync(storedProcedure,
            new { mode },
            async result =>
            {
                var data = new HomAccessGet();
                if (data != null)
                {
                    data.floor_lasts = (await result.ReadAsync<HomAccessFloorLast>()).ToList();
                }
                return data;
            });
            return rs;
        }
        #endregion elevator-reg

    }
}

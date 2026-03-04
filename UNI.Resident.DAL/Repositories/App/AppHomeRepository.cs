using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IAppHomeRepository" />
    public class AppHomeRepository : UniBaseRepository, IAppHomeRepository
    {

        public AppHomeRepository(IUniCommonBaseRepository common) : base(common)
        {
        }
        #region app-apartment-reg
        public async Task<PageHome> GetPageHomeAsync(string userId)
        {
            const string storedProcedure = "sp_Hom_Get_Page_Home_ByUserId";
            return await GetMultipleAsync<PageHome>(storedProcedure, new { userId }, async reader =>
            {
                var homePage = new PageHome();
                homePage.Profile = await reader.ReadFirstOrDefaultAsync<HomFamilyProfile>();
                //homePage.wallet = await reader.ReadFirstOrDefaultAsync<Wallet>();
                //if (homePage.wallet != null)
                //{
                //    homePage.wallet.TranferLink = await reader.ReadFirstOrDefaultAsync<WalBankLink>();
                //    if (homePage.wallet.TranferLink == null)
                //        homePage.wallet.TranferLink = new WalBankLink();
                //}
                return homePage;
            });
        }
        public async Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Home";
            return await GetMultipleAsync<HomApartmentPageHome>(storedProcedure, new { language }, async reader =>
            {
                var data = await reader.ReadFirstOrDefaultAsync<HomApartmentPageHome>();
                if (data != null)
                {
                    data.Profile = await reader.ReadFirstOrDefaultAsync<HomFamilyProfile>();
                    data.registed = await reader.ReadFirstOrDefaultAsync<HomApartmentRegGet>();
                }
                return data;
            });
        }
        #endregion

        public async Task<List<ProjectApp>> GetProjectsAsync(string userId)
        {
            const string storedProcedure = "sp_Hom_Project_List";
            return await GetListAsync<ProjectApp>(storedProcedure, new { userId });
        }
        public async Task<List<HomBuilding>> GetBuildingsAsync(string projectCd)
        {
            const string storedProcedure = "sp_Hom_Building_List";
            return await GetListAsync<HomBuilding>(storedProcedure, new { projectCd });
        }
        public async Task<List<HomFloor>> GetFloorListAsync(string buildingCd)
        {
            const string storedProcedure = "sp_Hom_Floor_List";
            return await GetListAsync<HomFloor>(storedProcedure, new { buildingCd });
        }
        public async Task<List<HomRoom>> GetRoomsAsync(string buildingCd, string floorNo)
        {
            const string storedProcedure = "sp_Hom_Room_List";
            return await GetListAsync<HomRoom>(storedProcedure, new { buildingCd, floorNo });
        }
    }
}

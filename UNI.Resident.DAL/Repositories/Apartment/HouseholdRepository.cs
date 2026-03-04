using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Apartment
{
    public class HouseholdRepository : UniBaseRepository, IHouseholdRepository
    {
        protected ILogger<HouseholdRepository> _logger;

        public HouseholdRepository(IConfiguration configuration,
            ILogger<HouseholdRepository> logger,
            IHostingEnvironment environment, IUniCommonBaseRepository common) : base(common)
        {
            _logger = logger;
        }
        #region web-Household
        
        public async Task<CommonViewInfo> GetHouseholdFilter(string userId)
        {
            const string storedProcedure = "sp_res_apartment_household_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId });
        }
        public async Task<CommonDataPage> GetHouseholdPageByApartment(HouseholdRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_household_page_byid";
            return await GetDataListPageAsync(storedProcedure, query, new { 
                ApartmentId = query.ApartmentId,
                Oid = query.Oid
            });
        }
        public async Task<CommonDataPage> GetHouseholdPage(HouseholdRequestModel1 query)
        {
            const string storedProcedure = "sp_res_household_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.projectCd, query.buildingCd });
        }
        public async Task<HouseholdInfo> GetHouseholdInfo(string CustId, int? ApartmentId, Guid? apartOid, Guid? Oid)
        {
            const string storedProcedure = "sp_res_apartment_household_field";
            return await GetFieldsAsync<HouseholdInfo>(storedProcedure, new { 
                CustId, 
                ApartmentId = ApartmentId,
                apartOid = apartOid,
                Oid = Oid
            });
        }

        public async Task<BaseValidate> SetHouseholdInfo(HouseholdInfo info)
        {
            const string storedProcedure = "sp_res_apartment_household_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { 
                Oid = info.Id,
                apartOid = info.apartOid,
                ApartmentId = info.ApartmentId
            });
            //return await SetInfoAsync<BaseValidate>(storedProcedure, null, new
            //{
            //    info.CustId,
            //    info.UserID,
            //    info.IsResident,
            //    info.ResAdd1,
            //    info.ContactAdd1,
            //    info.PassNo,
            //    info.PassDate,
            //    info.PassPlace,
            //    info.ApartmentId
            //});
        }

        #endregion
    }
}

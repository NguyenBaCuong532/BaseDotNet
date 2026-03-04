using System;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.CardVehicle
{
    public class VehicleRepository : UniBaseRepository, IVehicleRepository
    {
        protected ILogger<VehicleRepository> _logger;

        public VehicleRepository(IUniCommonBaseRepository common,
            ILogger<VehicleRepository> logger,
            IHostingEnvironment environment) : base(common)
        {
            _logger = logger;
        }
        #region web-Vehicle

        public async Task<CommonDataPage> GetApartmentVehiclePageAsync(VehicleRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_vehicle_page_byapartid";
            // Truyền cả 2 tham số xuống store
            return await GetDataListPageAsync(storedProcedure, query, new { Oid = query.Oid, ApartmentId = query.ApartmentId });
        }

        public async Task<ApartmentVehicleInfo> GetApartmentVehicleInfo(string userId, int CardVehicleId, Guid? cardVehicleOid = null)
        {
            const string storedProcedure = "sp_res_apartment_vehicle_field";
            return await GetFieldsAsync<ApartmentVehicleInfo>(storedProcedure, new { cardVehicleId = CardVehicleId, cardVehicleOid });
        }

        public async Task<BaseValidate> SetApartmentVehicleInfo([FromBody] viewBaseInfo info)
        {
            const string storedProcedure = "sp_res_apartment_vehicle_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, new {
                CardVehicleId = info.GetValueByFieldName("CardVehicleId"),
                startDate = info.GetValueByFieldName("StartTime"),
                endDate = info.GetValueByFieldName("EndTime"),
                VehicleNum = info.GetValueByFieldName("VehicleNum"),
                CardCd = info.GetValueByFieldName("CardCd")
            });
        }

        public async Task<ImportListPage> SetVehicleNumImport(string userId, VehicleNumImportSet importSet, bool? check)
        {
            const string storedProcedure = "sp_res_apartment_vehicle_num_import";
            return await base.SetImport<VehicleNumImportItem, VehicleNumImportSet>(storedProcedure,
                importSet, "vehicleNumImport", "VehicleNumImportType", new { check });
        }
        #endregion
    }
}

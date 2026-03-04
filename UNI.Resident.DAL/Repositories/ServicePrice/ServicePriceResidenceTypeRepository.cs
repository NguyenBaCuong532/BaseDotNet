using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Các loại hình căn hộ
    /// </summary>
    public class ServicePriceResidenceTypeRepository : ResidentBaseRepository, IServicePriceResidenceTypeRepository
    {
        public ServicePriceResidenceTypeRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<List<CommonValue>> GetServicePriceResidenceTypeNameValue(string filter)
            => await base.GetListAsync<CommonValue>("sp_res_service_price_residence_type_get_name_value", new { filter });
    }
}
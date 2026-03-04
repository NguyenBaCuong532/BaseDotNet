using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.DAL.Repositories.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ - Loại giá dịch vụ: sinh hoạt, kinh doanh..
    /// </summary>
    public class ServicePriceTypeRepository : ResidentBaseRepository, IServicePriceTypeRepository
    {
        public ServicePriceTypeRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<List<CommonValue>> GetServicePriceTypeForDropdownList(string filter)
            => await base.GetListAsync<CommonValue>("sp_res_service_price_type_get_code_name", new { filter });
    }
}
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories
{
    public class NobleRepository : UniBaseRepository, INobleRepository
    {
        public NobleRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        public async Task<List<ApartmentInfo>> GetApartmentByPhone(string phone)
        {
            const string storedProcedure = "sp_res_noble_apartment_list";
            return await GetListAsync<ApartmentInfo>(storedProcedure, new { phone });
        }

        public async Task<ApartmentOwner> GetApartmnetOwnerByPhoneNumber(string phone)
        {
            const string storedProcedure = "sp_res_noble_owner_phone";
            var rs = await base.GetMultipleAsync(storedProcedure, new { phone },
            async result =>
            {
                var data = await result.ReadFirstOrDefaultAsync<ApartmentOwner>();
                if (data != null && !result.IsConsumed)
                {
                    data.ApartmentList = result.Read<PrjoectCdRoomCode>().ToList();
                }
                return data;
            });
            return rs;
        }
    }
}

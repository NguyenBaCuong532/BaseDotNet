using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces
{
    public interface INobleService
    {
        Task<List<ApartmentInfo>> GetApartmentByPhone(string phone);
        Task<ApartmentOwner> GetApartmnetOwnerByPhoneNumber(string phone);
    }
}

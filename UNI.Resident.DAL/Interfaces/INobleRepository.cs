using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces
{
    public interface INobleRepository
    {
        Task<List<ApartmentInfo>> GetApartmentByPhone(string phone);
        Task<ApartmentOwner> GetApartmnetOwnerByPhoneNumber(string phone);
    }
}

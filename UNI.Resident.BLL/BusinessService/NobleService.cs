using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService
{
    public class NobleService : INobleService
    {
        private readonly INobleRepository _nobleRepository;
        public NobleService(INobleRepository nobleRepository)
        {
            _nobleRepository = nobleRepository;
        }

        public Task<List<ApartmentInfo>> GetApartmentByPhone(string phone)
        {
            return _nobleRepository.GetApartmentByPhone(phone);
        }

        public Task<ApartmentOwner> GetApartmnetOwnerByPhoneNumber(string phone)
        {
            return _nobleRepository.GetApartmnetOwnerByPhoneNumber(phone);
        }
    }
}

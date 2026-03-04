using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model.Bank.KLBank;

namespace UNI.Resident.BLL.BusinessInterfaces.Transaction
{
    public interface IApiBankService : IUniBaseService
    {
        klbResponseBase CreateResonse<T>(T data, int code, string mesage);

        T PaygateAuthenticate<T>(EncryptedBodyRequest requestData);
    }
}
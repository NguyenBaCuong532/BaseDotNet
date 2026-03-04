using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Resident.Model.Common;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.Bank.KLBank;

namespace UNI.Resident.BLL.BusinessInterfaces.Transaction
{
    public interface ITransactionService : IUniBaseService
    {
        Task<klbResponseBase> InquiryChecking(klbInquiryCheckingRequest request);

        Task<klbResponseBase> DepositChecking(klbDepositCheckingRequest request);

        Task<klbResponseBase> SetPaymentCallBack(klbNotifyTransactionEnscrypt request);
        Task<BaseValidate> SetLogTransactionInfo(LogTransactionBank log);
        Task<CommonViewInfo> GetTransBankFilter(string userId);
        Task<CommonDataPage> GetTransBankPage(FilterTransInput param);
    }
}
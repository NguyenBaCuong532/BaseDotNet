using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Resident.Model.Common;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.Bank.KLBank;

namespace UNI.Resident.DAL.Interfaces.Transaction
{
    public interface ITransactionRepository : IUniBaseRepository
    {
        Task<klbInquiryCheckingResponse> InquiryChecking(klbInquiryCheckingRequest request);

        Task<klbDepositCheckingResponse> DepositChecking(klbDepositCheckingRequest request);

        Task<BaseValidate> SetPaymentCallBack(klbNotifyTransactionEnscrypt response);
        Task<BaseValidate> SetLogTransactionInfo(LogTransactionBank log);
        Task<BaseValidate> PushNotifyAsync(string virtualAccount);
        Task<CommonViewInfo> GetTransBankFilter(string userId);
        Task<CommonDataPage> GetTransBankPage(FilterTransInput param);
    }
}
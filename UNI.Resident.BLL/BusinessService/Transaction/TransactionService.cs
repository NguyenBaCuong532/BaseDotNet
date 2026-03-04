using UNI.Resident.BLL.BusinessInterfaces.Transaction;
using UNI.Resident.DAL.Interfaces.Transaction;
using UNI.Resident.Model.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.Bank.KLBank;

namespace UNI.Resident.BLL.BusinessService.Transaction
{
    public class TransactionService : UniBaseService, ITransactionService
    {
        private readonly ITransactionRepository _tranRepository;
        private readonly IApiBankService _apiBankService;
        public TransactionService(ITransactionRepository tranRepository, IApiBankService apiBankService)
        {
            _tranRepository = tranRepository;
            _apiBankService = apiBankService;
        }

        public async Task<klbResponseBase> InquiryChecking(klbInquiryCheckingRequest request)
        {
            var result = await _tranRepository.InquiryChecking(request);
            if (result != null)
                return _apiBankService.CreateResonse(new klbInquiryCheckingResponse() { actualAccount = result.actualAccount, displayName = result.displayName }, 0, "success");

            return _apiBankService.CreateResonse(new klbInquiryCheckingResponse() { actualAccount = "", displayName = "" }, 1, "fails");
        }

        public async Task<klbResponseBase> DepositChecking(klbDepositCheckingRequest request)
        {
            var result = await _tranRepository.DepositChecking(request);
            if (result != null)
                return _apiBankService.CreateResonse(new klbDepositCheckingResponse() { actualAccount = result.actualAccount, amount = result.amount, displayName = result.displayName }, 0, "success");
            return _apiBankService.CreateResonse(new klbDepositCheckingResponse() { actualAccount = "", amount = 0, displayName = "" }, 1, "fails");
        }

        public async Task<klbResponseBase> SetPaymentCallBack(klbNotifyTransactionEnscrypt request)
        {
            // giải mã data kiên
            if (request != null)
            {
                var result = await _tranRepository.SetPaymentCallBack(request);
                if(result.notiQue)
                     await _tranRepository.PushNotifyAsync(request.virtualAccount);
                if (result.valid)
                    return _apiBankService.CreateResonse(new klbNotifyTransactionResponse() { status = true }, 0, "success");
            }

            return _apiBankService.CreateResonse(new klbNotifyTransactionResponse() { status = false }, 1, "fails");

        }

        public Task<BaseValidate> SetLogTransactionInfo(LogTransactionBank log)
        {
            return _tranRepository.SetLogTransactionInfo(log);
        }

        public Task<CommonViewInfo> GetTransBankFilter(string userId)
        {
            return _tranRepository.GetTransBankFilter(userId);
        }

        public Task<CommonDataPage> GetTransBankPage(FilterTransInput param)
        {
            return _tranRepository.GetTransBankPage(param);
        }
    }
}
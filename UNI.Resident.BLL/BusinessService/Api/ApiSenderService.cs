using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.DAL.Interfaces.Api;
using System.Threading.Tasks;
using UNI.Model.APPM;

namespace UNI.Resident.BLL.BusinessService.Api
{
    public class ApiSenderService : IApiSenderService
    {
        private readonly IApiSenderRepository _apisenderRepository;
        
        public ApiSenderService(IApiSenderRepository hrmRepository
            )
        {
            //if (_apisenderRepository != null)
                _apisenderRepository = hrmRepository;
        }
        public Task<MessageRespone> SendSmsAs(MessageBase send)
        {
            return _apisenderRepository.SendSmsAs(send);
        }
        public Task SendMailgunEmail(EmailBase emailModel)
        {
            return _apisenderRepository.SendMailgunEmail(emailModel);
        }
        
    }
}

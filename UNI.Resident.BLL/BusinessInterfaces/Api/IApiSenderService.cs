using System.Threading.Tasks;
using UNI.Model.APPM;

namespace UNI.Resident.BLL.BusinessInterfaces.Api
{
    public interface IApiSenderService
    {
        Task SendMailgunEmail(EmailBase emailModel);
        Task<MessageRespone> SendSmsAs(MessageBase send);
    }
}

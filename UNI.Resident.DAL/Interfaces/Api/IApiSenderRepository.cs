using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;

namespace UNI.Resident.DAL.Interfaces.Api
{
    public interface IApiSenderRepository
    {
        Task SendMailgunEmail(EmailBase emailModel);
        Task<MessageRespone> SendSmsAs(MessageBase send);
        Task<BaseResponse<string>> SendToKafka(string message, string topic = null);
    }
}

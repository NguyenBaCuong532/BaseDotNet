using UNI.Model.APPM;
using UNI.Model.SMS.RequestAPI;
using System;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    public interface ISmsSender
    {
        //Task<SMSResponseModel> SendSmsAsync(string number, string message, DateTime? scheduleAt = null);
        //Task<Model.SMS.RequestAPI.SMSResponseModel> SendSmsAsync(MessageBase send);
        Task<MessageRespone> SendSmsAs(MessageBase send);
    }
}

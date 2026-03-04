using UNI.Model.APPM;
using UNI.Model.Email;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string message);
        //Task SendAmazonEmail(string emails, string subject, string message);
        //Task SendAmazonEmail(List<string> emails, string subject, string message);
        Task SendMailgunEmail(List<string> emails, EmailGroup emailGroup, List<string> emailModelAttachs);
        Task SendMailgunEmail(string emails, EmailGroup emailGroup);
        Task SendMailgunEmail(EmailBase emailModel);
        
    }
}

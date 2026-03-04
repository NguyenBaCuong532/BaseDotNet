using FluentEmail.Core;
using FluentEmail.Core.Models;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MimeKit;
using MimeKit.Text;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.BLL.HelperService;
using UNI.Resident.DAL.Repositories.Api;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.Email;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.App
{
    // This class is used by the application to send Email and SMS
    // when you turn on two-factor authentication in ASP.NET Identity.
    // For more details see this link http://go.microsoft.com/fwlink/?LinkID=532713
    public class AuthMessageSender : HttpClientBase, IEmailSender, ISmsSender
    {
        protected AppSettings _appSettings;
        private MailgunSendService _mailgunSendService;
        private readonly ILogger<AuthMessageSender> _logger;
        private string _BaseUrls;
        private string _keyAuth;
        private string _fromAddress;
        private string _fromName;
        public AuthMessageSender(IOptions<AppSettings> appSettings,
            ILogger<AuthMessageSender> logger, IConfiguration configuration)
        {
            _logger = logger;
            _appSettings = appSettings.Value;
            _mailgunSendService = new MailgunSendService(
                configuration["EmailService:Domain"], // Mailgun Domain
                configuration["EmailService:ApiKey"], // Mailgun API Key
                configuration["EmailService:BaseUrls"]
            );
            _fromAddress = configuration["EmailService:FromAddress"];
            _fromName = configuration["EmailService:FromName"];

            _keyAuth = configuration["SmsService:KeyAuth"];
            _BaseUrls = configuration["SmsService:BaseUrls"];//Cloud SMS srv
        }
        public Task SendEmailAsync(string email, string subject, string message)
        {
            var mailMessage= new MimeMessage();
            mailMessage.From.Add(new MailboxAddress("Sunshine Group", "info@sunshinegroup.vn"));
            mailMessage.To.Add(new MailboxAddress(email));
            mailMessage.Subject = subject;

            mailMessage.Body = new TextPart(TextFormat.Html)
            {
                Text = message
            };

            using (var client = new SmtpClient())
            {
                // For demo-purposes, accept all SSL certificates (in case the server supports STARTTLS)
                client.ServerCertificateValidationCallback = (s, c, h, e) => true;

                client.Connect("mail.sunshinegroup.vn", 25, false);

                // Note: since we don't have an OAuth2 token, disable
                // the XOAUTH2 authentication mechanism.
                client.AuthenticationMechanisms.Remove("XOAUTH2");

                // Note: only needed if the SMTP server requires authentication
                client.Authenticate("admin@sunshinegroup.vn", "sunshine@123");

                client.Send(mailMessage);
            }
            // Plug in your email service here to send an email.
            return Task.FromResult(0);
        }

        public Task SendMailgunEmail(List<string> emails, EmailGroup emailGroup, List<string> emailModelAttachs)
        {
            string fromAdd = string.IsNullOrEmpty(emailGroup.SendEmail) ? _fromAddress : emailGroup.SendEmail;
            List <Address> addresses = new List<Address>();
            emails.ForEach(x => addresses.Add(new Address(x)));
            var email = Email
                .From(fromAdd, string.IsNullOrEmpty(emailGroup.SendName) ? _fromName : emailGroup.SendName)
                .To(addresses)
                .Subject(emailGroup.Title)
                .Body(emailGroup.Content);
            email.Data.IsHtml = true;
            emailModelAttachs?.ForEach(e => email.AttachFromFilename(e));
            _mailgunSendService.ReDomainName(fromAdd);
            return _mailgunSendService.SendAsync(email, sendBatch:true);
        }

        public Task SendMailgunEmail(string emails, EmailGroup emailGroup)
        {
            return SendMailgunEmail(new List<string>(emails.Split(',')), emailGroup, null);
        }

        public Task SendMailgunEmail(EmailBase emailModel)
        {
            
            var maillist = new List<string>(emailModel.To.Split(','));
            List<Address> addresses = new List<Address>();
            maillist.ForEach(x => addresses.Add(new Address(x)));
            List<Address> addbcc = new List<Address>();
            string fromAdd = string.IsNullOrEmpty(emailModel.SendBy) ? _fromAddress : emailModel.SendBy;
            if (!string.IsNullOrEmpty(emailModel.Bcc))
            {
                var maillbcc = new List<string>(emailModel.Bcc.Split(','));
                maillbcc.ForEach(x => addbcc.Add(new Address(x)));
            }
            var email = Email
                .From(fromAdd, string.IsNullOrEmpty(emailModel.SendName) ? _fromName : emailModel.SendName)
                .To(addresses)
                .BCC(addbcc)
                .Subject(emailModel.Subject)
                .Body(emailModel.Contents);

            if (emailModel.BodyType != "text")
                email.Data.IsHtml = true;
            else
                email.Data.IsHtml = false;
            emailModel.Attachs?.ForEach(e => email.Attach(this.FromFilename(e, null)));
            _mailgunSendService.ReDomainName(fromAdd);
            return _mailgunSendService.SendAsync(email, sendBatch: true, id: emailModel.sourceId);
        }

        public Attachment FromFilename(string filename, string contentType = null)
        {
            var stream = System.IO.File.OpenRead(filename);
            var att =new Attachment()
            {
                Data = stream,
                Filename = System.IO.Path.GetFileName(filename),
                ContentType = contentType
            };

            return att;
        }
        public async Task<MessageRespone> SendSmsAs(MessageBase send)
        {
            try
            {
                var timeStamp = (int)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds;
            Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _keyAuth);
            var response = Post<MessageBase, MessageRespone>(_BaseUrls, send);
            if (response != null)
            {
                return await Task.FromResult(response.Item1);
            }

            return await Task.FromResult(new MessageRespone()
            {
                errorNum = response.Item1.errorNum,
                errorDes = response.Item1.errorDes
            });
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                //throw;
                return new MessageRespone { errorNum = 99, errorDes = 1 };
            }
        }
    }
    
}

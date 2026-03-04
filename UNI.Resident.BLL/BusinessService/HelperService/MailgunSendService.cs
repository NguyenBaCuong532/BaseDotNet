using FluentEmail.Core;
using FluentEmail.Mailgun;
using RestSharp;
using RestSharp.Authenticators;
using UNI.Model.Email;
using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace UNI.Resident.BLL.HelperService
{
    public class MailgunSendService
    {
        private readonly string _apiKey;
        private string _domainName;
        private readonly string _baseUrl;

        public MailgunSendService(string domainName, string apiKey, string baseUrl)
        {
            _domainName = domainName;
            _apiKey = apiKey;
            _baseUrl = baseUrl;
        }

        public EmailResponse Send(IFluentEmail email, CancellationToken? token = null)
        {
            return SendAsync(email, token).GetAwaiter().GetResult();
        }
        public void ReDomainName(string fromAdd)
        {
            if (fromAdd.Contains("sunshinegroup.vn"))
            {
                _domainName = "mg.sunshinegroup.vn";
            }
            else if (fromAdd.Contains("unicloudgroup.com.vn"))
            {
                _domainName = "mg.unicloudgroup.com.vn";
            }
            else if (fromAdd.Contains("ksfinance.net"))
            {
                _domainName = "mg.ksfinance.net";
            }
            else
            {
                _domainName = "mg.sunshinemail.vn";
            }    
        }
        public Task<EmailResponse> SendAsync(IFluentEmail email, CancellationToken? token = null, bool sendBatch = false, string id = null)
        {

            var client = new RestClient($"{_baseUrl}/{_domainName}");
            client.Authenticator = new HttpBasicAuthenticator("api", _apiKey);

            var request = new RestRequest("messages", Method.POST);
            request.AddParameter("from", $"{email.Data.FromAddress.Name} <{email.Data.FromAddress.EmailAddress}>");
            email.Data.ToAddresses.ForEach(x => {
                request.AddParameter("to", $"{x.Name} <{x.EmailAddress}>");
            });
            email.Data.CcAddresses.ForEach(x => {
                request.AddParameter("cc", $"{x.Name} <{x.EmailAddress}>");
            });
            email.Data.BccAddresses.ForEach(x => {
                request.AddParameter("bcc", $"{x.Name} <{x.EmailAddress}>");
            });
            request.AddParameter("subject", email.Data.Subject);

            request.AddParameter(email.Data.IsHtml ? "html" : "text", email.Data.Body);
            request.AddParameter("o:tag", id);
            if (!string.IsNullOrEmpty(email.Data.PlaintextAlternativeBody))
            {
                request.AddParameter("text", email.Data.PlaintextAlternativeBody);
            }

            if (email.Data.Attachments.Any())
            {
                request.AlwaysMultipartFormData = true;
            }
            email.Data.Attachments.ForEach(x =>
            {
                request.AddFile("attachment", StreamWriter(x.Data), x.Filename, x.Data.Length, x.ContentType);
            });
            if (sendBatch)
            {
                request.AddParameter("recipient-variables", GetRecipientVariables(email));
            }
            return Task.Run(() =>
            {
                var t = new TaskCompletionSource<EmailResponse>();

                var handle = client.ExecuteAsync<MailgunResponse>(request, response =>
                {
                    var result = new EmailResponse();
                    if (string.IsNullOrEmpty(response.Data.Id))
                    {
                        result.ErrorMessages.Add(response.Data.Message);
                    }
                    result.HttpStatusCode = response.StatusCode;
                    result.MessageId = response.Data.Id;
                    t.TrySetResult(result);
                    
                });

                return t.Task;
            });
        }
        private string GetRecipientVariables(IFluentEmail email)
        {
            var listMail = email.Data.ToAddresses.Select(x => "\"" + x.EmailAddress + "\":\"\"");
            return "{" + string.Join(", ", listMail) + "}";
        }
        private Action<Stream> StreamWriter(Stream stream)
        {
            return s =>
            {
                stream.CopyTo(s);
                stream.Dispose();
            };
        }
    }
}
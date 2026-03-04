using Confluent.Kafka;
using Elastic.Apm;
using FluentEmail.Core;
using FluentEmail.Core.Models;
using FluentEmail.Mailgun;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RestSharp;
using RestSharp.Authenticators;
using UNI.Resident.DAL.Interfaces.Api;
using UNI.Resident.Model.Notification;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM;
using UNI.Model.Email;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories.Api
{
    public class ApiSenderRepository : HttpClientBase, IApiSenderRepository
    {
        protected AppSettings _appSettings;
        private string _sms_baseUrls;
        private string _sms_keyAuth;

        private string _baseUrls;
        private string _domainName;
        private readonly string _mailgun_apiKey;
        private string _fromAddress;
        private string _fromName;
        protected readonly ILogger logger;
        protected readonly IProducer<string, string> kafkaProducer;
        private readonly string _notifyTopic;
        public ApiSenderRepository(IOptions<AppSettings> appSettings, IConfiguration configuration, ILogger<ApiSenderRepository> logger)
        {
            _appSettings = appSettings.Value;
            _domainName = configuration["EmailService:Domain"];
            _mailgun_apiKey = configuration["EmailService:ApiKey"];
            _baseUrls = configuration["EmailService:BaseUrls"];
            _fromAddress = configuration["EmailService:FromAddress"];
            _fromName = configuration["EmailService:FromName"];

            _sms_baseUrls = configuration["SmsService:BaseUrls"];
            _sms_keyAuth = configuration["SmsService:KeyAuth"];

            this.logger = logger;

            var authEnabled = configuration["Kafka:Auth"] == "true";

            var config = new ProducerConfig
            {
                BootstrapServers = configuration["Kafka:ProducerSettings:BootstrapServers"]
            };
            if (authEnabled)
            {
                config.SecurityProtocol = SecurityProtocol.SaslPlaintext;
                config.SaslMechanism = SaslMechanism.ScramSha512;
                config.SaslUsername = configuration["Kafka:ProducerSettings:SaslUsername"];
                config.SaslPassword = configuration["Kafka:ProducerSettings:SaslPassword"];
            }
            _notifyTopic = configuration["Kafka:ProducerSettings:Topics:Notification"];

            kafkaProducer = new ProducerBuilder<string, string>(config)
                .SetKeySerializer(Serializers.Utf8)
                .SetValueSerializer(Serializers.Utf8)
                .SetLogHandler((_, log) => { logger.LogInformation("Producer log: {Log}", log.Message); })
                .SetErrorHandler((_, e) =>
                {
                    Agent.Tracer.CaptureError(e.Reason, e.Reason);
                    logger.LogError("Error: {Reason}", e.Reason);
                })
                .Build();
        }
        public Task<MessageRespone> SendSmsAs(MessageBase send)
        {
            var timeStamp = (int)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds;
            Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _sms_keyAuth);
            var response = Post<MessageBase, MessageRespone>(_sms_baseUrls, send);
            if (response != null)
            {
                return Task.FromResult(response.Item1);
            }

            return Task.FromResult(new MessageRespone()
            {
                errorNum = response.Item1.errorNum,
                errorDes = response.Item1.errorDes
            });
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
            emailModel.Attachs?.ForEach(e => email.Attach(this.FromFilename(e)));
            this.ReDomainName(fromAdd);
            return this.SendAsync(email, sendBatch: true);
        }
        public Attachment FromFilename(string filename, string contentType = null)
        {
            var stream = System.IO.File.OpenRead(filename);
            var att = new Attachment()
            {
                Data = stream,
                Filename = System.IO.Path.GetFileName(filename),
                ContentType = contentType
            };

            return att;
        }


        private Task<EmailResponse> SendAsync(IFluentEmail email, CancellationToken? token = null, bool sendBatch = false)
        {
            var client = new RestClient($"{_baseUrls}/{_domainName}");
            client.Authenticator = new HttpBasicAuthenticator("api", _mailgun_apiKey);

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

        private void ReDomainName(string fromAdd)
        {
            if (fromAdd.Contains("sunshinegroup.vn"))
            {
                _domainName = "mg.sunshinegroup.vn";
            }
            else if (fromAdd.Contains("unicloudgroup.com.vn"))
            {
                _domainName = "mg.unicloudgroup.com.vn";
            }
            else
            {
                _domainName = "mg.sunshinemail.vn";
            }
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

        public async Task<BaseResponse<string>> SendToKafka(string topic, string message)
        {
            try
            {
                // Gửi thông điệp tới Kafka
                var result = await kafkaProducer.ProduceAsync(topic, new Message<string, string>
                {
                    Key = Guid.NewGuid().ToString(),
                    Value = message
                });

                // Kiểm tra trạng thái của kết quả
                if (result.Status != PersistenceStatus.NotPersisted)
                {
                    logger.LogInformation("Delivered content to: {ResultTopicPartitionOffset}", result.TopicPartitionOffset);
                    return new BaseResponse<string>(ApiResult.Success);
                }

                // Nếu trạng thái là NotPersisted
                logger.LogError("Error: {Reason}", result.Status);
                return new BaseResponse<string>(ApiResult.Error, error: result.Status.ToString());
            }
            catch (Exception ex)
            {
                // Bắt lỗi và ghi log
                var error = ex.Message;
                logger.LogError("Error sending to Kafka: {Reason}", error);

                // Có thể gửi lỗi tới hệ thống theo dõi lỗi nếu cần
                //Agent.Tracer.CaptureException(ex);

                return new BaseResponse<string>(ApiResult.Error, error: error);
            }
        }
    }
}

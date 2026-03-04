using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService
{
    public class StorageService : IStorageService
    {
        #region private method
        private const string CON_API_CardPrint = "{0}/api/v1/cardhandler";
        private const string CON_API_StoreContent = "{0}/api/v1/fileHandler/getFileFromHtmlContent";
        private const string CON_API_QrContent = "{0}/api/v1/fileHandler/getFileQRCodeContent";
        private const string CON_API_ServiceBill = "{0}/api/v1/billHandler/createServiceBill";

        protected AppSettings _appSettings;
        protected AuthenticationHeaderValue Authorization { get; set; }
        protected Dictionary<string, string> Headers { get; set; }
        public StorageService(IOptions<AppSettings> appSettings)
        {

            _appSettings = appSettings.Value;
            //var response = RequestToken(Constants.ApiName_Data);
            //Authorization = new AuthenticationHeaderValue("Bearer", response.AccessToken);
        }
        //protected IdentityModel.Client.TokenResponse RequestToken(string scope = null)
        //{
        //    TokenClient tkenClient = new TokenClient(_appSettings.BaseUrls.Auth + BaseHttpConstant.TokenEndpoint,
        //                               clientId: "client",
        //                               clientSecret: "2B9OP51uMh");
        //    return tkenClient.RequestClientCredentialsAsync(scope).Result;
        //}
        protected Tuple<TResult, HttpResponseMessage> Post<TInput, TResult>(string url, TInput input) where TResult : class
        {
            var request = CreateRequest(url, HttpMethod.Post, input);
            return SendRequest<TResult>(request);
        }
        private Tuple<TResult, HttpResponseMessage> SendRequest<TResult>(HttpRequestMessage request, bool ignoreError = false) where TResult : class
        {
            if (request == null || request.Method == null || request.RequestUri == null)
                throw new Exception("Request is incorrect");
            using (var client = CreateClient())
            {
                var response = client.SendAsync(request).Result;
                if (ignoreError || response.IsSuccessStatusCode) return Tuple.Create(response.Content.ReadAs<TResult>(), response);
                return Tuple.Create<TResult, HttpResponseMessage>(null, response);
            }
        }
        protected virtual HttpClient CreateClient()
        {
            var client = new HttpClient();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            if (Authorization != null)
                client.DefaultRequestHeaders.Authorization = Authorization;

            if (Headers != null)
            {
                foreach (var headerItem in Headers)
                {
                    client.DefaultRequestHeaders.Add(headerItem.Key, headerItem.Value);
                }
            }

            return client;
        }
        protected virtual HttpRequestMessage CreateRequest<TInput>(string url, HttpMethod method, TInput input)
        {
            var request = new HttpRequestMessage(method, url)
            {
                Content = input.ToJsonStringContent()
            };

            return request;
        }
        #endregion private method

        //public crmTemplateSet SaveHtmlContent(crmTemplateSet template)
        //{
        //    var htmlCont = new crmStoreHtml { Contents = template.templateContent, tempName = template.templateName, subFolder = "template" };
        //    var url = string.Format(CON_API_StoreContent, _appSettings.BaseUrls.Storage);
        //    var response = Post<crmStoreHtml, BaseResponse<crmStoreHtmlResult>>(url, htmlCont);
        //    if (response.Item1.Data != null)
        //    {
        //        template.templateUrl = response.Item1.Data.templateUrl;
        //    }
        //    return template;
        //}
        //public string SaveQrContent(string qrContent)
        //{
        //    var qrRq = new WalQrContent { Contents = qrContent, Width = 100, Height = 100, subFolder = "template" };
        //    var url = string.Format(CON_API_QrContent, _appSettings.BaseUrls.Storage);
        //    var response = Post<WalQrContent, BaseResponse<string>>(url, qrRq);
        //    if (response.Item1.Data != null)
        //    {
        //        return response.Item1.Data;
        //    }
        //    return null;
        //}
        //public string GeneralQrContent(string qrContent, string filename)
        //{
        //    var qrRq = new WalQrContent { Contents = qrContent, Width = 100, Height = 100, subFolder = @"Uploads\s-cab-qrcode", fileName = filename };
        //    var url = string.Format(CON_API_QrContent, _appSettings.BaseUrls.Storage);
        //    var response = Post<WalQrContent, BaseResponse<string>>(url, qrRq);
        //    if (response.Item1.Data != null)
        //    {
        //        return response.Item1.Data;
        //    }
        //    return null;
        //}
        //public HomBillDataResult SaveServiceBill(HomPaymentGet serviceBill)
        //{
        //    var url = string.Format(CON_API_ServiceBill, _appSettings.BaseUrls.Storage);
        //    var response = Post<HomPaymentGet, BaseResponse<HomBillDataResult>>(url, serviceBill);
        //    if (response.Item1.Data != null)
        //    {
        //        return response.Item1.Data;
        //    }
        //    return null;
        //}
        //public Model.VisitorCard.SalerCardResult VisitorCardsPrint(Model.VisitorCard.SalerCards salercards)
        //{
        //    var url = string.Format(CON_API_CardPrint, _appSettings.BaseUrls.Storage);
        //    var response = Post<SalerCards, BaseResponse<SalerCardResult>>(url, salercards);
        //    return response.Item1.Data;
        //}
    }
}

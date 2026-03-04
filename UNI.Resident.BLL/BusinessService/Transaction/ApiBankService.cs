using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using RestSharp;
using UNI.Resident.BLL.BusinessInterfaces.Transaction;
using System;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.Bank.KLBank;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Transaction
{
    public class ApiBankService : UniBaseService, IApiBankService
    {
        private const string xApiKey = "x-api-key";
        private readonly ksbSettings _ksbSettings;
        private readonly ILogger<ApiBankService> _logger;
        private readonly RestClient _client;
        private readonly string xApiClient = "x-api-client";
        private readonly string xApiValidate = "x-api-validate";
        private readonly string xApiTime = "x-api-time";
        private readonly klbSettings _klbSettings;
        public ApiBankService(ILogger<ApiBankService> logger, IOptions<AppSettings> appSettings, RestClient client)
        {
            _logger = logger;
            _klbSettings = appSettings.Value.Klbank;
            _client = client;
        }

        #region Pay gate KLB
        public klbResponseBase CreateResonse<T>(T data, int code, string mesage)
        {
            // Chuyển đổi đối tượng sang JSON
            string jsonData = JsonConvert.SerializeObject(data);

            // Mã hóa JSON
            string encryptedData = AesCrypto.EncryptAES(jsonData, _klbSettings.encryptKey);

            // Trả về phản hồi
            return new klbResponseBase
            {
                code = code,
                message = mesage,
                data = encryptedData
            };
        }

        public T PaygateAuthenticate<T>(EncryptedBodyRequest requestData)
        {
            try
            {
                if (!_klbSettings.xApiClient.Equals(requestData.ClientId))
                {
                    Console.WriteLine("Invalid paygate client id");
                    throw new InternalException(ResponseCode.INVALID_CLIENT_ID);
                }

                string rawSignature = string.Format("{0}|{1}|{2}", requestData.ClientId, requestData.Timestamp.ToString(), requestData.Data);

                string calculatedSignature = HmacHelper.HmacSHA256Encode(rawSignature, _klbSettings.secretKey);

                if (calculatedSignature.Equals(requestData.Signature))
                {
                    var dasdasds = AesCrypto.EncryptAES(requestData.Data, _klbSettings.encryptKey);
                    var gdgdfgdgdf = JsonConvert.SerializeObject(dasdasds);


                    string decryptedJson = AesCrypto.DecryptAES(requestData.Data, _klbSettings.encryptKey);
                    T requestResult = JsonConvert.DeserializeObject<T>(decryptedJson);

                    Console.WriteLine($"Decrypted Data: {JsonConvert.SerializeObject(requestResult)}");
                    return requestResult;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }

            throw new InternalException(ResponseCode.INVALID_CERTIFICATE);
        }
        #endregion
    }
}
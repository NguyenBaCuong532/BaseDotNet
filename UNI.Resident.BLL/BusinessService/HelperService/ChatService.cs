using UNI.Model;
using UNI.Model.APPM;
using UNI.Utils;
using System.Net.Http.Headers;

namespace UNI.Resident.BLL.HelperService
{
    public class ChatService : HttpClientBase
    {
        private const string CON_API_SetDevice = "{0}/api/v1/device";
        private const string CON_API_SetUser = "{0}/api/v1/user";
        private const string CON_API_DelDevice = "{0}/api/v1/device?deviceCd={1}&deviceType={2}&playerId={3}";
        private const string CON_CHAT_BaseUrl = "http://125.212.202.15:3000";

        public ChatService(AuthenticationHeaderValue auth)
        {
            Authorization = auth;
        }
        public string SetDeviceAsSync(SmartDeviceSync device)
        {
            var url = string.Format(CON_API_SetDevice, CON_CHAT_BaseUrl);
            var response = Post<SmartDeviceSync, BaseResponse<string>>(url, device);
            return response.Item1.Data;
        }
        //public string SetUserAsSync(UserChatSync user)
        //{
        //    var url = string.Format(CON_API_SetUser, CON_CHAT_BaseUrl);
        //    var response = Post<UserChatSync, BaseResponse<string>>(url, user);
        //    return response.Item1.Data;
        //}
        public bool DeleteDeviceAsSync(SmartDevice device)
        {
            var url = string.Format(CON_API_SetDevice, CON_CHAT_BaseUrl);
            var response = Delete(string.Format(CON_API_DelDevice, CON_CHAT_BaseUrl, device.DeviceCd, device.DeviceType, device.playerId));
            return response.IsSuccessStatusCode;
        }
    }
}

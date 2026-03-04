using UNI.Model;
using UNI.Utils;

namespace SSG.Resident.BLL.HelperService
{
    public class PayCallbackService : HttpClientBase
    {
        public string SetPayCallback(WalPayCallback data, string callbackUrl)
        {
            var url = callbackUrl;
            var response = Post<WalPayCallback, BaseResponse<string>>(url, data);
            
            if (response.Item1 == null)
                return null;
            else
                return response.Item1?.Data;
        }
    }
}

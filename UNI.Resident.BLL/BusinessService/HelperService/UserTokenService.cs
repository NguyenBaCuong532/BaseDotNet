using UNI.Resident.Model.UserConfig;
using UNI.Model;
using UNI.Model.Core;
using UNI.Utils;

namespace UNI.Resident.BLL.HelperService
{
    public class UserTokenService : HttpClientBase
    {
        private const string con_fb_get_user = "https://graph.facebook.com/v3.0/me?fields=id,email,name,gender,birthday&access_token={0}";
        private const string con_gg_get_user = "https://www.googleapis.com/oauth2/v1/userinfo?access_token={0}";
        public fbUserProfile GetFbProfile(string token)
        {
            var plUrl = string.Format(con_fb_get_user, token);
            var response1 = Get<fbUserProfile>(plUrl);
            return response1.Item1;
        }
        public ggUserProfile GetGgProfile(string token)
        {
            var plUrl = string.Format(con_gg_get_user, token);
            var response1 = Get<ggUserProfile>(plUrl);
            return response1.Item1;
        }
        
    }
}

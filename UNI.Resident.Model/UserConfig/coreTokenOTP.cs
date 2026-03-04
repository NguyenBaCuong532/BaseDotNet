using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using UNI.Model;

namespace UNI.Resident.Model.UserConfig
{
    public class coreTakeTokenOTPRequest
    {
        public string Phone;

        [Required(ErrorMessage = "BrandName không được trống")]
        public BrandNameSms BrandName;

        [Required(ErrorMessage = "Loại otp không được trống")]
        public TokenType TokenType;
    }

    public class coreTakeTokenOTPResponse
    {
        public string Phone;
    }

    public class coreVerifyTokenOTPRequest
    {
        [Required(ErrorMessage = "Mã otp không được trống")]
        [Description("Mã otp")]
        public string Otp { get; set; }

        [Required(ErrorMessage = "Loại otp không được trống")]
        public TokenType TokenType;
        [Description("Mã sinh otp")]
        public string secret_cd { get; set; }
    }

    public class coreVerifyTokenOTPRequest1
    {
        [Required(ErrorMessage = "Mã User không được trống")]
        [Description("Mã User")]
        public string userId { get; set; }
        [Required(ErrorMessage = "Mã otp không được trống")]
        [Description("Mã otp")]
        public string Otp { get; set; }

        [Required(ErrorMessage = "Loại otp không được trống")]
        public TokenType TokenType;
    }

    public class coreVerifyTokenOTPRespose
    {
    }

    public class coreUserToken
    {
        public int tokenType { get; set; }
        public int mode { get; set; }
        public BaseCtrlClient client { get; set; }
    }
}

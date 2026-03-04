using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM;

namespace UNI.Resident.DAL.Interfaces.Api
{
    public interface IApiKafkaRepository
    {
        Task<BaseResponse<string>> SendToKafka(string topic, string message);
    }
}

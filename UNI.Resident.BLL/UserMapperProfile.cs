using AutoMapper;
using UNI.Model.SMS;
using UNI.Model.SMS.ViewModel;

// For more information on enabling MVC for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860

namespace UNI.Resident.BLL
{
    public class EntityModelMapperProfile : Profile
    {
        public EntityModelMapperProfile()
        {
            CreateMap<SMS, SMSEntity>();
            CreateMap<SMSEntity, SMS>();
            CreateMap<SmsModel, CreateSmsModel>();
        }
    }
}

using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Data;
using System.Net.Http;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.BLL.BusinessInterfaces.Elevator;
using UNI.Resident.BLL.BusinessInterfaces.Invoice;
using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.BLL.BusinessInterfaces.CardVehicle;
using UNI.Resident.BLL.BusinessInterfaces.Advertisement;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.BLL.BusinessService.Apartment;
using UNI.Resident.BLL.BusinessService.Api;
using UNI.Resident.BLL.BusinessService.App;
using UNI.Resident.BLL.BusinessService.Card;
using UNI.Resident.BLL.BusinessService.Elevator;
using UNI.Resident.BLL.BusinessService.Invoice;
using UNI.Resident.BLL.BusinessService.Notify;
using UNI.Resident.BLL.BusinessService.Request;
using UNI.Resident.BLL.BusinessService.CardVehicle;
using UNI.Resident.BLL.BusinessService.Advertisement;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.DAL.Interfaces.Api;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.DAL.Interfaces.Elevator;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.DAL.Interfaces.CardVehicle;
using UNI.Resident.DAL.Interfaces.Advertisement;
using UNI.Resident.DAL.Repositories;
using UNI.Resident.DAL.Repositories.Apartment;
using UNI.Resident.DAL.Repositories.Api;
using UNI.Resident.DAL.Repositories.App;
using UNI.Resident.DAL.Repositories.Card;
using UNI.Resident.DAL.Repositories.Elevator;
using UNI.Resident.DAL.Repositories.Invoice;
using UNI.Resident.DAL.Repositories.Notify;
using UNI.Resident.DAL.Repositories.Request;
using UNI.Resident.DAL.Repositories.CardVehicle;
using UNI.Resident.DAL.Repositories.Advertisement;
using UNI.Resident.DAL.Interfaces.ServicePrice;
using UNI.Resident.DAL.Repositories.ServicePrice;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.BLL.BusinessService.ServicePrice;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.BLL.BusinessService.Settings;
using UNI.Resident.DAL.Interfaces.Settings;
using UNI.Resident.DAL.Repositories.Settings;
using UNI.Resident.BLL.BusinessInterfaces.Employee;
using UNI.Resident.BLL.BusinessService.Employee;
using UNI.Resident.DAL.Interfaces.Employee;
using UNI.Resident.DAL.Repositories.Employee;
using UNI.Utilities.Keycloak.Extensions;

namespace UNI.Resident.API
{
    /// <summary>
    /// Extensions
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        /// <summary>
        /// RegisterServices
        /// </summary>
        /// <param name="services"></param>
        /// <param name="configuration"></param>
        /// <returns></returns>
        public static IServiceCollection RegisterServices(this IServiceCollection services, IConfiguration configuration)
        {
            // and a lot more Services
            services.AddSingleton(configuration);
            var jwtSettings = configuration.GetSection("Jwt");
            services.AddKeyCloakClient(jwtSettings);
            //reposotory
            services.AddScoped<IAppManagerRepository, AppManagerRepository>();
            services.AddScoped<IElevatorBuildingRepository, ElevatorBuildingRepository>();
            services.AddScoped<IElevatorCardRepository, ElevatorCardRepository>();
            services.AddScoped<IElevatorDeviceRepository, ElevatorDeviceRepository>();
            services.AddScoped<IElevatorParamRepository, ElevatorParamRepository>();
            services.AddScoped<IElevatorRepository, ElevatorRepository>();
            services.AddScoped<ICardVehicleExtRepository, CardVehicleExtRepository>();
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<IUserConfigRepository, UserConfigRepository>();
            services.AddScoped<IUIConfigRepository, UIConfigRepository>();
            //services.AddScoped<ISysManageRepository, SysManageRepository>();
            services.AddScoped<ICommonRepository, CommonRepository>();
            services.AddScoped<IFirebaseRepository, FirebaseRepository>();
            services.AddScoped<IAuditRepository, AuditRepository>();
            services.AddScoped<IApartmentRepository, ApartmentRepository>();
            services.AddScoped<IFamilyMemberRepository, FamilyMemberRepository>();
            services.AddScoped<IHouseholdRepository, HouseholdRepository>();
            services.AddScoped<IProjectRepository, ProjectRepository>();
            services.AddScoped<IEmployeeRepository, EmployeeRepository>();
            services.AddScoped<ICardRepository, CardRepository>();
            services.AddScoped<IVehicleRepository, VehicleRepository>();
            services.AddScoped<IRequestRepository, RequestRepository>();
            services.AddScoped<IFeeServiceRepository, FeeServiceRepository>();
            services.AddScoped<IServiceLivingMeterElectricWaterRepository, ServiceLivingMeterElectricWaterRepository>();
            services.AddScoped<IReceiptRepository, ReceiptRepository>();
            services.AddScoped<IElevatorRepository, ElevatorRepository>();
            services.AddScoped<INotifyRepository, NotifyRepository>();
            services.AddScoped<IApiSenderRepository, ApiSenderRepository>();
            services.AddScoped<IApiNotifyRepository, ApiNotifyRepository>();
            services.AddScoped<ITaskRepository, TaskRepository>();
            services.AddScoped<INobleRepository, NobleRepository>();
            services.AddScoped<IMetaRepository, MetaRepository>();

            // Advertisement repositories for Resident CMS
            services.AddScoped<IAdvertisementRepository, AdvertisementRepository>();
            services.AddScoped<IAdvertisementAnalyticsRepository, AdvertisementAnalyticsRepository>();
            //service
            services.AddScoped<IAppManagerService, AppManagerService>();
            services.AddScoped<IElevatorBuildingService, ElevatorBuildingService>();
            services.AddScoped<IElevatorCardService, ElevatorCardService>();
            services.AddScoped<IElevatorDeviceService, ElevatorDeviceService>();
            services.AddScoped<IElevatorParamService, ElevatorParamService>();
            services.AddScoped<IElevatorService, ElevatorService>();
            services.AddScoped<ICardVehicleExtService, CardVehicleExtService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IUserConfigService, UserConfigService>();
            services.AddScoped<IUIConfigService, UIConfigService>();
            //services.AddScoped<ISysManageService, SysManageService>();
            services.AddScoped<ICommonService, CommonService>();
            services.AddScoped<IStorageService, StorageService>();
            services.AddScoped<IAuditService, AuditService>();
            services.AddScoped<IApartmentService, ApartmentService>();
            services.AddScoped<IFamilyMemberService, FamilyMemberService>();
            services.AddScoped<IHouseholdService, HouseholdService>();
            services.AddScoped<IProjectService, ProjectService>();
            services.AddScoped<IEmployeeService, EmployeeService>();
            services.AddScoped<ICardService, CardService>();
            services.AddScoped<IVehicleService, VehicleService>();
            services.AddScoped<IRequestService, RequestService>();
            services.AddScoped<IFeeServiceService, FeeServiceService>();
            services.AddScoped<IServiceLivingMeterElectricWaterService, ServiceLivingMeterElectricWaterService>();
            services.AddScoped<IReceiptService, ReceiptService>();
            services.AddScoped<IAppNotifyService, AppNotifyService>();
            services.AddScoped<INotifyService, NotifyService>();
            services.AddScoped<IApiSenderService, ApiSenderService>();
            services.AddScoped<ITaskService, TaskService>();
            services.AddScoped<INobleService, NobleService>();
            services.AddScoped<IMetaService, MetaService>();

            // Advertisement services for Resident CMS
            services.AddScoped<IAdvertisementService, AdvertisementService>();
            services.AddScoped<IAdvertisementAnalyticsService, AdvertisementAnalyticsService>();

            services.AddTransient<IEmailSender, AuthMessageSender>();
            services.AddTransient<ISmsSender, AuthMessageSender>();
            services.AddTransient<HttpClient>();


            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddControllersWithViews(options =>
            {
                options.Filters.Add(typeof(AuditFilterAttribute));
            });
            services.AddScoped<AuditFilterAttribute>();

            //
            services.AddScoped<ICardPartnerRepository, CardPartnerRepository>();
            services.AddScoped<ICardPartnerService, CardPartnerService>();

            services.AddScoped<ICardBaseRepository, CardBaseRepository>();
            services.AddScoped<ICardBaseService, CardBaseService>();

            services.AddScoped<ICardDailyRepository, CardDailyRepository>();
            services.AddScoped<ICardDailyService, CardDailyService>();
            services.AddScoped<ICardGuestRepository, CardGuestRepository>();
            services.AddScoped<ICardGuestService, CardGuestService>();
            services.AddScoped<ICardInternalRepository, CardInternalRepository>();
            services.AddScoped<ICardInternalService, CardInternalService>();
            services.AddScoped<ICardResidentRepository, CardResidentRepository>();
            services.AddScoped<ICardResidentService, CardResidentService>();

            services.AddScoped<ICardRepository, CardRepository>();
            services.AddScoped<ICardService, CardService>();

            services.AddScoped<IVehicleCardRepository, VehicleCardRepository>();
            services.AddScoped<IVehicleCardService, VehicleCardService>();
            
            services.AddScoped<IVehicleGuestRepository, VehicleGuestRepository>();
            services.AddScoped<IVehicleGuestService, VehicleGuestService>();
            services.AddScoped<IVehicleInternalRepository, VehicleInternalRepository>();
            services.AddScoped<IVehicleInternalService, VehicleInternalService>();
            services.AddScoped<IVehicleResidentRepository, VehicleResidentRepository>();
            services.AddScoped<IVehicleResidentService, VehicleResidentService>();

            services.AddScoped<IAppNotifyService, AppNotifyService>();
            services.AddScoped<IElevatorRepository, ElevatorRepository>();

            services.AddScoped<IInvoiceRepository, InvoiceRepository>();
            services.AddScoped<IInvoiceService, InvoiceService>();

            services.AddScoped<IServiceRepository, ServiceRepository>();
            services.AddScoped<IServiceService, ServiceService>();

            services.AddScoped<IMetaImportRepository, MetaImportRepository>();
            services.AddScoped<IMetaImportService, MetaImportService>();

            // Vehicle Payment
            services.AddScoped<IVehiclePaymentRepository, VehiclePaymentRepository>();
            services.AddScoped<IVehiclePaymentService, VehiclePaymentService>();
            /* Report */
            services.AddScoped<IReportRepository, ReportRepository>();
            services.AddScoped<IReportService, ReportService>();

            var serviceLifetime = ServiceLifetime.Scoped;
            var connectionString = "SHomeConnection";
            var commonFilterStored = "sp_common_filter";
            services.AddScopedUniBaseService(serviceLifetime, connectionString, commonFilterStored);
            services.AddScopedUniBaseService<IResidentCommonBaseRepository, ResidentCommonBaseRepository>(serviceLifetime, connectionString, commonFilterStored);

            AddStorageService(services, configuration);

            return services;
        }

        static void AddStorageService(this IServiceCollection services,
            IConfiguration configuration)
        {
            var storageProvider = configuration["StorageService:Provider"];
            //save storage url to config db
            SetConfigData(configuration.GetConnectionString("SHomeConnection"), "api_storage_url",
               configuration["StorageService:MinIo:ProxyEndpoint"]);
            //map storage service
            if (storageProvider == "MinIo")
            {
                services.AddSingleton<IApiStorageService, ApiMinIoStorageService>(sp =>
                    new ApiMinIoStorageService(
                        sp.GetRequiredService<ILogger<ApiMinIoStorageService>>(),
                        new StorageConfig()
                        {
                            AccessKey = configuration["StorageService:MinIo:AccessKey"],
                            SecretKey = configuration["StorageService:MinIo:SecretKey"],
                            Endpoint = configuration["StorageService:MinIo:Endpoint"],
                            BucketName = configuration["StorageService:MinIo:BucketName"],
                            Region = configuration["StorageService:MinIo:Region"],
                            UseSsl = bool.Parse(configuration["StorageService:MinIo:UseSSL"] ?? "true"),
                            ProxyEndpoint = configuration["StorageService:MinIo:ProxyEndpoint"],
                            PrefixFolder = configuration["StorageService:MinIo:PrefixFolder"]
                        }));
            }
            else
            {
                services.AddSingleton<IApiStorageService, ApiFireBaseStorageService>(sp =>
                    new ApiFireBaseStorageService(
                        sp.GetRequiredService<ILogger<ApiFireBaseStorageService>>(),
                        new StorageConfig()
                        {
                            AccessKey = configuration["StorageService:Firebase:AccessKey"],
                            SecretKey = configuration["StorageService:Firebase:SecretKey"],
                            Endpoint = configuration["StorageService:Firebase:Endpoint"],
                            BucketName = configuration["StorageService:Firebase:BucketName"],
                            Region = configuration["StorageService:Firebase:Region"],
                            UseSsl = bool.Parse(configuration["StorageService:Firebase:UseSSL"] ?? "true"),
                            ProxyEndpoint = configuration["StorageService:Firebase:ProxyEndpoint"],
                            PrefixFolder = configuration["StorageService:Firebase:PrefixFolder"]
                        }));
            }
        }
        private static void SetConfigData(string connectionString, string key, string value)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                connection.Execute("sp_config_data_set", new { key, value }, commandType: CommandType.StoredProcedure);
            }

            return;
        }
    }
}

using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using UNI.Resident.BLL.BusinessService;
using UNI.Resident.BLL.BusinessService.App;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.DAL.Repositories;
using UNI.Resident.DAL.Repositories.App;
using System.Net.Http;
using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.BLL.BusinessService.Notify;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.DAL.Repositories.Notify;
using UNI.Common.CommonBase;

namespace SSG.SupApp.API
{
    /// <summary>
    /// Service
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        /// <summary>
        /// Register
        /// </summary>
        /// <param name="services"></param>
        /// <param name="configuration"></param>
        /// <returns></returns>
        public static IServiceCollection RegisterServices(this IServiceCollection services, IConfiguration configuration)
        {
            // and a lot more Services
            services.AddSingleton(configuration);
            
            services.AddScoped<IAppManagerRepository, AppManagerRepository>();
            services.AddScoped<ISHomeRepository, SHomeRepository>();
            //services.AddScoped<ISPayRepository, SPayRepository>();
            services.AddScoped<IUserAppRepository1, UserAppRepository1>();
            //services.AddScoped<IMarketingRepository, MarketingRepository>();
            services.AddScoped<IFirebaseRepository, FirebaseRepository>();
            //services.AddScoped<INotifyRepository, NotifyRepository>();

            services.AddScoped<IAppManagerService, AppManagerService>();
            services.AddScoped<ISHomeService, SHomeService>();
            //services.AddScoped<ISPayService, SPayService>();
            services.AddScoped<IUserAppService1, UserAppService1>();
            //services.AddScoped<IMarketingService, MarketingService>();
            services.AddScoped<IStorageService, StorageService>();
            //services.AddScoped<INotifyService, NotifyService>();

            services.AddTransient<IEmailSender, AuthMessageSender>();
            services.AddTransient<ISmsSender, AuthMessageSender>();
            services.AddTransient<HttpClient>();

            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            //services.AddScopedUniBaseService(ServiceLifetime.Scoped, "SHomeConnection", "sp_common_filter");
            return services;
        }
    }
}

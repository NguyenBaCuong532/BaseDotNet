using AutoMapper;
using Elastic.Apm.AspNetCore;
using Elastic.Apm.AspNetCore.DiagnosticListener;
using Elastic.Apm.DiagnosticSource;
using Elastic.Apm.Instrumentations.SqlClient;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using NSwag;
using NSwag.AspNetCore;
using NSwag.Generation.Processors.Security;
using Serilog;
using UNI.Resident.BLL;
using System.Collections.Generic;
using UNI.Common;
using UNI.Common.Middleware;
using UNI.Model;

namespace SSG.SupApp.API
{
    /// <summary>
    /// Startup class
    /// </summary>
    public class Startup
    {
        /// <summary>
        /// Startup contructor
        /// </summary>
        /// <param name="env"></param>
        /// <param name="configuration"></param>
        public Startup(IWebHostEnvironment env, IConfiguration configuration)
        {
            Utils.SetEnvironmentVariable(env.IsDevelopment());
            Configuration = configuration;
        }
        /// <summary>
        /// Configuration interface
        /// </summary>
        public IConfiguration Configuration { get; }

        /// <summary>
        /// This method gets called by the runtime. Use this method to add services to the container.
        /// </summary>
        /// <param name="services"></param>
        public void ConfigureServices(IServiceCollection services)
        {
            var userConnectionString = Configuration.GetConnectionString("IdentityUserConnection");

            // Add framework services.
            services.AddDbContext<IdentityDbContext<IdentityUser>>(options =>
            {
                options.UseSqlServer(userConnectionString);
            });

            services.AddIdentity<IdentityUser, IdentityRole>()
                .AddEntityFrameworkStores<IdentityDbContext<IdentityUser>>()
                .AddDefaultTokenProviders();

            services.Configure<IdentityOptions>(options =>
            {
                // Password settings
                options.Password.RequireDigit = false;
                options.Password.RequiredLength = 4;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase = false;
                options.Password.RequireLowercase = false;
            });

            //services.AddScoped<BLL.BusinessService.HelperService.ClientIdCheckFilter>();
            //services.AddMvc();
            services.AddControllers().AddNewtonsoftJson();

            services.AddAuthentication(IdentityServerAuthenticationDefaults.AuthenticationScheme)
                .AddIdentityServerAuthentication(options =>
                {
                    options.Authority = Configuration["AppSettings:BaseUrls:Auth"];
                    options.RequireHttpsMetadata = false;
                    options.ApiName = Constants.ApiName_SupApp;
                });

            services.AddAuthorization(options =>
            {
                ////cust
                //options.AddPolicy(UNIPolicy.SOFF_MAN, policy => policy.RequireClaim(Constants.Permission, UNIApiRoleClaims.CLM_OFF_MAN));
                //options.AddPolicy(UNIPolicy.SOFF_USR, policy => policy.RequireClaim(Constants.Permission, UNIApiRoleClaims.CLM_OFF_USR));
                //options.AddPolicy(UNIPolicy.SOFF_ALL, policy => policy.RequireClaim(Constants.Permission, UNIApiRoleClaims.CLM_OFF_USR, UNIApiRoleClaims.CLM_OFF_MAN));

            });

            services.AddSwaggerDocument(o =>
            {
                o.Title = "Uni Super App API";
                o.AddSecurity("oauth2", new OpenApiSecurityScheme
                {
                    Type = OpenApiSecuritySchemeType.OAuth2,
                    Flow = OpenApiOAuth2Flow.Implicit,
                    Flows = new OpenApiOAuthFlows
                    {
                        Implicit = new OpenApiOAuthFlow
                        {
                            AuthorizationUrl = $"{Configuration["AppSettings:BaseUrls:Auth"] ?? ""}/connect/authorize",
                            TokenUrl = $"{Configuration["AppSettings:BaseUrls:Auth"] ?? ""}/connect/token",
                            Scopes = new Dictionary<string, string> {
                                { Constants.ApiName_SupApp, Constants.ApiName_SupApp },
                            }
                        }
                    }
                });
                o.OperationProcessors.Add(new OperationSecurityScopeProcessor("oauth2"));
            });

            //services.AddSwaggerDocument(o => o.Title = "Sunshine Super App API");
            services.RegisterServices(Configuration);

            var config = new MapperConfiguration(cfg => { cfg.AddProfile(new EntityModelMapperProfile()); });
            services.AddSingleton<IMapper>(sp => config.CreateMapper());

            
            services.Configure<AppSettings>(Configuration.GetSection("AppSettings"));
        }
        /// <summary>
        /// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        /// </summary>
        /// <param name="app"></param>
        /// <param name="env"></param>
        /// <param name="loggerFactory"></param>
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILoggerFactory loggerFactory)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseElasticApm(configuration: Configuration,
                new AspNetCoreDiagnosticSubscriber(),
                new HttpDiagnosticsSubscriber(),
                new SqlClientDiagnosticSubscriber());

            app.UseHttpsRedirection();
            app.UseDefaultFiles();
            app.UseStaticFiles();

            app.UseSerilogRequestLogging();
            loggerFactory.AddFile(Configuration.GetSection("Logging"));

            var apiPrefix = Configuration["AppSettings:ApiPrefix"] ?? "";
            app.UseRouting();
            app.UseOpenApi(
                config => config.PostProcess = (document, request) =>
                {
                    document.BasePath = apiPrefix;
                    if (!env.IsDevelopment())
                    {
                        document.Servers.Clear();
                        document.Servers.Add(new OpenApiServer { Url = Configuration["AppSettings:Server:BaseUrl"] ?? "" });
                    }
                }
            );
            //app.UseSwaggerUi();
            app.UseSwaggerUi(config =>
            {
                config.TransformToExternalPath = (internalUiRoute, request) => apiPrefix + internalUiRoute;
                config.OAuth2Client = new OAuth2ClientSettings
                {
                    ClientId = Configuration["AppSettings:Server:ClientId"] ?? "swagger"
                };
            }
            );

            app.UseCors(builder =>
                builder.AllowAnyOrigin()
                    .AllowAnyHeader()
                    .AllowAnyMethod());
            app.UseAuthentication();
            app.UseAuthorization();
            app.UseMiddleware<ErrorHandlerMiddleware>();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute("api", "api/v{version}/{controller}/{action}/{id?}");
            });
        }
    }
}

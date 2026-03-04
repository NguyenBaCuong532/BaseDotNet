using AutoMapper;
using Elastic.Apm.AspNetCore;
using Elastic.Apm.AspNetCore.DiagnosticListener;
using Elastic.Apm.DiagnosticSource;
using Elastic.Apm.Instrumentations.SqlClient;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using NSwag;
using NSwag.AspNetCore;
using NSwag.Generation.Processors.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using UNI.Common.Middleware;
using UNI.Model;
using UNI.Resident.API.Authorization;
using UNI.Resident.API.BackgroundServices;
using UNI.Resident.BLL;

namespace UNI.Resident.API
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
            UNI.Common.Utils.SetEnvironmentVariable(env.IsDevelopment());
            Configuration = configuration;

            var fireBaseJson = configuration["AppSettings:FirebaseCredential"];
            Common.Utils.SetEnvironmentVariable(fireBaseJson);
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
            services.AddControllers().AddNewtonsoftJson();

            //services.AddAuthentication(IdentityServerAuthenticationDefaults.AuthenticationScheme)
            //    .AddIdentityServerAuthentication(options =>
            //    {
            //        options.Authority = Configuration["AppSettings:BaseUrls:Auth"];
            //        options.RequireHttpsMetadata = false;
            //        options.ApiName = Constants.ApiName_Home;
            //    });

            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.RequireHttpsMetadata = false;
                    options.Authority = Configuration["Jwt:Authority"];
                    options.IncludeErrorDetails = true;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateAudience = true,
                        ValidAudiences = new[] { "account" },
                        ValidateIssuer = true,
                        ValidIssuer = Configuration["Jwt:Authority"],
                        ValidateLifetime = true,
                        RequireExpirationTime = true,
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes("123456"))
                    };
                    options.Events = new JwtBearerEvents
                    {
                        OnTokenValidated = context =>
                        {
                            MapRealmRoles(context);
                            return Task.CompletedTask;
                        }
                    };
                });

            services.AddOpenApiDocument(c =>
            {
                c.Title = "Uni Resident API";
                c.AddSecurity("oauth2", new OpenApiSecurityScheme
                {
                    Type = OpenApiSecuritySchemeType.OAuth2,
                    Flow = OpenApiOAuth2Flow.Implicit,
                    Flows = new OpenApiOAuthFlows
                    {
                        Implicit = new OpenApiOAuthFlow
                        {
                            AuthorizationUrl = Configuration["Jwt:Authority"] + "/protocol/openid-connect/auth",
                            TokenUrl = Configuration["Jwt:Authority"] + "/protocol/openid-connect/token",
                            //AuthorizationUrl = $"{Configuration["AppSettings:BaseUrls:Auth"] ?? ""}/connect/authorize",
                            //TokenUrl = $"{Configuration["AppSettings:BaseUrls:Auth"] ?? ""}/connect/token",
                            Scopes = new Dictionary<string, string> {
                                { Constants.ApiName_Home, Constants.ApiName_Home },
                            }
                        }
                    }
                });

                c.OperationProcessors.Add(new OperationSecurityScopeProcessor("oauth2"));
            });
            //services.AddSwaggerDocument(o => o.Title = "Sunshine Home API");

            services.AddAuthorization(options =>
            {
                //Home
                //options.AddPolicy(UNIPolicy.SHOME_MAN, policy => policy.RequireClaim(Constants.Permission, UNIApiRoleClaims.CLM_HOM_MAN));
                //options.AddPolicy(UNIPolicy.SHOME_USR, policy => policy.RequireClaim(Constants.Permission, UNIApiRoleClaims.CLM_HOM_USR));
                //options.AddPolicy(UNIPolicy.SHOME_ALL, policy => policy.RequireClaim(Constants.Permission, UNIApiRoleClaims.CLM_HOM_USR, UNIApiRoleClaims.CLM_HOM_MAN));

            });

            services.RegisterServices(Configuration);

            // Đăng ký Background Service để xử lý thông báo đã đến lịch gửi
            services.AddHostedService<ScheduledNotificationBackgroundService>();

            services.AddSession(options =>
            {
                options.Cookie.Name = ".HOME.Session";
                // Set a short timeout for easy testing.
                options.IdleTimeout = TimeSpan.FromMinutes(20);
                options.Cookie.HttpOnly = true;
                // Make the session cookie essential
                options.Cookie.SameSite = SameSiteMode.None;
                options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
                options.Cookie.IsEssential = true;
            });

            var config = new MapperConfiguration(cfg => { cfg.AddProfile(new EntityModelMapperProfile()); });
            services.AddSingleton<IMapper>(sp => config.CreateMapper());

            services.Configure<AppSettings>(Configuration.GetSection("AppSettings"));
            services.AddTransient(sp => new RestSharp.RestClient(Configuration["AppSettings:Server:BaseUrl"]));
            services.AddTransient(sp => new RestSharp.RestClient(Configuration["Jwt:Authority"]));

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

            app.UseRouting();
            app.UseOpenApi(
                config => config.PostProcess = (document, request) =>
                {
                    if (!env.IsDevelopment())
                    {
                        document.Servers.Clear();
                        document.Servers.Add(new OpenApiServer { Url = Configuration["AppSettings:Server:BaseUrl"] ?? "" });
                    }
                }
            );
            app.UseSwaggerUi(config =>
            {
                config.OAuth2Client = new OAuth2ClientSettings
                {
                    ClientId = Configuration["Jwt:ClientId"] ?? "swagger_development",
                };
            }
            );

            app.UseCors(builder =>
                builder.AllowAnyOrigin()
                    .AllowAnyHeader()
                    .AllowAnyMethod());
            app.UseAuthentication();
            app.UseAuthorization();
            app.UseSession();
            app.UseMiddleware<ErrorHandlerMiddleware>();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute("api", "api/v{version}/{controller}/{action}/{id?}");
            });
        }
        private static void MapRealmRoles(TokenValidatedContext context)
        {
            if (!(context.Principal.Identity is ClaimsIdentity claimsIdentity)) return;
            var realmAccess = context.Principal.Claims.FirstOrDefault(w => w.Type == "realm_access");
            if (realmAccess == null) return;
            var realmRole = JsonConvert.DeserializeObject<Role>(realmAccess.Value);
            foreach (var role in realmRole.Roles)
            {
                claimsIdentity.AddClaim(new Claim(ClaimTypes.Role, role));
            }
        }
    }
}

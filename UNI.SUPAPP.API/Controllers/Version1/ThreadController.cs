using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.Firestore;
using UNI.Resident.BLL.BusinessInterfaces.App;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// Super App
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 07/02/2020 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/thread/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class ThreadController : SSGController
    {

        private readonly IAppManagerService _appService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ThreadController"/> class.
        /// </summary>
        /// <param name="appService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public ThreadController(
            IAppManagerService appService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _appService = appService;
        }

        #region thread 


        /// <summary>
        /// Set Thread Add
        /// </summary>
        /// <param name="thread"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<fbThread>> SetThreadAdd([FromBody] fbThreadSet thread)
        {
            var result = await _appService.SetThreadAdd(this.UserId, thread);
            return GetResponse<fbThread>(ApiResult.Success, result);
        }
        
        /// <summary>
        /// Delete Agent Project
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetThreadUser([FromBody] fbThreadUserAdd user)
        {
            var result = await _appService.SetThreadUser(this.UserId, user);
            if (result.valid)
                return GetResponse<string>(ApiResult.Success, null);
            else
            {
                var response = GetResponse<string>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        /// <summary>
        /// RemoveThreadUser
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> RemoveThreadUser([FromBody] fbThreadUserAdd user)
        {
            var result = await _appService.DelThreadUser(this.UserId, user);
            if (result.valid)
                return GetResponse<string>(ApiResult.Success, null);
            else
            {
                var response = GetResponse<string>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        
        #endregion agency
    }
}

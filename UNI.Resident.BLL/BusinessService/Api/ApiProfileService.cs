using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.KecloakTemplate.Api;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.DAL.Interfaces.Api;
using User = Keycloak.Net.Models.Users.User;

namespace UNI.Resident.BLL.BusinessService.Api
{
    public class ApiProfileService : IApiProfileService
    {
        private readonly ILogger<ApiProfileService> _logger;
        private readonly IApiProfileRepository _repository;
        public ApiProfileService(IApiProfileRepository repository,
            ILogger<ApiProfileService> logger
            //, IKeycloakAuthService keycloakAuthService, IKeycloakClient keycloakClient
            )
        {
            _logger = logger;
            //_keycloakAuthService = keycloakAuthService;
            //_keycloakClient = keycloakClient;
            _repository = repository;
            //_sendRepository = apiSendRepository;
        }

        public async Task<tplApi<tplUserProfile>> GetUserProfile(string accessToken)
        {
            try
            {
                return await _repository.GetUserProfile(accessToken);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public Task<BaseResponse<List<UserOrgShort>>> GetListEmp(string accessToken, string orgId, string emp_code)
        {
            return _repository.GetListEmp(accessToken, orgId, emp_code);
        }

        public async Task<IEnumerable<User>> GetUsers(string userId, string search, int offset, int size)
        {
            try
            {
                return await _repository.GetUsers(userId, search, offset, size);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        public async Task<bool> AddUser(string userId, User user)
        {
            try
            {
                return await _repository.AddUser(userId, user);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        public async Task<bool> UpdateUser(string userId, User user)
        {
            try
            {
                return await _repository.UpdateUser(userId, user);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        public async Task<User> GetUserById(string id)
        {
            try
            {
                return await _repository.GetUserById(id);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public Task<User> GetUserByUserName(string userName)
        {
            return _repository.GetUserByUserName(userName);
        }
        public async Task<bool> ResetUserPassword(string userId, string password, bool temporary)
        {
            try
            {
                return await _repository.ResetUserPassword(userId, password, temporary);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public Task<bool> DelUser(string userId)
        {
            return _repository.DelUser(userId);
        }
        public Task<bool> SetUserStatus(string userId, bool status)
        {
            return _repository.SetUserStatus(userId, status);
        }
        public Task<bool> AssignRolesToUserAsync(string userId, string roleNamesCsv)
        {
            return _repository.AssignRolesToUserAsync(userId, roleNamesCsv);
        }

        public string CreatePassword(int length)
        {
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
            const string spec = "!@#$%&";
            const string num = "1234567890";
            const string charU = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const string charL = "abcdefghijklmnopqrstuvwxyz";
            StringBuilder res = new StringBuilder();
            Random rnd = new Random();
            res.Append(valid[rnd.Next(valid.Length)]);
            //length--;
            res.Append(num[rnd.Next(num.Length)]);
            //length--;
            res.Append(spec[rnd.Next(spec.Length)]);
            //length--;
            res.Append(valid[rnd.Next(valid.Length)]);
            res.Append(charU[rnd.Next(charU.Length)]);
            //length--;
            res.Append(charL[rnd.Next(charL.Length)]);
            //while (0 < length--)
            //{
            //    res.Append(valid[rnd.Next(valid.Length)]);
            //}
            return res.ToString();
        }
    }
}

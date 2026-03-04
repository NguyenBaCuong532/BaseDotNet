using Keycloak.Net;
using Keycloak.Net.Models.RealmsAdmin;
using Keycloak.Net.Models.Roles;
using Keycloak.Net.Models.Users;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using UNI.Common.Extensions;
using UNI.Model;
using UNI.Model.KecloakTemplate.Api;
using UNI.Resident.DAL.Interfaces.Api;

namespace UNI.Resident.DAL.Repositories.Api
{
    public class ApiProfileRepository : IApiProfileRepository
    {
        private readonly ILogger<ApiProfileRepository> _logger;
        private readonly KeycloakClient _keycloakClient;
        private readonly RestClient _client;
        private readonly string _baseUrl;
        private readonly string _apiKey;

        private readonly string _clientUrl;
        private readonly string _clientId;
        private readonly string _clientSecret;
        private readonly string _clientRealm;
        private readonly bool _useByOrg;
        public ApiProfileRepository(RestClient client, IConfiguration configuration, ILogger<ApiProfileRepository> logger)
        {
            this._logger = logger;
            this._client = client;
            this._clientId = configuration["Jwt:ClientId"];
            this._clientUrl = configuration["Jwt:ClientUrl"];
            this._clientSecret = configuration["Jwt:ClientSecret"];
            this._clientRealm = configuration["Jwt:ClientRealm"];
            this._keycloakClient = new KeycloakClient(this._clientUrl, this._clientSecret, new KeycloakOptions("", this._clientId));
        }

        public async Task<tplApi<tplUserProfile>> GetUserProfile(string accessToken)
        {
            try
            {
                var request = new RestRequest($"{_baseUrl}/api/user/v1/detail");
                request.AddHeader("authorization", $"Bearer {accessToken}");
                var result = await _client.GetApiAsync<tplApi<tplUserProfile>>(request);
                return result.Data;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task<BaseResponse<List<UserOrgShort>>> GetListEmp(string accessToken, string orgId, string emp_code)
        {
            try
            {
                string _baseUrl = this._baseUrl;
                string _xApiKey = this._apiKey;
                var request = new RestRequest($"{_baseUrl}/api/v2/userrole/GetEmpSearch?orgId={orgId}&emp_code={emp_code}&filter={emp_code}");
                request.AddHeader("authorization", $"Bearer {accessToken}");
                request.AddHeader("x-api-key", _xApiKey);
                var result = await _client.GetApiAsync<BaseResponse<List<UserOrgShort>>>(request);

                return result.Data;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                //throw;
                return null;
            }
        }
        //public async Task<UserOrgShort> GetEmployee(string accessToken, string orgId, string emp_code)
        //{
        //    try
        //    {
        //        string _baseUrl = this._baseUrl;
        //        string _xApiKey = this._apiKey;
        //        var request = new RestRequest($"{_baseUrl}/api/v2/userrole/GetEmpSearch?orgId={orgId}&emp_code={emp_code}&filter={emp_code}");
        //        request.AddHeader("authorization", $"Bearer {accessToken}");
        //        request.AddHeader("x-api-key", _xApiKey);
        //        var result = await _client.GetApiAsync<BaseResponse<List<UserOrgShort>>>(request);

        //        return result.Data.Data.FirstOrDefault();
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError($"{ex}");
        //        //throw;
        //        return null;
        //    }
        //}
        /// <summary>
        /// Lấy danh sách người dùng
        /// </summary>
        /// <param name="search"></param>
        /// <param name="offset"></param>
        /// <param name="size"></param>
        /// <returns></returns>
        public async Task<IEnumerable<User>> GetUsers(string userId, string search, int offset, int size)
        {
            try
            {

                var lstUser = await this._keycloakClient.GetUsersAsync(realm: _clientRealm, search: search, first: offset, max: size);
                if (_useByOrg)
                {
                    //var org = this.GetProfile(userId);
                    //if (org != null && org.orgId != null)
                    //{
                    //    return lstUser.Where(u => u.FirstName == org.orgId.ToString());
                    //}
                }
                return lstUser;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        /// <summary>
        /// Thêm người dùng mới
        /// </summary>
        /// <returns></returns>
        public async Task<bool> AddUser(string userId, User user)
        {
            try
            {
                //var org = this.GetProfile(userId);
                //if (_useByOrg)
                //{
                //    if (org != null && org.orgId != null)
                //    {
                //        user.FirstName = org.orgId.ToString();
                //    }
                //}
                var lstUser = await this._keycloakClient.CreateUserAsync(realm: _clientRealm, user: user);
                return lstUser;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        /// <summary>
        /// Cập nhật người dùng
        /// </summary>
        /// <returns></returns>
        public async Task<bool> UpdateUser(string userId, User user)
        {
            try
            {
                var lstUser = await this._keycloakClient.UpdateUserAsync(_clientRealm, userId, user);
                return lstUser;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        /// <summary>
        /// Lấy thông tin user
        /// </summary>
        /// <returns></returns>
        public async Task<User> GetUserById(string id)
        {
            try
            {
                var user = await this._keycloakClient.GetUserAsync(_clientRealm, id);
                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task<User> GetUserByUserName(string loginName)
        {
            try
            {
                var lstUser = await this._keycloakClient.GetUsersAsync(realm: _clientRealm, username: loginName, first: 0, max: 10);
                if (lstUser.Count() >= 1)
                    return lstUser.Where(m => m.UserName.Equals(loginName)).FirstOrDefault();
                else
                    return lstUser.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task<bool> DelUser(string userId)
        {
            return await this._keycloakClient.DeleteUserAsync(_clientRealm, userId);
        }
        /// <summary>
        /// Reset mật khẩu người dùng
        /// </summary>
        /// <returns></returns>
        public async Task<bool> ResetUserPassword(string userId, string password, bool temporary)
        {
            try
            {
                var lstUser = await this._keycloakClient.ResetUserPasswordAsync(_clientRealm, userId, password, temporary);
                return lstUser;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }

        public async Task<bool> SetUserStatus(string id, bool status)
        {
            try
            {
                var user = await this._keycloakClient.GetUserAsync(_clientRealm, id);
                user.Enabled = !status;
                var lstUser = await this._keycloakClient.UpdateUserAsync(_clientRealm, id, user);
                return lstUser;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task<bool> RoleExistsAsync(string roleName)
        {
            try
            {
                var role = await _keycloakClient.GetRoleByNameAsync(_clientRealm, roleName);
                return role != null; // Nếu role tồn tại, trả về true
            }
            catch
            {
                return false; // Nếu không tìm thấy role, trả về false
            }
        }

        public async Task<bool> CreateRealmRolesIfNotExistsAsync(List<string> roleNames)
        {
            if (roleNames == null || roleNames.Count == 0)
            {
                Console.WriteLine("⚠️ Danh sách role rỗng, không có gì để tạo.");
                return false;
            }

            // 1. Lấy danh sách role đã tồn tại trong Keycloak
            var existingRoles = await _keycloakClient.GetRolesAsync(_clientRealm);
            var existingRoleNames = existingRoles.Select(r => r.Name).ToHashSet(); // Đổi thành HashSet để kiểm tra nhanh hơn

            // 2. Lọc ra các role chưa tồn tại
            var newRoles = roleNames
                .Where(roleName => !existingRoleNames.Contains(roleName)) // Chỉ lấy role chưa tồn tại
                .Select(roleName => new Role
                {
                    Name = roleName,
                    Description = $"Auto-created role: {roleName}",
                    Composite = false,
                    ClientRole = false,
                    ContainerId = _clientRealm
                })
                .ToList();

            // 3. Nếu không có role mới để tạo, thông báo và return
            if (newRoles.Count == 0)
            {
                Console.WriteLine("✅ Tất cả các role đã tồn tại. Không cần tạo mới.");
                return false;
            }

            // 4. Tạo từng role mới
            bool success = true;
            foreach (var role in newRoles)
            {
                var result = await _keycloakClient.CreateRoleAsync(_clientRealm, role);
                if (result)
                {
                    Console.WriteLine($"✅ Role '{role.Name}' đã được tạo thành công.");
                }
                else
                {
                    Console.WriteLine($"❌ Lỗi khi tạo role '{role.Name}'.");
                    success = false;
                }
            }

            return success;
        }
        public async Task<bool> AssignRolesToUserAsync(string userId, string roleNamesCsv)
        {
            try
            {
                // 1. Chuyển đổi chuỗi role thành danh sách List<string>
                var roleNames = roleNamesCsv.Split(',').Select(r => r.Trim()).ToList();
                await CreateRealmRolesIfNotExistsAsync(roleNames);
                // 2. Lấy danh sách tất cả các role trong realm
                var roles = await _keycloakClient.GetRolesAsync(_clientRealm);
                if (roles == null || roles.Count() == 0) return false;

                // 3. Lọc danh sách role cần gán
                var rolesToAssign = roles.Where(r => roleNames.Contains(r.Name)).ToList();

                // 4. Gán danh sách role vào user
                var result = await _keycloakClient.AddRealmRoleMappingsToUserAsync(_clientRealm, userId, rolesToAssign);

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                return false;
            }

        }

    }
}

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Account;
using UNI.Model.APPM;

namespace UNI.Resident.BLL.BusinessService
{
    /// <summary>
    /// Class User Service.
    /// <author>Thien TH</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
                //private readonly UserManager<IdentityUser> _userManager;
        
        public UserService(
            IUserRepository userRepository
            //UserManager<IdentityUser> userManager,
            //SignInManager<IdentityUser> signInManager,
            //RoleManager<IdentityRole> roleManager
            )
        {
            if (userRepository != null)
                _userRepository = userRepository;
            //_corUserRepository = suserRepository;
            //if (userManager != null)
            //    _userManager = userManager;
            //if (signInManager != null)
            //    _signInManager = signInManager;
            //if (roleManager != null)
            //    _roleManager = roleManager;

            //_usertokenService = new UserTokenService();
        }
        
        public async Task<UsersInfo> GetUserInfoAsync(string userId)
        {
            return await _userRepository.GetUserInfoAsync(userId);
        }
        public async Task<BaseValidate> SetUserInfoAsync(UsersInfo info)
        {
            return await _userRepository.SetUserInfoAsync(info);
        }
        public async Task<BaseValidate> DeleteUserAsync(string userId)
        {
            return await _userRepository.DeleteUserAsync(userId);
        }
        public async Task<bool> AuthenticateAdminAsync(string userId)
        {
            return await _userRepository.AuthenticateAdminAsync(userId);
        }
        //public async Task<ObjectResult> SetUser(UserSync user)
        //{
        //    var account = await _userManager.FindByNameAsync(user.UserLogin);
        //    if (account != null)
        //    {
        //        user.UserId = account.Id;
        //    }
        //    else
        //    {
        //        var result = await SetCreateAuthenUser(new RegisterUserModel
        //        {
        //            UserName = user.UserLogin,
        //            Email = user.Email,
        //            Password = user.UserPassword,
        //            FullName = user.FullName
        //        });
        //        if (result.StatusCode == 200)
        //        {
        //            user.UserId = result.Value.ToString();
        //        }
        //        else
        //            return new BadRequestObjectResult(result.Value);
        //    }
        //    await _userRepository.SetUser(user);
        //    //await _corUserRepository.SetUser(user);
        //    return new OkObjectResult(user.UserId);
        //}
        
        //public async Task<ObjectResult> ResetPassword(SetUserPassword passwordSet)
        //{
        //    var user = await _userManager.FindByNameAsync(passwordSet.UserLogin);
        //    if (user != null)
        //    {

        //        var token = await _userManager.GeneratePasswordResetTokenAsync(user);
        //        var result = await _userManager.ResetPasswordAsync(user, token, passwordSet.UserPassword);
        //        if (result.Succeeded)
        //        {
        //            Console.WriteLine("======================================================abccccc==hoanpv");
        //            return new OkObjectResult(Constants.StatusSuccess);
        //        }
        //        else
        //        {
        //            Console.WriteLine("========================================================hoanpv11111111");
        //            return new BadRequestObjectResult(result);
        //        }
        //    }
        //    return new BadRequestObjectResult(Constants.Statusfail);
        //}
        //public async Task<IdentityResult> UpdateAsync(IdentityUser user)
        //{
        //    return await _userManager.UpdateAsync(user);
        //}
        //public async Task<IdentityUser> FindUserByName(string userName)
        //{
        //    return await _userManager.FindByNameAsync(userName);
        //}
        //public async Task<IdentityUser> FindUserById(string userId)
        //{
        //    return await _userManager.FindByIdAsync(userId);
        //}
        //public async Task<ObjectResult> SetCreateAuthenRole(string userName, string roler)
        //{
        //    var user = await _userManager.FindByNameAsync(userName);
        //    if (user != null)
        //    {
        //        var roles = await _userManager.GetRolesAsync(user);
        //        if (!roles.Contains(roler))
        //        {
        //            var createURole = await _userManager.AddToRoleAsync(user, roler);
        //            if (createURole.Succeeded || createURole.Errors.FirstOrDefault().Code == "UserAlreadyInRole")
        //            {
        //                return new OkObjectResult(Constants.StatusSuccess);
        //            }
        //            else
        //            {
        //                return new BadRequestObjectResult(Constants.Statusfail);
        //            }
        //        }
        //        else
        //        {
        //            return new OkObjectResult(Constants.StatusSuccess);
        //        }
        //    }
        //    else
        //    {
        //        return new BadRequestObjectResult("User don't exist!");
        //    }
        //}
        //public async Task<ObjectResult> SetCreateAuthenUser(RegisterUserModel user)
        //{
        //    try
        //    {
        //        var newUser = new IdentityUser { UserName = user.UserName, Email = user.Email, NormalizedUserName = user.FullName, PhoneNumber = user.Phone };
        //        var fUser = await _userManager.FindByNameAsync(user.UserName);
        //        if (fUser == null)
        //        {
        //            var createUserResult = await _userManager.CreateAsync(newUser, user.Password);
        //            if (createUserResult.Succeeded)
        //            {
        //                fUser = newUser;
        //                return new OkObjectResult(newUser.Id);
        //            }
        //            else
        //            {
        //                return new BadRequestObjectResult(string.Join(", ", createUserResult.Errors.Select(e => "[" + e.Code + " : " + e.Description + "]")));
        //            }
        //        }
        //        else
        //        {
        //            return new BadRequestObjectResult("User is exist!");
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        
        //public Task<List<FeedbackType>> GetFeedbackType(BaseCtrlClient client)
        //{
        //    return _userRepository.GetFeedbackType(client);
        //}
        
        //public async Task<ResponseList<List<FeedbackGet>>> GetFeedbackList(FilterInputProject filter)
        //{
        //    return await _userRepository.GetFeedbackList(filter);
        //}
        
        public async Task<string> GetUserProject(string userId)
        {
            var cats = await _userRepository.GetUserCategories(true);
            if (cats.Count >= 1)
                return cats.FirstOrDefault();
            else
                return "";
        }
        //public async Task<List<ProjectBase>> GetProjectList(string userId)
        //{
        //    return await _userRepository.GetProjectList(userId);
        //}
        
    }
}

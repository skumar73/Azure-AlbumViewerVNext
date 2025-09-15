using Microsoft.ApplicationInsights;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Westwind.BusinessObjects;

namespace AlbumViewerBusiness
{
    /// <summary>
    /// Account repository used to validate and manage user accounts
    /// </summary>

    public class AccountRepository : EntityFrameworkRepository<AlbumViewerContext,User>
    {

        private readonly TelemetryClient _telemetryClient;

        public AccountRepository(AlbumViewerContext context,
             TelemetryClient telemetryClient)
            : base(context)
        {
            _telemetryClient = telemetryClient;
        }
        
        public async Task<bool> Authenticate(string username, string password)
        {
            // TODO: Do proper password hashing - for now DEMO CODE 
            // var hashedPassword = AppUtils.HashPassword(password);
            var hashedPassword = password;

            var user = await Context.Users.FirstOrDefaultAsync(usr => 
                            usr.Username == username && 
                            usr.Password == hashedPassword);
            if (user == null)
            {
                var properties = new Dictionary<string, string>();
                properties.Add("Authentication for username", username);
                _telemetryClient.TrackEvent("Authentication failed");
                return false;
            }

            _telemetryClient.TrackEvent("Authentication successful");
            return true;
        }

        public async Task<User> AuthenticateAndLoadUser(string username, string password)
        {
            // TODO: Do proper password hashing - for now DEMO CODE 
            // var hashedPassword = AppUtils.HashPassword(password);
            var hashedPassword = password;

            var user = await Context.Users
                          .FirstOrDefaultAsync(usr => usr.Username == username &&
                                                 usr.Password == hashedPassword);
            return user;
        }        
    }
}

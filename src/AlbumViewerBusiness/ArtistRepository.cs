
using Microsoft.ApplicationInsights;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Westwind.BusinessObjects;
using Westwind.Utilities;

namespace AlbumViewerBusiness
{
    public class ArtistRepository : EntityFrameworkRepository<AlbumViewerContext, Artist>
    {

        private readonly TelemetryClient _telemetryClient;
        public ArtistRepository(AlbumViewerContext context,
              TelemetryClient telemetryClient)
            : base(context)
        {
            _telemetryClient = telemetryClient;
        }

        public async Task<List<ArtistWithAlbumCount>> GetAllArtists()
        {
            return await Context.Artists
                .OrderBy(art => art.ArtistName)
                .Select(art => new ArtistWithAlbumCount()
                {
                    ArtistName = art.ArtistName,
                    Description = art.Description,
                    ImageUrl = art.ImageUrl,
                    Id = art.Id,
                    AmazonUrl = art.AmazonUrl,
                    AlbumCount = Context.Albums.Count(alb => alb.ArtistId == art.Id)
                })
                .ToListAsync();
        }

        /// <summary>
        /// Returns a list of albums for a given artist
        /// </summary>
        /// <param name="artistId"></param>
        /// <returns></returns>
        public async Task<List<Album>> GetAlbumsForArtist(int artistId)
        {
            var properties = new Dictionary<string, string>();

            var artist = Context.Artists.FirstOrDefault(x => x.Id == artistId);
            if (artist == null)
            {
                properties.Add("Artist albums lookup:", artist.ArtistName);
                _telemetryClient.TrackEvent("Albums looked up for artist", properties);
            }

            return await Context.Albums
                .Include(a => a.Tracks)
                .Include(a => a.Artist)
                .Where(a => a.ArtistId == artistId)
                .ToListAsync();
        }


        /// <summary>
        /// Artist look up by name - used for auto-complete box returns
        /// </summary>
        /// <param name="search"></param>
        /// <returns></returns>
        public async Task<List<ArtistLookupItem>> ArtistLookup(string search = null)
        {
            if (string.IsNullOrEmpty(search))
                return new List<ArtistLookupItem>();

            var repo = new AlbumRepository(Context, _telemetryClient);

            var term = search.ToLower();
            return await repo.Context.Artists
                .Where(a => a.ArtistName.ToLower().StartsWith(term))
                .Select(a => new ArtistLookupItem
                {
                    name = a.ArtistName,
                    id = a.ArtistName
                })
                .ToListAsync();
        }



        public async Task<bool> DeleteArtist(int id)
        {
            bool result = false;

            var artist = await Context.Artists.FirstOrDefaultAsync(art => art.Id == id);

            // already gone
            if (artist == null)
                return true;

            var albumIds = await Context.Albums.Where(alb => alb.ArtistId == id).Select(alb => alb.Id).ToListAsync();

            var albumRepo = new AlbumRepository(Context, _telemetryClient);

            foreach (var albumId in albumIds)
            {
                // don't run async or we get p
                result = await albumRepo.DeleteAlbum(albumId, noSaveChanges: true);
                if (!result)
                    return false;
            }
            Context.Artists.Remove(artist);
            result = await SaveAsync(); // just save

            if (!result)
                return false;

            return result;
        }

        protected override bool OnValidate(Artist entity)
        {
            if (entity == null)
            {
                ValidationErrors.Add("No artist to validate.");
                return false;
            }

            if (string.IsNullOrEmpty(entity.ArtistName))
                ValidationErrors.Add("Please enter a artist name.", "AritistName");
            else if (string.IsNullOrEmpty(entity.Description) || entity.Description.Length < 30)
                ValidationErrors.Add("Description must be at least 30 characters.", "Description");

            return ValidationErrors.Count == 0;
        }

    }

    public class ArtistLookupItem
    {
        public string name { get; set; }
        public string id { get; set; }
    }
}
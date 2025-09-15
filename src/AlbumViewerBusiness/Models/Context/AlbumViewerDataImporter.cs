using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AlbumViewerBusiness
{

    /// <summary>
    /// This class imports Albums, artists and tracks from the
    /// wwwroot/data/albums.js file which contains all the data
    /// in a single graph.
    /// </summary>
    public  class AlbumViewerDataImporter
    {
        public static bool EnsureAlbumData(AlbumViewerContext context, string jsonDataFilePath)
        {
            bool hasData = false;
            try
            {
                Console.WriteLine($"Checking if Albums table has data...");
                hasData = context.Albums.Any();
                Console.WriteLine($"Albums table has data: {hasData}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking Albums table, creating database schema: {ex.Message}");
                try
                {
                    context.Database.EnsureCreated(); // just create the schema - no migrations
                    Console.WriteLine("Database schema created successfully");
                    hasData = context.Albums.Any();
                    Console.WriteLine($"Albums table has data after schema creation: {hasData}");
                }
                catch (Exception createEx)
                {
                    Console.WriteLine($"Error creating database schema: {createEx.Message}");
                    throw;
                }
            }

            if (!hasData)
            {
                Console.WriteLine($"No data found, importing from: {jsonDataFilePath}");
                if (!System.IO.File.Exists(jsonDataFilePath))
                {
                    Console.WriteLine($"ERROR: Albums data file not found at: {jsonDataFilePath}");
                    return false;
                }
                
                try
                {
                    string json = System.IO.File.ReadAllText(jsonDataFilePath);
                    Console.WriteLine($"Read {json.Length} characters from albums.js");
                    var result = ImportFromJson(context, json) > 0;
                    Console.WriteLine($"Import result: {result}");
                    return result;
                }
                catch (Exception importEx)
                {
                    Console.WriteLine($"Error importing album data: {importEx.Message}");
                    throw;
                }
            }

            Console.WriteLine("Database already has data, skipping import");
            return true;
        }

        /// <summary>
        /// Imports data from json
        /// </summary>
        /// <param name="json"></param>
        /// <returns></returns>
        public static int ImportFromJson(AlbumViewerContext context, string json)
        {
            var albums = JsonConvert.DeserializeObject<Album[]>(json);

            foreach (var album in albums)
            {
                // clear out primary/identity keys so insert works
                album.Id = 0;
                album.ArtistId = 0;
                album.Artist.Id = 0;

                var existingArtist = context.Artists.FirstOrDefault(a => a.ArtistName == album.Artist.ArtistName);
                if (existingArtist == null)
                {
                    context.Artists.Add(album.Artist);
                }
                else
                {
                    album.Artist = existingArtist;
                    album.ArtistId = existingArtist.Id;
                }

                if (album.Tracks != null)
                {
                    foreach (var track in album.Tracks)
                    {
                        track.Id = 0;
                        context.Tracks.Add(track);
                    }
                }
                context.Add(album);

                try
                {
                    context.SaveChanges();
                }
                catch
                {
                    Console.WriteLine("Error adding: " + album.ArtistId);
                }
            }

            var user = new User()
            {
                Username = "test",
                Password = "test",
                Fullname = "Test User",                               
            };
            context.Users.Add(user);
            context.SaveChanges();

            return 1;
        }
    }
}
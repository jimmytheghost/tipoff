using System.Text.Json;
using System.Text.Json.Serialization;

namespace Tipoff.Core;

public sealed class ScheduleCache
{
    private readonly string directory;
    private static readonly JsonSerializerOptions Options = new() { WriteIndented = true, Converters = { new JsonStringEnumConverter() } };

    public ScheduleCache(string? directory = null)
    {
        this.directory = directory ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Tipoff", "Schedules", "Windows");
    }

    public ScheduleSnapshot? Read(DateOnly day, TimeZoneInfo zone, ScheduleGuide guide)
    {
        try
        {
            var snapshot = JsonSerializer.Deserialize<ScheduleSnapshot>(File.ReadAllText(PathFor(day, zone, guide)), Options);
            return snapshot is not null && snapshot.Day == Dates.Key(day) && snapshot.TimeZone == zone.Id && snapshot.Guide == guide ? snapshot : null;
        }
        catch { return null; }
    }

    public void Write(ScheduleSnapshot snapshot)
    {
        Directory.CreateDirectory(directory);
        var destination = PathFor(DateOnly.Parse(snapshot.Day), TimeZoneInfo.FindSystemTimeZoneById(snapshot.TimeZone), snapshot.Guide);
        var temporary = destination + ".tmp";
        File.WriteAllText(temporary, JsonSerializer.Serialize(snapshot, Options));
        File.Move(temporary, destination, true);
        foreach (var file in new DirectoryInfo(directory).GetFiles("*.json").OrderByDescending(file => file.LastWriteTimeUtc).Skip(45))
        {
            try { file.Delete(); } catch { }
        }
    }

    private string PathFor(DateOnly day, TimeZoneInfo zone, ScheduleGuide guide)
    {
        var safeZone = string.Concat(zone.Id.Select(character => Path.GetInvalidFileNameChars().Contains(character) || character is '/' or '\\' ? '_' : character));
        return Path.Combine(directory, $"{guide.ToString().ToLowerInvariant()}-{Dates.Key(day)}-{safeZone}.json");
    }
}

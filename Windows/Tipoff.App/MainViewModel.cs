using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Globalization;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Media;
using Tipoff.Core;

namespace Tipoff.App;

public sealed class MainViewModel : INotifyPropertyChanged, IDisposable
{
    private readonly ScheduleProvider provider = new();
    private readonly ScheduleCache cache = new();
    private CancellationTokenSource? request;
    private ScheduleSnapshot? snapshot;
    private bool refreshing;
    private bool cached;
    private string? error;
    private DateTimeOffset? lastAttempt;

    public event PropertyChangedEventHandler? PropertyChanged;
    public ObservableCollection<GameCard> Games { get; } = [];
    public ScheduleGuide Guide { get; private set; } = ScheduleGuide.Nba;
    public DateOnly SelectedDate { get; private set; } = DateOnly.FromDateTime(DateTime.Now);
    public TimeZoneInfo TimeZone { get; private set; } = TimeZoneInfo.Local;

    public string Tagline => Guide == ScheduleGuide.Nfl ? "Football, with Denver first." : $"Your {Guide.Title()} viewing guide.";
    public string DateTitle => SelectedDate == DateOnly.FromDateTime(DateTime.Now) ? "Today" : SelectedDate.ToString("ddd, MMM d", CultureInfo.CurrentCulture);
    public string DateSubtitle => $"{SelectedDate:MMM d} · local time" + (snapshot is null ? "" : $" · {snapshot.Games.Count} {(snapshot.Games.Count == 1 ? "game" : "games")}");
    public string JumpLabel => Guide == ScheduleGuide.Nfl ? "Sunday" : "Today";
    public Visibility JumpVisibility => ShouldShowJump ? Visibility.Visible : Visibility.Collapsed;
    private bool ShouldShowJump => Guide == ScheduleGuide.Nfl ? SelectedDate.DayOfWeek != DayOfWeek.Sunday : SelectedDate != DateOnly.FromDateTime(DateTime.Now);
    public string Source => snapshot?.Source ?? $"{Guide.Title()} broadcast listings";
    public string Freshness => snapshot is null ? (refreshing ? "Checking the latest listings…" : "Not checked yet") : FormatFreshness(snapshot.FetchedAt, cached);
    public System.Windows.Media.Brush FreshnessBrush => cached || snapshot is { } value && DateTimeOffset.UtcNow - value.FetchedAt > TimeSpan.FromMinutes(10) ? System.Windows.Media.Brushes.DarkOrange : (System.Windows.Media.Brush)new BrushConverter().ConvertFromString("#667078")!;
    public bool CanRefresh => !refreshing;
    public string EmptyMessage => refreshing && snapshot is null ? "Finding the lineup…" : $"No {Guide.Title()} games scheduled.\nCheck the next day’s lineup.";
    public Visibility EmptyVisibility => Games.Count == 0 ? Visibility.Visible : Visibility.Collapsed;
    public string Message => BuildMessage();
    public Visibility MessageVisibility => Message.Length == 0 ? Visibility.Collapsed : Visibility.Visible;

    public async Task OpenedAsync()
    {
        var currentZone = TimeZoneInfo.Local;
        var today = DateOnly.FromDateTime(DateTime.Now);
        if (currentZone.Id != TimeZone.Id) { TimeZone = currentZone; SelectedDate = today; snapshot = null; }
        if (lastAttempt is null || DateTimeOffset.UtcNow - lastAttempt > TimeSpan.FromMinutes(5)) await RefreshAsync();
        else UpdateRelativeTime();
    }

    public async Task SelectGuideAsync(ScheduleGuide guide)
    {
        if (Guide == guide) return;
        Guide = guide;
        snapshot = null;
        Games.Clear();
        NotifyAll();
        await RefreshAsync();
    }

    public async Task MoveDayAsync(int offset)
    {
        SelectedDate = SelectedDate.AddDays(offset);
        snapshot = null;
        Games.Clear();
        NotifyAll();
        await RefreshAsync();
    }

    public async Task JumpAsync()
    {
        var today = DateOnly.FromDateTime(DateTime.Now);
        if (Guide == ScheduleGuide.Nfl)
        {
            var offset = ((int)DayOfWeek.Sunday - (int)today.DayOfWeek + 7) % 7;
            SelectedDate = today.AddDays(offset);
        }
        else SelectedDate = today;
        snapshot = null;
        Games.Clear();
        NotifyAll();
        await RefreshAsync();
    }

    public async Task RefreshAsync()
    {
        request?.Cancel();
        request?.Dispose();
        request = new CancellationTokenSource();
        var token = request.Token;
        lastAttempt = DateTimeOffset.UtcNow;
        error = null;
        if (snapshot is null)
        {
            snapshot = cache.Read(SelectedDate, TimeZone, Guide);
            cached = snapshot is not null;
            ApplySnapshot();
        }
        refreshing = true;
        NotifyAll();
        try
        {
            var result = await provider.LoadAsync(SelectedDate, TimeZone, Guide, token);
            token.ThrowIfCancellationRequested();
            snapshot = result;
            cached = false;
            ApplySnapshot();
            try { cache.Write(result); } catch { error = "Couldn’t save an offline copy."; }
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { return; }
        catch
        {
            cached = snapshot is not null;
            error = snapshot is null ? "Couldn’t load games. Check your connection and try again." : "Refresh failed. Showing saved listings.";
        }
        finally
        {
            if (!token.IsCancellationRequested) { refreshing = false; NotifyAll(); }
        }
    }

    public void UpdateRelativeTime()
    {
        OnPropertyChanged(nameof(Freshness));
        OnPropertyChanged(nameof(FreshnessBrush));
    }

    private void ApplySnapshot()
    {
        Games.Clear();
        if (snapshot is not null)
            foreach (var game in snapshot.DisplayGames) Games.Add(GameCard.From(game, TimeZone));
    }

    private string BuildMessage()
    {
        var messages = new List<string>();
        if (error is not null) messages.Add(error);
        if (snapshot?.LimitedCoverage == true)
            messages.Add(snapshot.Source.StartsWith("ESPN", StringComparison.Ordinal) ? "Using ESPN. Local and streaming listings may be incomplete." : "TV listings may omit streaming options. Check the broadcaster’s schedule.");
        if (Guide == ScheduleGuide.Nba && snapshot?.Games.Any(game => game.IsNuggets) == true)
            messages.Add("Altitude’s personal Nuggets supplement is not yet included in this Windows preview; source listings are shown unchanged.");
        return string.Join(" ", messages);
    }

    private static string FormatFreshness(DateTimeOffset fetchedAt, bool saved)
    {
        var age = DateTimeOffset.UtcNow - fetchedAt;
        var prefix = saved ? "Saved" : "Checked";
        if (age < TimeSpan.FromMinutes(1)) return $"{prefix} just now";
        if (age < TimeSpan.FromHours(1)) return $"{prefix} {(int)age.TotalMinutes}m ago";
        if (age < TimeSpan.FromDays(1)) return $"{prefix} {(int)age.TotalHours}h ago";
        return $"{prefix} {(int)age.TotalDays}d ago";
    }

    private void NotifyAll()
    {
        foreach (var name in new[] { nameof(Tagline), nameof(DateTitle), nameof(DateSubtitle), nameof(JumpLabel), nameof(JumpVisibility), nameof(Source), nameof(Freshness), nameof(FreshnessBrush), nameof(CanRefresh), nameof(EmptyMessage), nameof(EmptyVisibility), nameof(Message), nameof(MessageVisibility) }) OnPropertyChanged(name);
    }

    private void OnPropertyChanged([CallerMemberName] string? name = null) => PropertyChanged?.Invoke(this, new(name));

    public void Dispose()
    {
        request?.Cancel();
        request?.Dispose();
        provider.Dispose();
    }
}

public sealed record GameCard(string Away, string HomeDisplay, string PreferredLabel, string Time, string Notice, string BroadcastText)
{
    public static GameCard From(Game game, TimeZoneInfo zone)
    {
        var video = game.Broadcasts.Where(item => !item.Category.Contains("radio", StringComparison.OrdinalIgnoreCase)).ToList();
        var broadcastText = video.Count == 0 ? "Not listed" : string.Join("\n", video.GroupBy(item => item.Category).Select(group => $"{group.Key.ToUpperInvariant()}\n{string.Join(" / ", group.Select(item => item.Name))}"));
        return new(game.Away, "@ " + game.Home, game.PreferredTeamLabel ?? "", game.TimeLabel(zone), game.Notice ?? "", broadcastText);
    }
}

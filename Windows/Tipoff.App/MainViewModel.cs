using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Globalization;
using System.Runtime.CompilerServices;
using System.Windows;
using Tipoff.Core;

namespace Tipoff.App;

public sealed class MainViewModel : INotifyPropertyChanged, IDisposable
{
    private readonly IScheduleLoading provider;
    private readonly Func<DateTimeOffset> now;
    private readonly Func<TimeZoneInfo> localZone;
    private readonly ScheduleCache cache;
    private CancellationTokenSource? request;
    private ScheduleSnapshot? snapshot;
    private bool refreshing;
    private bool cached;
    private string? error;
    private DateTimeOffset? lastAttempt;
    private bool followsToday = true;

    public MainViewModel(IScheduleLoading? provider = null, ScheduleCache? cache = null,
        Func<DateTimeOffset>? now = null, Func<TimeZoneInfo>? localZone = null)
    {
        this.provider = provider ?? new ScheduleProvider();
        this.cache = cache ?? new ScheduleCache();
        this.now = now ?? (() => DateTimeOffset.UtcNow);
        this.localZone = localZone ?? (() => TimeZoneInfo.Local);
        TimeZone = this.localZone();
        SelectedDate = Today;
    }

    private DateOnly Today => DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(now(), localZone()).DateTime);

    public event PropertyChangedEventHandler? PropertyChanged;
    public ObservableCollection<GameCard> Games { get; } = [];
    public ScheduleGuide Guide { get; private set; } = ScheduleGuide.Nba;
    public DateOnly SelectedDate { get; private set; }
    public TimeZoneInfo TimeZone { get; private set; } = TimeZoneInfo.Local;

    public string DateTitle => SelectedDate == Today ? "Today" : SelectedDate.ToString("ddd, MMM d", CultureInfo.CurrentCulture);
    public string DateSubtitle => $"{SelectedDate:MMM d} · local time" + (snapshot is null ? "" : $" · {snapshot.Games.Count} {(snapshot.Games.Count == 1 ? "game" : "games")}");
    public string JumpLabel => Guide == ScheduleGuide.Nfl ? "Sunday" : "Today";
    public Visibility JumpVisibility => ShouldShowJump ? Visibility.Visible : Visibility.Collapsed;
    private bool ShouldShowJump => Guide == ScheduleGuide.Nfl ? SelectedDate.DayOfWeek != DayOfWeek.Sunday : SelectedDate != Today;
    public string Source => snapshot?.Source ?? $"{Guide.Title()} broadcast listings";
    public string Freshness => snapshot is null ? (refreshing ? "Checking the latest listings…" : "Not checked yet") : FormatFreshness(snapshot.FetchedAt, cached);
    public bool IsFreshnessWarning => cached || snapshot is { } value && now() - value.FetchedAt > TimeSpan.FromMinutes(10);
    public bool CanRefresh => !refreshing;
    public string EmptyMessage => snapshot is not null
        ? $"No {Guide.Title()} games scheduled.\nCheck the next day's lineup."
        : refreshing ? "Finding the lineup..."
        : error is not null ? "Schedule unavailable.\nTry refreshing the listings."
        : "Listings not checked yet.";
    public Visibility EmptyVisibility => Games.Count == 0 ? Visibility.Visible : Visibility.Collapsed;
    public string Message => BuildMessage();
    public Visibility MessageVisibility => Message.Length == 0 ? Visibility.Collapsed : Visibility.Visible;

    public async Task OpenedAsync(bool force = false)
    {
        TimeZoneInfo.ClearCachedData();
        var currentZone = localZone();
        var today = Today;
        if (currentZone.Id != TimeZone.Id || (followsToday && SelectedDate != today))
        {
            TimeZone = currentZone;
            if (followsToday) SelectedDate = today;
            snapshot = null;
            lastAttempt = null;
        }
        if (refreshing && !force && lastAttempt is not null) { UpdateRelativeTime(); return; }
        if (force || lastAttempt is null || now() - lastAttempt > TimeSpan.FromMinutes(5)) await RefreshAsync();
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
        followsToday = SelectedDate == Today;
        snapshot = null;
        Games.Clear();
        NotifyAll();
        await RefreshAsync();
    }

    public async Task JumpAsync()
    {
        var today = Today;
        if (Guide == ScheduleGuide.Nfl)
        {
            var offset = ((int)DayOfWeek.Sunday - (int)today.DayOfWeek + 7) % 7;
            SelectedDate = today.AddDays(offset);
        }
        else SelectedDate = today;
        followsToday = SelectedDate == today;
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
        lastAttempt = now();
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
        catch when (token.IsCancellationRequested) { return; }
        catch
        {
            cached = snapshot is not null;
            error = snapshot is null ? "Couldn’t load games. Check your connection and try again." : "Refresh failed. Showing saved listings.";
        }
        finally
        {
            if (!token.IsCancellationRequested) { refreshing = false; UpdateRelativeTime(); NotifyAll(); }
        }
    }

    public void UpdateRelativeTime()
    {
        foreach (var game in Games) game.UpdateRelativeTime(now());
        OnPropertyChanged(nameof(Freshness));
        OnPropertyChanged(nameof(IsFreshnessWarning));
    }

    private void ApplySnapshot()
    {
        Games.Clear();
        if (snapshot is not null)
            foreach (var game in snapshot.DisplayGames) Games.Add(GameCard.From(game, TimeZone, now()));
    }

    private string BuildMessage()
    {
        var messages = new List<string>();
        if (error is not null) messages.Add(error);
        if (!string.IsNullOrWhiteSpace(snapshot?.AltitudeWarning)) messages.Add(snapshot.AltitudeWarning);
        return string.Join(" ", messages);
    }

    private string FormatFreshness(DateTimeOffset fetchedAt, bool saved)
    {
        var age = now() - fetchedAt;
        var prefix = saved ? "Saved" : "Checked";
        if (age < TimeSpan.FromMinutes(1)) return $"{prefix} just now";
        if (age < TimeSpan.FromHours(1)) return $"{prefix} {(int)age.TotalMinutes}m ago";
        if (age < TimeSpan.FromDays(1)) return $"{prefix} {(int)age.TotalHours}h ago";
        return $"{prefix} {(int)age.TotalDays}d ago";
    }

    private void NotifyAll()
    {
        foreach (var name in new[] { nameof(DateTitle), nameof(DateSubtitle), nameof(JumpLabel), nameof(JumpVisibility), nameof(Source), nameof(Freshness), nameof(IsFreshnessWarning), nameof(CanRefresh), nameof(EmptyMessage), nameof(EmptyVisibility), nameof(Message), nameof(MessageVisibility) }) OnPropertyChanged(name);
    }

    private void OnPropertyChanged([CallerMemberName] string? name = null) => PropertyChanged?.Invoke(this, new(name));

    public void Dispose()
    {
        request?.Cancel();
        request?.Dispose();
        (provider as IDisposable)?.Dispose();
    }
}

public sealed record GameCard(
    string Away,
    string HomeDisplay,
    string PreferredLabel,
    string Time,
    string Notice,
    string BroadcastText,
    Visibility DetailsVisibility,
    string DetailsLabel,
    string DetailsNetworks,
    string DetailsTimes,
    string DetailsNotes,
    string InitialDetailsFreshness) : INotifyPropertyChanged
{
    public event PropertyChangedEventHandler? PropertyChanged;
    public DateTimeOffset? DetailsFetchedAt { get; init; }
    public bool DetailsSaved { get; init; }
    private DateTimeOffset displayTime;
    public bool IsPreferred => PreferredLabel.Length != 0;
    public string DetailsFreshness
    {
        get
        {
            if (DetailsFetchedAt is not { } fetchedAt) return InitialDetailsFreshness;
            var age = displayTime - fetchedAt;
            var ageText = age < TimeSpan.FromMinutes(1) ? "just now" : age < TimeSpan.FromHours(1) ? $"{(int)age.TotalMinutes}m ago" : age < TimeSpan.FromDays(1) ? $"{(int)age.TotalHours}h ago" : $"{(int)age.TotalDays}d ago";
            return $"Altitude schedule · {(DetailsSaved ? "saved" : "checked")} {ageText}";
        }
    }
    public void UpdateRelativeTime(DateTimeOffset now)
    {
        displayTime = now;
        PropertyChanged?.Invoke(this, new(nameof(DetailsFreshness)));
    }

    public Visibility PreferredVisibility => PreferredLabel.Length == 0 ? Visibility.Collapsed : Visibility.Visible;
    public Visibility NoticeVisibility => Notice.Length == 0 ? Visibility.Collapsed : Visibility.Visible;

    public static GameCard From(Game game, TimeZoneInfo zone, DateTimeOffset? now = null)
    {
        var video = game.Broadcasts.Where(item => !item.Category.Contains("radio", StringComparison.OrdinalIgnoreCase)).ToList();
        var broadcastText = video.Count == 0 ? "Not listed" : string.Join("\n", video.GroupBy(item => item.Category).Select(group => $"{group.Key.ToUpperInvariant()}\n{string.Join(" / ", group.Select(item => item.Name))}"));
        if (game.Altitude is not { } details)
            return new(game.Away, "@ " + game.Home, game.PreferredTeamLabel ?? "", game.TimeLabel(zone), game.Notice ?? "", broadcastText,
                Visibility.Collapsed, "Details", "", "", "", "");

        string Local(DateTimeOffset value) => TimeZoneInfo.ConvertTime(value, zone).ToString("h:mm tt", CultureInfo.InvariantCulture);
        var times = new List<string>();
        if (details.Pregame is { } pregame) times.Add($"Pregame {Local(pregame)}");
        if (game.Start is { } start) times.Add($"Game {Local(start)}");
        if (details.Postgame is { } postgame) times.Add($"Postgame {Local(postgame)}");
        var card = new GameCard(game.Away, "@ " + game.Home, game.PreferredTeamLabel ?? "", game.TimeLabel(zone), game.Notice ?? "", broadcastText,
            Visibility.Visible,
            details.Notes.Count == 0 ? "Details" : "Details*",
            details.Networks.Count == 0 ? "No additional network listed" : string.Join(" / ", details.Networks),
            string.Join("  ·  ", times),
            string.Join("\n", details.Notes),
            "") { DetailsFetchedAt = details.FetchedAt, DetailsSaved = details.Saved };
        card.UpdateRelativeTime(now ?? DateTimeOffset.UtcNow);
        return card;
    }
}

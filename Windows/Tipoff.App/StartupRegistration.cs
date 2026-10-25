using Microsoft.Win32;

namespace Tipoff.App;

internal static class StartupRegistration
{
    private const string RunKeyPath = @"Software\Microsoft\Windows\CurrentVersion\Run";
    private const string SettingsKeyPath = @"Software\Tipoff";
    private const string ValueName = "Tipoff";
    private const string ConfiguredValueName = "LaunchAtLogin";

    public static bool IsEnabled
    {
        get
        {
            using var key = Registry.CurrentUser.OpenSubKey(RunKeyPath);
            return key?.GetValue(ValueName) is string value &&
                string.Equals(value, StartupCommand, StringComparison.OrdinalIgnoreCase);
        }
    }

    public static void EnsureDefaultEnabled()
    {
        using var settings = Registry.CurrentUser.CreateSubKey(SettingsKeyPath);
        var configured = settings.GetValue(ConfiguredValueName);
        if (configured is null || configured is int enabled && enabled == 1) SetEnabled(true);
    }

    public static void SetEnabled(bool enabled)
    {
        using var run = Registry.CurrentUser.CreateSubKey(RunKeyPath);
        if (enabled) run.SetValue(ValueName, StartupCommand);
        else run.DeleteValue(ValueName, false);

        using var settings = Registry.CurrentUser.CreateSubKey(SettingsKeyPath);
        settings.SetValue(ConfiguredValueName, enabled ? 1 : 0, RegistryValueKind.DWord);
    }

    private static string StartupCommand => $"\"{Environment.ProcessPath ?? throw new InvalidOperationException("Tipoff could not locate its executable.")}\" --startup";
}

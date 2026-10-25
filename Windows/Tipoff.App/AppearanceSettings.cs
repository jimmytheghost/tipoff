using Microsoft.Win32;
using System.Windows;

namespace Tipoff.App;

internal static class AppearanceSettings
{
    public static string Current { get; private set; } = "Light";

    public static string? Initialize()
    {
        try
        {
            using var settings = Registry.CurrentUser.OpenSubKey(@"Software\Tipoff");
            Apply(settings?.GetValue("Appearance") as string == "Dark" ? "Dark" : "Light");
            return null;
        }
        catch (Exception error) { return $"Could not read appearance settings: {error.Message}"; }
    }

    public static void Set(string appearance)
    {
        if (appearance is not ("Light" or "Dark")) throw new ArgumentOutOfRangeException(nameof(appearance));
        using var settings = Registry.CurrentUser.CreateSubKey(@"Software\Tipoff");
        settings.SetValue("Appearance", appearance);
        Apply(appearance);
    }

    private static void Apply(string appearance)
    {
        var palette = new ResourceDictionary { Source = new Uri($"Themes/{appearance}.xaml", UriKind.Relative) };
        System.Windows.Application.Current.Resources.MergedDictionaries[0] = palette;
        Current = appearance;
    }
}

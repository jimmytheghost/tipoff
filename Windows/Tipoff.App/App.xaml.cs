using System.Drawing;
using System.Windows;
using Forms = System.Windows.Forms;

namespace Tipoff.App;

public partial class App : System.Windows.Application
{
    private Forms.NotifyIcon? trayIcon;
    private MainWindow? flyout;
    private Forms.ToolStripMenuItem? startupItem;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        ShutdownMode = ShutdownMode.OnExplicitShutdown;
        flyout = new MainWindow();
        var inspect = e.Args.Contains("--inspect", StringComparer.OrdinalIgnoreCase);
        var startedWithWindows = e.Args.Contains("--startup", StringComparer.OrdinalIgnoreCase);
        string? startupError = null;
        if (!inspect)
        {
            try { StartupRegistration.EnsureDefaultEnabled(); }
            catch (Exception error) { startupError = error.Message; }
        }
        flyout.AutoHide = !inspect;
        if (inspect)
        {
            flyout.AllowsTransparency = false;
            flyout.WindowStyle = WindowStyle.SingleBorderWindow;
            flyout.ShowInTaskbar = true;
            flyout.Topmost = false;
            flyout.Background = System.Windows.Media.Brushes.White;
        }
        trayIcon = new Forms.NotifyIcon
        {
            Icon = new Icon(System.IO.Path.Combine(AppContext.BaseDirectory, "Tipoff.ico")),
            Text = "Tipoff",
            Visible = true,
            ContextMenuStrip = BuildMenu()
        };
        trayIcon.MouseUp += (_, args) =>
        {
            if (args.Button == Forms.MouseButtons.Left) ToggleFlyout();
        };
        if (!startedWithWindows) ShowFlyout();
        if (startupError is not null)
        {
            trayIcon.ShowBalloonTip(5000, "Tipoff", $"Could not configure Start with Windows: {startupError}", Forms.ToolTipIcon.Warning);
        }
    }

    private Forms.ContextMenuStrip BuildMenu()
    {
        var menu = new Forms.ContextMenuStrip();
        menu.Items.Add("Open Tipoff", null, (_, _) => ShowFlyout());
        menu.Items.Add("Refresh", null, async (_, _) => { if (flyout is not null) await flyout.RefreshAsync(); });
        startupItem = new Forms.ToolStripMenuItem("Start Tipoff with Windows")
        {
            Checked = StartupEnabledSafely(),
            CheckOnClick = true
        };
        startupItem.Click += (_, _) =>
        {
            try { StartupRegistration.SetEnabled(startupItem.Checked); }
            catch (Exception error)
            {
                startupItem.Checked = StartupEnabledSafely();
                trayIcon?.ShowBalloonTip(5000, "Tipoff", $"Could not update Start with Windows: {error.Message}", Forms.ToolTipIcon.Warning);
            }
        };
        menu.Items.Add(startupItem);
        menu.Items.Add(new Forms.ToolStripSeparator());
        menu.Items.Add("Quit", null, (_, _) => flyout?.RequestQuit());
        return menu;
    }

    private static bool StartupEnabledSafely()
    {
        try { return StartupRegistration.IsEnabled; }
        catch { return false; }
    }

    private void ToggleFlyout()
    {
        if (flyout?.IsVisible == true) flyout.Hide(); else ShowFlyout();
    }

    private void ShowFlyout()
    {
        if (flyout is null) return;
        flyout.ShowNearTaskbar();
        flyout.Activate();
        _ = flyout.OpenedAsync();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        if (trayIcon is not null) { trayIcon.Visible = false; trayIcon.Dispose(); }
        flyout?.Dispose();
        base.OnExit(e);
    }
}

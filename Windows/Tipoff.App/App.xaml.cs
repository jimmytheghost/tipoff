using System.Drawing;
using System.Windows;
using Forms = System.Windows.Forms;

namespace Tipoff.App;

public partial class App : System.Windows.Application
{
    private Forms.NotifyIcon? trayIcon;
    private MainWindow? flyout;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        ShutdownMode = ShutdownMode.OnExplicitShutdown;
        flyout = new MainWindow();
        var inspect = e.Args.Contains("--inspect", StringComparer.OrdinalIgnoreCase);
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
            Text = "Tipoff — No scores. Just where to watch.",
            Visible = true,
            ContextMenuStrip = BuildMenu()
        };
        trayIcon.MouseUp += (_, args) =>
        {
            if (args.Button == Forms.MouseButtons.Left) ToggleFlyout();
        };
        ShowFlyout();
    }

    private Forms.ContextMenuStrip BuildMenu()
    {
        var menu = new Forms.ContextMenuStrip();
        menu.Items.Add("Open Tipoff", null, (_, _) => ShowFlyout());
        menu.Items.Add("Refresh", null, async (_, _) => { if (flyout is not null) await flyout.RefreshAsync(); });
        menu.Items.Add(new Forms.ToolStripSeparator());
        menu.Items.Add("Quit", null, (_, _) => flyout?.RequestQuit());
        return menu;
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

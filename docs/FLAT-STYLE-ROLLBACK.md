# Flat-style rollback

The flat pass is enabled by `class="tipoff-flat"` on the body in `web/index.html`. Its overrides are grouped at the end of `web/guide.css`. The original header fills, alternating rows, and brightness rules remain intact.

For a source rollback, remove `tipoff-flat` from the body class and publish the updated HTML through the maintained deployment workflow. No CSS deletion or native app build is needed. The switch was tested locally in both directions.

For a full live rollback, use the guarded rollback for release `tipoff-web-flat-20261107-01`. Its exact command and frozen backup records are in the ignored `.build/website-publication/OPERATIONS.md`. This restores the two files changed by the pass. The source baseline before the pass is commit `5078896`.

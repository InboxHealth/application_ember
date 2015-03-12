# 0.2.0
Upgrade to use the new application cookbook 4.1.6 release and improved symlinking
* Enhancements
  * Ember sub applications sym links now link directly to the release of the application
    they were install alongside instead of whatever was the most "current" base
    application
* Bug Fixes
  * The enhancement of symlinking prevents the entire deploy from failing in
    a non idempotent state.  Previously ember build failures would leave the
    "current" ember distribution unlinked.

# 0.1.0

Initial release of application_ember

* Enhancements
  * an enhancement

* Bug Fixes
  * a bug fix

- Migrated from Flutter 3.22/Dart 3.4 to Flutter 3.38/Dart 3.10
  + Added locally patched plugin `flutter_media_metadata`
  + Added `flutter_dotenv` to work around the removal of `--dart-define-from-file`
  + Updated packages to the newest versions (with actual changes)
  + Updated Android & signing config
- Refactored large portion of the code:
  + Reorganized files
  + Added `BuildContext` extensions: theme, widgets, dialogs
  + Added services for business logics, registered globally with `get_it`
  + Improved widgets: `Input`, `Button`
  + Switched to `dio` from `http`
  + Switched to MVVM: some views/screens have their own view models (will continue migrating)
  + Migrated from `sqflite` to `drift` ORM
- UI/Screen changes:
  + Updated downloader UI & error messages
- Changed dev build activating commit message to match release build
- Added timeout to metadata retrieval, avoiding stalling by corrupted files
- Added/Updated view models for root app & home screen
- Added loading message for initial song data load

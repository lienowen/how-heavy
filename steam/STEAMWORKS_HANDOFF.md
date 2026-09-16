# Steamworks handoff

## Credentials and identifiers required from the publisher

- Steamworks partner account with tax and banking onboarding complete.
- The real App ID and Windows Depot ID.
- A protected beta branch and its access password.
- Steam Guard approval for the upload workstation.

Never commit passwords, session cookies, Steam Guard codes, or publisher API keys.

## Cloud saves

Configure Steam Auto-Cloud for `campaign.json` and `campaign.backup.json` under the Godot user-data folder for product name `The Weight We Carry`. Validate synchronization between two clean Windows accounts before claiming cloud-save support.

## Launch configuration

- Executable: `TheWeightWeCarry.exe`
- Operating system: Windows
- Architecture: 64-bit
- Core game must remain playable when Steam initialization is unavailable.

## Achievement setup

Create all API names listed in `ACHIEVEMENTS.csv` exactly as written. Do not publish hidden or unsupported achievements. Achievement calls must be added only after a real App ID is available and must fail silently offline.

## Upload sequence

1. Replace `APP_ID_REQUIRED` and `DEPOT_ID_REQUIRED` locally; do not commit private account data.
2. Run SteamCMD app build in preview mode.
3. Inspect file mappings and confirm source, QA, legal, and credentials are absent.
4. Upload to the protected beta branch.
5. Install through the Steam client on a clean Windows account.
6. Complete the M5 matrix before promoting any branch.

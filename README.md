# READINESS v1.7.4 beta - SystemDLC Detector

Cheat detection tool for Minecraft servers with 4 scanning modules.

## Features

### [1] Mods Scanner
- Scans all Minecraft mod folders
- Detects suspicious mods and cheats
- Checks multiple launcher installations

### [2] Browser History Scanner
- Analyzes browser history for cheat-related searches
- Supports Chrome, Edge, Firefox, Opera
- Detects cheat download attempts

### [3] Deep System Analysis
- **SRUDB.dat analysis** - detects Python network activity
- **USN Journal** - checks for deletion attempts
- **Prefetch traces** - finds execution history
- **Services check** - detects suspicious services
- **Date-based scoring**: Python active today = CRITICAL (50%), past activity = MEDIUM (15%)
- Uses SrumECmd.exe for forensic analysis

### [4] Alts Scanner (Ban History)
- Parses Minecraft client logs (latest.log + archives)
- Detects banned accounts with full details
- Shows ban date, reason, and who banned
- Filters real bans (ignores VPN kicks)
- Supports custom log paths
- Auto-detects TLauncher, PrismLauncher, MultiMC
- Only scans Minecraft 1.21+ (skips 1.16.5)

## Requirements

- Windows 10/11
- Administrator rights (auto-requests UAC)
- PowerShell 5.1+
- .NET Framework 4.8+

## Installation

### Option 1: Download Release (Recommended)
1. Download `READINESS.exe` from [Releases](../../releases)
2. Right-click → Run as Administrator
3. Done!

### Option 2: Build from Source
1. Install [ps2exe](https://github.com/MScholtes/PS2EXE):
```powershell
Install-Module ps2exe -Scope CurrentUser
```

2. Clone repository:
```bash
git clone https://github.com/YOUR_USERNAME/READINESS.git
cd READINESS
```

3. Compile:
```powershell
Invoke-ps2exe -inputFile "READINESS_FINAL (1).ps1" -outputFile "READINESS.exe" -title "READINESS v1.7.4 beta" -requireAdmin
```

## Usage

1. Run `READINESS.exe` as Administrator
2. Select scan mode (1-4)
3. For Alts Scanner:
   - Press Enter for auto-detection
   - Or enter custom path: `C:\MyMinecraft\logs`
4. View results

## Detection Scoring (Section 3)

| Indicator | Score | Description |
|-----------|-------|-------------|
| Python active TODAY | 50% | Critical - cheat likely running |
| Python past activity | 15% | Medium - past cheat usage |
| SRUDB.dat issues | 20% | Database tampering |
| USN Journal deletion | 10% | Log cleaning attempt |
| Suspicious services | 5% | Background processes |
| Prefetch traces | 5% | Execution history |

**Risk Levels:**
- 0-30%: LOW
- 31-50%: MEDIUM
- 51-70%: HIGH
- 71-100%: CRITICAL

## Supported Paths (Alts Scanner)

**Auto-detected:**
- `%APPDATA%\.minecraft\logs`
- `%APPDATA%\.tlauncher\legacy\Minecraft\game\logs`
- `C:\PulseVisuals\game\logs`
- PrismLauncher instances (1.21+ only)
- MultiMC instances
- Custom launchers

**Custom path:**
Enter your own path when prompted.

## File Structure

```
READINESS/
├── READINESS.exe                      # Compiled executable
├── READINESS_FINAL (1).ps1            # Main source code
├── BACKUP_READINESS_*.ps1             # Backup versions
├── avalanche.exe                      # (External tool)
└── README.md                          # This file
```

## External Dependencies

- **SrumECmd.exe** (Section 3): Must be located at `C:\Avalanche\SrumECmd\SrumECmd.exe`
  - Download from [Eric Zimmerman's Tools](https://ericzimmerman.github.io/)

## Privacy & Security

- All scanning is LOCAL - no data is sent online
- Requires admin rights for system file access
- Error logging is suppressed by default
- No telemetry or tracking

## Troubleshooting

### "Access Denied" errors
- Make sure to run as Administrator
- Right-click READINESS.exe → Run as administrator

### Section 3 not working
- Install SrumECmd.exe to `C:\Avalanche\SrumECmd\`
- Ensure administrator rights are granted

### Alts Scanner shows no bans
- Check if logs exist: `%APPDATA%\.tlauncher\legacy\Minecraft\game\logs`
- Try entering custom path manually
- Ensure Minecraft 1.21+ (1.16.5 is filtered out)

## Development

Built with:
- PowerShell 5.1
- ps2exe for compilation
- .NET compression for .gz log parsing

## License

This project is for educational and server moderation purposes only.

## Credits

- Created by: IwTu
- Version: 1.7.4 beta
- SrumECmd by Eric Zimmerman

## Changelog

### v1.7.4 beta
- Added Alts Scanner (Section 4)
- Client-side Minecraft log parsing
- Custom path support
- TLauncher/PrismLauncher auto-detection
- Ban history with full details

### v1.7.3
- Deep System Analysis with SRUDB.dat
- Date-based Python detection scoring
- Prefetch trace analysis

### v1.7.2
- Browser history scanner
- Multi-browser support

### v1.7.1
- Initial mods scanner
- Basic cheat detection

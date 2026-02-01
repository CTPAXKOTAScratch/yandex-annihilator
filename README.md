🧨 Yandex Nuker

PowerShell script to completely remove Yandex bloatware, spyware, and autostart components from Windows. Born from frustration with pre-installed OEM garbage that phones home without consent.

⚠️ Warning
Permanently deletes Yandex Browser and all its data

Administrator rights required

Backup important data before running

Use at your own risk

🚀 Quick Start
Download nuke-yandex.ps1

Right-click → "Run with PowerShell"

Type YES then NUKE when prompted (double confirmation)

Let the script run (takes 30-60 seconds)

Reboot when finished

🔧 What It Removes
Component	Status	Description
Processes	✅	Kills all running Yandex processes
Services	✅	Stops & disables Yandex background services
Scheduled Tasks	✅	Removes auto-repair and update tasks
Registry	✅	Cleans autostart and configuration entries
Folders	✅	Deletes all Yandex program files and data
Start Menu	✅	Removes shortcuts and pinned tiles
Browser	✅	Uninstalls Yandex Browser completely
Music/Other Apps	✅	Removes Yandex Music and related software
📋 Features
Double confirmation system (YES + NUKE) – no accidental runs

Automatic admin elevation – runs with proper privileges

Step-by-step execution – shows what's being removed in real-time

Verification scan – confirms complete removal at the end

Clean exit – recommends reboot and waits for keypress

UTF-8 encoded – no corrupted symbols in console

🖥️ Requirements
Windows 10 or 11 (tested on both)

PowerShell 5.1+ (included with Windows)

Administrator rights (script auto-elevates)

🐛 Known Issues & Limitations
May not remove OEM-level Yandex installations (factory recovery partitions)

Some antivirus may flag as "potentially unwanted program" (PUP) – it's not

If Yandex was installed via Microsoft Store, remnants may remain in WindowsApps folder

📁 File Structure
text
yandex-nuker/
├── nuke-yandex.ps1     # Main removal script
├── README.md          # This file
└── LICENSE           # MIT License
🔍 How It Works
The script performs a surgical strike on Yandex's persistence mechanisms:

Kills processes – Stops anything running

Disables services – Prevents auto-repair

Removes tasks – Deletes scheduled resurrection jobs

Cleans registry – Removes autostart entries

Uninstalls software – Proper removal via Windows Installer

Deletes folders – Obliterates leftover files

Cleans Start Menu – Removes shortcuts and pins

❓ FAQ
🤔 Will this break my Windows?
No. The script only targets Yandex components. Windows system files are untouched.

🔄 Can I recover Yandex after running this?
No. This is permanent removal. If you need Yandex Browser again, reinstall from yandex.com.

🛡️ Is this safe?
Yes. The script is open-source – you can review every line. It only removes Yandex files and registry entries. No internet calls, no data collection.

💻 What about my mom's work extensions?
Migrate first. If someone needs Yandex for work extensions, help them switch to Chrome/Edge equivalents before running this script.

⏱️ How long does it take?
About 30-60 seconds depending on system speed.

📄 License
MIT License - see LICENSE file for details.

Free to use, modify, and distribute. Attribution appreciated but not required.

🙏 Credits
Born from genuine frustration with pre-installed OEM bloatware. Made for everyone who wants their PC to actually be theirs.

🐛 Reporting Issues
Found a bug? Yandex found a new persistence method?

Check if it's already reported in Issues

Create a new issue with:

Windows version

What happened vs what you expected

Any error messages shown

🤝 Contributing
Improvements welcome! Especially:

Better detection methods

Support for non-Russian language systems

GUI version

Additional bloatware targets

💻 Made with frustration, tested with vengeance. Reclaim your PC.

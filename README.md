# WordPress XAMPP Installer for Arch Linux

<!-- Add screenshot here -->

A WordPress installer for Arch Linux using XAMPP. Because apparently setting up a local dev environment is rocket science for some people.

## What This Does

Installs WordPress on Arch Linux using XAMPP. That's it. No magic, no bullshit, just straight-up functionality for people who can't be bothered to do it manually.

### What You Get:
- A working WordPress installation (shocking, I know)
- Automatic dependency management (because reading package lists is hard)
- Smart detection of existing installations (no more "already installed" errors)
- Your needs*

### What You Don't Get:
- Automatic database creation (that's your job, genius)
- Automatic wp-config.php setup (learn to configure things yourself)
- Hand-holding through every step (this isn't Windows)
- Support for non-standard XAMPP installations (stick to the defaults)
- Magic fixes for broken MySQL configurations (learn to debug)

## Requirements

Before you even think about running this:

- Arch Linux (obviously, it's in the fucking title)
- Internet connection (for downloading stuff, duh)
- sudo privileges (don't be a scrub)
- Basic terminal knowledge (if you can't use a terminal, maybe stick to Windows)
- Optional: AUR helper (yay, paru, pikaur, or aurman) - if you don't have one, the script will install yay for you

## Installation

### Quick Install (For the Impatient)

```bash
bash <(curl -s https://raw.githubusercontent.com/DuckB1t/duckpress/main/install.sh)
```

### Manual Install (For the Paranoid)

1. Clone this repository:
```bash
git clone https://github.com/DuckB1t/duckpress.git
cd duckpress
```

2. Make the script executable (or it won't work, genius):
```bash
chmod +x install.sh
```

3. Run the installer:
```bash
./install.sh
```

## Usage

### Installation Modes

Pick your poison:

1. Interactive Mode (Default):
   - CLI prompts for user input
   - Allows customization of site folder
   - For people who like to have control

2. Headless Mode:
   - No user interaction
   - Uses default values
   - For automation nerds and lazy fucks

### Command Line Options

```bash
--headless   # Run without prompts (for the brave souls)
```

## Uninstallation

Fucked something up and want to start over? Here's how to nuke everything:

### 1. Stop XAMPP Services
```bash
sudo /opt/lampp/lampp stop
```

### 2. Remove Everything (Nuclear Option)
```bash
# Remove XAMPP package (if installed via AUR)
yay -R xampp
# or
paru -R xampp

# Remove XAMPP directory (this removes WordPress files and databases too)
sudo rm -rf /opt/lampp
```

### 3. Clean Up Processes (If Stuck)
```bash
# Kill any remaining XAMPP processes
sudo pkill -f httpd
sudo pkill -f mysqld
sudo pkill -f proftpd
```

## XAMPP Control

After installation, here's how to control XAMPP (because you'll need to know this shit):

```bash
# Start XAMPP
sudo /opt/lampp/lampp start

# Stop XAMPP
sudo /opt/lampp/lampp stop

# Restart XAMPP (when things inevitably break)
sudo /opt/lampp/lampp restart
```

## Troubleshooting

### Port Conflicts

If you see a port conflict error (because of course something else is using port 80):
1. The script will detect if ports 80 or 443 are in use
2. You can choose to stop the conflicting service
3. If you're still having issues, check what's hogging those ports:
```bash
sudo lsof -i :80
sudo lsof -i :443
```

### Permission Issues

If you get permission errors (classic Linux experience):
1. Make sure you're running the script with sudo (duh!)
2. Check if XAMPP is properly installed
3. If you're still having issues, check the permissions:
```bash
ls -la /opt/lampp/htdocs/
```

### Manual Uninstall Issues

**Can't find XAMPP:**
- Check if installed: `ls -la /opt/lampp`
- Check AUR package: `yay -Qi xampp` or `paru -Qi xampp`

**Permission denied:**
- Use sudo for system directories: `sudo rm -rf /opt/lampp`
- Check file ownership: `ls -la /opt/lampp/htdocs/`

**Stuck processes:**
- Kill XAMPP processes manually: `sudo pkill -f httpd && sudo pkill -f mysqld`
- If MySQL won't start, try: `sudo /opt/lampp/lampp restart`

**Database removal fails:**
- List databases: `/opt/lampp/bin/mysql -u root -e "SHOW DATABASES;"`
- Check if MySQL is running: `pgrep mysqld`
- Start MySQL: `sudo /opt/lampp/lampp startmysql`

## Contributing

Found a bug? Want to make this script less shitty? Great!

1. Fork this repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License. Do whatever the fuck you want with it.

## Acknowledgments

- WordPress team for making a decent CMS
- Apache Friends for XAMPP (even though it's bloated as hell)
- Arch Linux community for being elitist pricks (in a good way)

---

## Disclaimer

This script is made for real humans, not some corporate bullshit. Use this script to flex in front of your crush, impress your nerd friends, or just because you're too lazy to set up WordPress manually.

If you break your system using this script, that's on you. We're not responsible for your incompetence or your inability to read documentation.

BTW I use Arch. 😎 (not cringe.. ik yk)

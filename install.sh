#!/bin/bash

# WordPress XAMPP Installer for Arch Linux

# Default values
HEADLESS_MODE=false
SITE_FOLDER="wordpress"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --headless)
            HEADLESS_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check for AUR helpers
check_aur_helper() {
    local aur_helpers=("yay" "paru" "pikaur" "aurman")
    for helper in "${aur_helpers[@]}"; do
        if command_exists "$helper"; then
            echo "$helper"
            return 0
        fi
    done
    return 1
}

# Function to install AUR helper (yay)
install_aur_helper() {
    info_msg "Installing yay AUR helper..."
    
    # Install required dependencies
    sudo pacman -S --needed --noconfirm git base-devel || error_exit "Failed to install dependencies for yay"
    
    # Clone yay repository
    git clone https://aur.archlinux.org/yay.git /tmp/yay || error_exit "Failed to clone yay repository"
    
    # Build and install yay
    cd /tmp/yay || error_exit "Failed to change to yay directory"
    makepkg -si --noconfirm || error_exit "Failed to build and install yay"
    
    # Clean up
    cd - > /dev/null
    rm -rf /tmp/yay
    
    echo "yay"
}

# Function to check if a port is in use
check_port() {
    local port=$1
    if command_exists netstat; then
        netstat -tuln | grep -q ":$port "
        return $?
    elif command_exists ss; then
        ss -tuln | grep -q ":$port "
        return $?
    fi
    return 1
}

# Function to display error and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Function to display success message
success_msg() {
    echo "$1"
}

# Function to display info message
info_msg() {
    echo "$1"
}

# Function to display warning message
warning_msg() {
    echo "$1"
}

# Function to check and install dependencies
install_dependencies() {
    info_msg "Checking and installing dependencies..."
    
    local deps=("curl" "unzip")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        warning_msg "Installing missing dependencies: ${missing_deps[*]}"
        sudo pacman -S --noconfirm "${missing_deps[@]}" || error_exit "Failed to install dependencies"
    fi
}

# Function to check XAMPP installation
check_xampp() {
    if [ -d "/opt/lampp" ]; then
        warning_msg "XAMPP is already installed at /opt/lampp"
        read -p "Do you want to reinstall XAMPP? (y/n): " reinstall
        [[ $reinstall =~ ^[Yy]$ ]] || return 1
        # Remove existing XAMPP
        sudo pacman -R --noconfirm xampp || error_exit "Failed to remove existing XAMPP"
    fi
    return 0
}

# Function to install XAMPP using AUR helper
install_xampp() {
    info_msg "Installing XAMPP..."
    
    # Check for AUR helper
    local aur_helper
    aur_helper=$(check_aur_helper)
    
    if [ -z "$aur_helper" ]; then
        info_msg "No AUR helper found. Installing yay..."
        aur_helper=$(install_aur_helper)
    fi
    
    # Install XAMPP using the AUR helper
    info_msg "Installing XAMPP using $aur_helper..."
    "$aur_helper" -S --noconfirm xampp || error_exit "Failed to install XAMPP"
    
    # Start XAMPP services
    sudo /opt/lampp/lampp start || error_exit "Failed to start XAMPP services"
}

# Function to check port conflicts
check_port_conflicts() {
    local ports=("80" "443")
    local conflicts=()
    
    for port in "${ports[@]}"; do
        if check_port "$port"; then
            conflicts+=("$port")
        fi
    done
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        warning_msg "Port conflicts detected on ports: ${conflicts[*]}"
        read -p "Do you want to stop the conflicting services? (y/n): " stop_services
        [[ $stop_services =~ ^[Yy]$ ]] || error_exit "Please free up the required ports and try again"
        
        for port in "${conflicts[@]}"; do
            sudo fuser -k "$port"/tcp
        done
    fi
}

# Function to get user input
get_user_input() {
    read -p "Enter site folder name (default: wordpress): " SITE_FOLDER
    SITE_FOLDER=${SITE_FOLDER:-wordpress}
}

# Function to download and configure WordPress
install_wordpress() {
    info_msg "Downloading WordPress..."
    curl -L "https://wordpress.org/latest.zip" -o wordpress.zip || error_exit "Failed to download WordPress"
    
    info_msg "Extracting WordPress..."
    # First remove any existing WordPress directory
    sudo rm -rf /opt/lampp/htdocs/wordpress
    sudo unzip -o wordpress.zip -d /opt/lampp/htdocs/ || error_exit "Failed to extract WordPress"
    
    # If site folder is not "wordpress", move it to the desired name
    if [ "$SITE_FOLDER" != "wordpress" ]; then
        info_msg "Moving WordPress to $SITE_FOLDER..."
        sudo rm -rf "/opt/lampp/htdocs/$SITE_FOLDER"
        sudo mv /opt/lampp/htdocs/wordpress "/opt/lampp/htdocs/$SITE_FOLDER" || error_exit "Failed to move WordPress files"
    fi
    
    # Set proper permissions
    sudo chown -R daemon:daemon "/opt/lampp/htdocs/$SITE_FOLDER"
    sudo chmod -R 755 "/opt/lampp/htdocs/$SITE_FOLDER"
    
    # Clean up
    rm wordpress.zip
}

# Function to display completion message
show_completion() {
    echo
    echo "WordPress Installation Complete!"
    echo
    echo "Site Path: /opt/lampp/htdocs/$SITE_FOLDER"
    echo "Access at: http://localhost/$SITE_FOLDER"
    echo
    echo "Next Steps:"
    echo "1. Create a MySQL database"
    echo "2. Configure wp-config.php"
    echo "3. Run the WordPress installation wizard"
    echo
    
    # Show XAMPP control instructions
    echo "XAMPP Control Commands:"
    echo "Start:   sudo /opt/lampp/lampp start"
    echo "Stop:    sudo /opt/lampp/lampp stop"
    echo "Restart: sudo /opt/lampp/lampp restart"
}

# Main installation process
main() {
    echo "WordPress XAMPP Installer for Arch Linux"
    echo
    
    # Check and install dependencies
    install_dependencies
    
    # Check port conflicts
    check_port_conflicts
    
    # Check and install XAMPP
    if check_xampp; then
        install_xampp
    fi
    
    # Get user input if not in headless mode
    if [ "$HEADLESS_MODE" = false ]; then
        get_user_input
    fi
    
    # Install WordPress
    install_wordpress
    
    # Show completion message
    show_completion
}

# Run main function
main 
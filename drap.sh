#!/bin/bash
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
CYAN='\e[96m'
RESET="\e[0m"
CURRENT_OS_DOWNLOAD_CMD=""

OWNER_NAME=$(whoami)

clear

banner() {
    clear
    
    
    local term_width
    term_width=$(tput cols)
    
    # Top Border
    printf '%*s\n' "$term_width" '' | tr ' ' '='
    
    # DRAP ASCII Title
    echo -e "${GREEN}"
    echo "  ____   ____  _____   ___  "
    echo " |  _ \ |  _ \| ____| / _ \ "
    echo " | | | || | | |  _|  | | | |"
    echo " | |_| || |_| | |___ | |_| |"
    echo " |____/ |____/|_____| \___/     Drap"
    echo -e "${RESET}"
    
    # Subtitle Centered
    subtitle="Universal Packages Downloader" 
    padding=$(( (term_width - ${#subtitle}) / 2 ))
    printf "%*s%s\n" "$padding" "" "$subtitle"
    
    # Separator Line
    echo -e "${CYAN}──────────────────────────────────────────────────────────────${RESET}"
    
    # Description
    echo -e "${CYAN}A cross-distro intelligent tool downloader${RESET}"
    echo -e "${CYAN}Supports: apt, pacman, dnf, yum, zypper, apk, nix, flatpak, snap${RESET}"
    
    # Author Box
    echo -e "\n${YELLOW}Author: ${RESET} Gaurav Mahajan"
    echo -e "${YELLOW}──────────────────────────────────────────────────────────────${RESET}"
    echo -e "${YELLOW}│││${RESET} Welcome back ${YELLOW}${OWNER_NAME}${RESET}                                         "
    echo -e "${YELLOW}──────────────────────────────────────────────────────────────${RESET}"
    
    
    # Brief Intro
    echo -e "\n${CYAN}Drap: A smart, cross-distro installer framework —"
    echo -e "   Auto-detects your package manager and installs tools via:"
    echo -e "   apt, pacman, dnf, yum, zypper, apk, nix, flatpak, or snap.${RESET}"
    
    # Final Message
    echo -e "${GREEN}.............................................."
    echo -e "${GREEN}: Drap — One command. Any distro. Every tool :${RESET}"
    echo -e "${GREEN}.............................................."
    echo -e "\nContribute or report bugs on GitHub to help improve Drap."
    # GitHub Link
    echo -e "${YELLOW}GitHub Repo:${RESET} https://github.com/mahajang214/drap"
        
    
    # Simulate loading
    echo
    if command -v pv &>/dev/null; then
        echo "Initializing Drap... " | pv -qL 10
    else
        echo -e "${BLUE}Initializing Drap... ${RESET}"
        sleep 1
    fi
    
    echo
}

check_OS(){
    OS=$(uname -s)
    case $OS in
        Linux*)
            echo "Linux OS is detected"
            if command -v apt-get &>/dev/null; then
                CURRENT_OS_DOWNLOAD_CMD="apt-get"
                
                elif command -v pacman &>/dev/null; then
                # install_packages "sudo pacman -S --noconfirm"
                CURRENT_OS_DOWNLOAD_CMD="pacman"
                
                elif command -v dnf &>/dev/null; then
                # install_packages "sudo dnf install -y"
                CURRENT_OS_DOWNLOAD_CMD="dnf"
                
                elif command -v yum &>/dev/null; then
                # install_packages "sudo yum install -y"
                CURRENT_OS_DOWNLOAD_CMD="yum"
                
                elif command -v zypper &>/dev/null; then
                # install_packages "sudo zypper install -y"
                CURRENT_OS_DOWNLOAD_CMD="zypper"
                
                elif command -v apk &>/dev/null; then
                # install_packages "sudo apk add"
                CURRENT_OS_DOWNLOAD_CMD="apk"
                
                elif command -v nix-env &>/dev/null; then
                # install_packages "nix-env -iA nixpkgs"
                CURRENT_OS_DOWNLOAD_CMD="nix-env"
                
            else
                echo -e "\e[91m✘ Unsupported Linux distro or missing package manager.\e[0m"
                exit 1
            fi
            
        ;;
        Darwin*)
            echo -e "\e[92mDetected macOS\e[0m"
            if command -v brew &>/dev/null; then
                # install_packages "brew install"
                CURRENT_OS_DOWNLOAD_CMD="brew"
            else
                echo -e "\e[91mHomebrew not found. Please install Homebrew.\e[0m"
            fi
            
        ;;
        *)
            echo -e "${RED}Error: your operating system does not support drap. $RESET"
        ;;
    esac
    
    
}
bye(){
    term_width=$(tput cols)
    echo -e "\e[91m"
    printf '%*s\n' "$term_width" '' | tr ' ' '-'
    echo -e "\tBye..."
    printf '%*s\n' "$term_width" '' | tr ' ' '-'
    echo -e "$RESET"
    exit 1;
}
download_tool(){
    
    if [[ -z "$CURRENT_OS_DOWNLOAD_CMD" ]]; then
        echo -e "${RED}Error : cannot detect operating system. $RESET"
        bye
    fi
    
    install_with_flatpak_or_snap() {
        local tool="$1"
        
        if command -v flatpak &>/dev/null; then
            echo -e "${YELLOW}Trying Flatpak for $tool...$RESET"
            sudo flatpak install -y flathub "$tool"
            elif command -v snap &>/dev/null; then
            echo -e "${YELLOW}Trying Snap for $tool...$RESET"
            sudo snap install "$tool"
        else
            echo -e "${RED}Flatpak and Snap not found. Installing Flatpak...$RESET"
            case "$CURRENT_OS_DOWNLOAD_CMD" in
                apt-get) sudo apt install -y flatpak ;;
                pacman) sudo pacman -Sy flatpak --noconfirm ;;
                dnf) sudo dnf install -y flatpak ;;
                yum) sudo yum install -y flatpak ;;
                zypper) sudo zypper install -y flatpak ;;
                apk) sudo apk add flatpak ;;
                nix-env) sudo nix-env -iA nixpkgs.flatpak ;;
            esac
            
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            sudo flatpak install -y flathub "$tool"
        fi
    }
    
    
    for tool in "$@"; do
        echo -e "${BLUE}Installing $tool...$RESET"
        
        # Skip if already installed
        if command -v "$tool" &>/dev/null; then
            echo -e "${GREEN}$tool is already installed.$RESET"
            continue
        fi
        
        # Native install based on detected package manager
        case "$CURRENT_OS_DOWNLOAD_CMD" in
            apt-get) sudo apt-get install -y "$tool" ;;
            pacman) sudo pacman -Sy "$tool" --noconfirm ;;
            dnf) sudo dnf install -y "$tool" ;;
            yum) sudo yum install -y "$tool" ;;
            zypper) sudo zypper install -y "$tool" ;;
            apk) sudo apk add "$tool" ;;
            nix-env) sudo nix-env -iA nixpkgs."$tool" ;;
        esac
        
        # Check again; fallback if needed
        if ! command -v "$tool" &>/dev/null; then
            install_with_flatpak_or_snap "$tool"
        else
            echo -e "${GREEN}$tool successfully installed.$RESET"
        fi
    done
    
}

uninstall_tool(){
    if [[ -z "$CURRENT_OS_DOWNLOAD_CMD" ]]; then
        echo -e "${RED}Error : cannot detect operating system. $RESET"
        bye
    fi
    
    for tool in "$@"; do
        echo -e "${BLUE}Uninstalling $tool...$RESET"
        
        # Check if tool is installed
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${YELLOW}$tool is not installed.$RESET"
            exit 1;
        fi
        
        # Uninstall based on package manager
        case "$CURRENT_OS_DOWNLOAD_CMD" in
            apt-get) sudo apt-get remove --purge -y "$tool" ;;
            pacman) sudo pacman -Rns --noconfirm "$tool" ;;
            dnf) sudo dnf remove -y "$tool" ;;
            yum) sudo yum remove -y "$tool" ;;
            zypper) sudo zypper remove -y "$tool" ;;
            apk) sudo apk del "$tool" ;;
            nix-env) sudo nix-env -e "$tool" ;;
        esac
        
        echo -e "${GREEN}$tool successfully uninstalled.$RESET"
    done
}

update_tool(){
    if [[ -z "$CURRENT_OS_DOWNLOAD_CMD" ]]; then
        echo -e "${RED}Error : cannot detect operating system. $RESET"
        bye
    fi
    
    for tool in "$@"; do
        echo -e "${BLUE}Updating $tool...$RESET"
        
        # Check if tool is installed
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${YELLOW}$tool is not installed.$RESET"
            exit 1;
        fi
        
        # Update based on package manager
        case "$CURRENT_OS_DOWNLOAD_CMD" in
            apt-get) sudo apt-get update && sudo apt-get install --only-upgrade -y "$tool" ;;
            pacman) sudo pacman -Syu --noconfirm "$tool" ;;
            dnf) sudo dnf upgrade -y "$tool" ;;
            yum) sudo yum update -y "$tool" ;;
            zypper) sudo zypper refresh && sudo zypper update -y "$tool" ;;
            apk) sudo apk upgrade "$tool" ;;
            nix-env) sudo nix-env -uA nixpkgs."$tool" ;;
        esac
        
        echo -e "${GREEN}$tool successfully updated.$RESET"
    done
}

#usage download_tool figlet toilet
check_OS
download_tool figlet
banner
sleep 1s;


echo -e "${YELLOW}You can also choose to install, uninstall or update tools.${RESET}"
select purpose in "install" "uninstall" "update"; do
    case $purpose in
        install)
            echo -e "${GREEN}Tools you want to install in your system."
            read -p "Enter tool names (space-separated): " tool_list

            # Convert string into array
            IFS=' ' read -r -a tools <<< "$tool_list"
            echo -e "${GREEN}\nInstalling tools..."
            # Loop over array correctly
            for tool in "${tools[@]}"; do
                echo "Tool: $tool"
                download_tool "$tool"
            done
            break
            ;;
        uninstall)
            echo -e "${GREEN}Tools you want to uninstall from your system."
            read -p "Enter tool names (space-separated): " tool_list

            # Convert string into array
            IFS=' ' read -r -a tools <<< "$tool_list"
            echo -e "${RED}Uninstalling tools...$RESET"
            uninstall_tool "${tools[@]}"
            exit 0
            ;;
        update)
            echo -e "${GREEN}Tools you want to update in your system."
            read -p "Enter tool names (space-separated): " tool_list

            # Convert string into array
            IFS=' ' read -r -a tools <<< "$tool_list"
            echo -e "${BLUE}Updating tools...$RESET"
            update_tool "${tools[@]}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting...$RESET"
            exit 1
            ;;
    esac
done


# download_tool bat
echo -e "${GREEN}Successful... $RESET"
bye


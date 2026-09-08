    #!/bin/bash
    
    #This simply contains things i install on Linux Mint at first
    
    apt install micro cpupower-gui steam codeblocks gparted clamav clamtk btop htop -y

	echo "Installing Warehouse (GUI to manage Flatpak apps)"
	flatpak install flathub io.github.flattool.Warehouse -y

	echo "Installing Flatseal (GUI to manage Flatpak apps permissions)"
	flatpak install flathub com.github.tchx84.Flatseal -y

	echo "Installing Bottles (App to run windows programs)"
	flatpak install flathub com.usebottles.bottles -y

	echo "Installing LACT (GPU Underclocking/Power Throtteling or Overclocking)"
	flatpak install flathub io.github.ilya_zlobintsev.LACT -y

	echo "Installing CPU-X (Shows CPU/GPU model and specs + other PC info)"
	flatpak install flathub io.github.thetumultuousunicornofdarkness.cpu-x -y

	echo "Installing ZapZap (Whatsapp)"
	flatpak install flathub com.rtosta.zapzap -y

	echo "Installing Discord"
	flatpak install flathub com.discordapp.Discord -y

	echo "Installing VLC (Video Player)"
	flatpak install flathub org.videolan.VLC -y

	echo "Installing Parabolic (Previously Known as TubeConverter, allows downloading of youtube videos as MP4 or MP3)"
	flatpak install flathub org.nickvision.tubeconverter -y

	echo "Installing OBS (Desktop Recording)"
	flatpak flatpak install flathub com.obsproject.Studio -y

	echo "Installing Krita (Drawing)"
	flatpak install flathub org.kde.krita -y

	echo "Installing Kdenlive (Video Editing)"
	flatpak install flathub org.kde.kdenlive -y

	echo "Installing Gimp (Image Editing)"
	flatpak install flathub org.gimp.GIMP -y

	echo "Installing Thunderbird (Email)"
	flatpak install flathub org.mozilla.Thunderbird -y

	echo "Installing Inkscape (Image Editing)"
	flatpak install flathub org.inkscape.Inkscape -y

	echo "Installing Remmina (Remote Desktop + SSH)"
	flatpak install flathub org.remmina.Remmina -y

	echo "Installing ProtonUpQT"
	flatpak install flathub net.davidotek.pupgui2 -y

    echo "Installing ProtonPlus"
	flatpak install flathub com.vysp3r.ProtonPlus -y

	echo "Installing ProtonTricks (Allows adding extra libraries that might not be present in Proton)"
	flatpak install flathub com.github.Matoking.protontricks -y

	echo "Installing Steam Link"
	flatpak install flathub com.valvesoftware.SteamLink -y

	echo "Installing MangoHud (Performance Overlay)"
	flatpak install flathub mangohud -y

	echo "Installing Heroic Games Launcher (Epic, GOG, Amazon Games)"
	flatpak install flathub com.heroicgameslauncher.hgl -y

	echo "Installing Lutris (Ubisoft, EA, Itch.Io, emulation)"
	flatpak install flathub net.lutris.Lutris -y

	echo "Installing Prism Launcher (Premium Minecraft Launcher, based on MultiMC)"
	flatpak install flathub org.prismlauncher.PrismLauncher -y

	echo "Installing Space Cadet Pinball (Windows XP classic pinball game)"
	flatpak install flathub com.github.k4zmu2a.spacecadetpinball -y

	echo "Installing Sober (Roblox Player Launcher)"
	flatpak install flathub org.vinegarhq.Sober -y

	echo "Installing Vinegar (Roblox Studio Launcher)"
	flatpak install flathub org.vinegarhq.Vinegar -y

	echo "A restart might be needed for installed apps to show"
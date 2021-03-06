#!/bin/bash

# Install prerequisites (supervisor xvfb fluxbox x11vnc websockify)
# Redirect stdout to null
install_prerequisites() {
    sudo apt-get update
    sudo apt-get install -y supervisor xvfb fluxbox x11vnc websockify
}


#Request sudo permissions
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Check prerequisites

declare -a NEEDED_SOFTWARE_LIST=(supervisord xvfb-run fluxbox x11vnc websockify)
for SOFTWARE in ${NEEDED_SOFTWARE_LIST[@]} ; do
    $SOFTWARE --version |& grep "command not found" && (
        install_prerequisites;
      );
done

#Clone noVNC into proper /opt/ directory
echo "Cloning noVNC..."
echo

{
    git clone git://github.com/kanaka/noVNC /opt/noVNC/
}&> /dev/null

#Copy supervisord configuration to proper configuration directory
echo "Configuring supervisord..."
echo
mkdir -p /home/ubuntu/.config/
cp supervisord.conf /home/ubuntu/.config/supervisord.conf

#Make sure that the runners folder exists
echo "Installing C9 runner..."
echo

mkdir -p /home/ubuntu/workspace/.c9/runners

#Copy the C9 runner to the C9 watch folder
\cp c9vnc.run /home/ubuntu/workspace/.c9/runners/c9vnc.run

#Create the proper directory for the script
echo "Install run script..."
echo

sudo mkdir -p /opt/c9vnc

#Copy the run script to proper /opt/ directory
sudo \cp run.sh /opt/c9vnc/c9vnc.sh

#Copy the uninstall script to proper /opt/ directory
sudo \cp uninstall.sh /opt/c9vnc/uninstall.sh

#Symlink script
{
    ln -s /opt/c9vnc/c9vnc.sh /usr/local/bin/c9vnc
}&> /dev/null

#Export X11 Settings
echo "Configuring X11"
echo

mkdir -p /tmp/X11
echo export XDG_RUNTIME_DIR=/tmp/C9VNC >> ~/.bashrc
echo export DISPLAY=:99.0 >> ~/.bashrc
source ~/.bashrc

# sudo x11vnc -storepasswd ; sed -i -e 's/command=x11vnc/command=x11vnc -usepw/g' ${HOME}/.config/supervisord.conf ; sudo chmod go+r ~/.vnc/passwd 

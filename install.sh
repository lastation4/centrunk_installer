#!/bin/bash

##### VARIABLE ASSIGNMENT #####
##### DO NOT CHANGE THESE #####

BASE_DIR='/opt'
GIT_URL='https://github.com/DVMProject/dvmhost.git'
INSTALL_LOC='/opt/dvm'
CONFIG_DIR='/opt/dvm/configs'
FW_GIT_URL='https://github.com/DVMProject/dvmfirmware-hs.git'
FW_TOOLS_F10X='https://github.com/DVMProject/STM32F10X_Platform.git'
FW_TOOLS_F4='https://github.com/DVMProject/STM32F4XX_Platform.git'
CONFIG_REPO='https://github.com/lastation4/centrunk-default-config.git'
DEBUG=1

##### FUNCTION DEFINITIONS #####

clean_environment()
{
    if [[ $DEBUG -eq 0 ]]
    then
        rm -rf $INSTALL_LOC
        rm -rf /opt/dvm-firmware/
        write_log_event "Cleaned install directory $INSTALL_LOC."
    fi
}

write_log_event()
{
    echo $(date +"%Y-%m-%d_%H-%M-%S")": $1" >> /var/log/centrunk_install.log
}

replace_config()
{
    write_log_event "Starting configuration file reconfiguration!"
    sed -i "s/EQUIP_ID/$EQUIP_ID/g" $1
    sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $1
    sed -i "s/RCON_PORT/$RCON_PORT/g" $1
    sed -i "s/PATH_TO_MODEM/${PATH_TO_MODEM//\//\\/}/g" $1
    sed -i "s/CHANNEL_ID/$CID/g" $1
    sed -i "s/RFSS_ID/$RFSS_ID/g" $1
    sed -i "s/SITE_ID/$SITE_ID/g" $1
    sed -i "s/SYS_ID/$SYS_ID/g" $1
    sed -i "s/NET_ID/$NET_ID/g" $1
    sed -i "s/NAC_CODE/$NAC_CODE/g" $1
    sed -i "s/SUPER_GROUP/$SUPER_GROUP/g" $1
    sed -i "s/CHANNEL_NUMBER/$CHID/g" $1
    sed -i "s/VCN/$VCN/g" $1
    # this is sed'd in for "security"
    sed -i "s/REDACTED/CENTRUNK/g" $1
    sed -i "s/P_CENTRUNK/62030/g" $1
    write_log_event "Done replacing default values in config."
}

usage()
{
    echo "centrunk_installer 
    --voice|--control|--voc 
    --id <EQUIP_ID> 
    --ip <IP_ADDRESS> 
    --rcon <RCON_PORT>
    --uart <PATH_TO_MODEM>
    --channel <UHF|VHF|800|700|900>
    --rfss <RFSS_ID>
    --site <SITE_ID>  
    --sys <SYS_ID>
    --net <NET_ID>
    --nac <NAC_CODE>
    --atg <SUPER_GROUP>
    [--flash]
    --zt <ZEROTIER_ID>
    --chid <CHANNEL_NUMBER>
    --vcn <VOICE_CHANNEL_NUMBER>
    --help
    "
}

echo "Welcome to the Centrunk Installer." 
echo "The options you selected are as follows: "
write_log_event "Beginning installation..."

##### VARIABLE ASSIGNMENT #####

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --zt)
      ZEROTIER=$2
      shift
      shift
      ;;
    --flash)
      FLASH=1
      shift
      ;;
    --voice)
      TYPE=VOICE
      shift # past argument
      ;;
    --control)
      TYPE=CONTROL
      shift # past argument
      ;;
    --voc)
      TYPE=VOC
      shift
      ;;
    --id)
      EQUIP_ID="$2"
      shift
      shift
      ;;
    --ip)
      IP_ADDRESS="$2"
      shift
      shift
      ;;
    --rcon)
      RCON_PORT="$2"
      shift
      shift
      ;;
    --uart)
      PATH_TO_MODEM="$2"
      shift
      shift
      ;;
    --channel)
      case $2 in
        UHF)
          CID=2
          ;;
        VHF)
          CID=3
          ;;
        800)
          CID=0
          ;;
        700)
          CID=1
          ;;
        900)
          CID=15
          ;;
        *)
          usage
          exit 1
          ;;
      esac
      shift
      shift
      ;;
    --rfss)
      RFSS_ID="$2"
      shift
      shift
      ;;
    --site)
      SITE_ID="$2"
      shift
      shift
      ;;
    --sys)
      SYS_ID="$2"
      shift
      shift
      ;;
    --net)
      NET_ID="$2"
      shift
      shift
      ;;
    --nac)
      NAC_CODE="$2"
      shift
      shift
      ;;
    --atg)
      SUPER_GROUP="$2"
      shift
      shift
      ;;
    --chid)
      CHID="$2"
      shift
      shift
      ;;
    --vcn)
      VCN="$2"
      shift
      shift
      ;;
    --help)
      usage
      exit 1
      ;;
    -*|--*)
      usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done


echo \
"TYPE=$TYPE
ZT=$ZEROTIER
EQUIP_ID=$EQUIP_ID
IP_ADDRESS=$IP_ADDRESS
RCON_PORT=$RCON_PORT
UART=$PATH_TO_MODEM
CHANNEL=$CID
RFSS_ID=$RFSS_ID
SITE_ID=$SITE_ID
SYS_ID=$SYS_ID
NET_ID=$NET_ID
NAC=$NAC_CODE
ATG=$SUPER_GROUP
FLASH=$FLASH
CHANNELID=$CHID
VOICECHANNEL=$VCN"

write_log_event \
"TYPE=$TYPE\n
ZT=$ZEROTIER\n
EQUIP_ID=$EQUIP_ID\n
IP_ADDRESS=$IP_ADDRESS\n
RCON_PORT=$RCON_PORT\n
UART=$PATH_TO_MODEM\n
CHANNEL=$CID\n
RFSS_ID=$RFSS_ID\n
SITE_ID=$SITE_ID\n
SYS_ID=$SYS_ID\n
NET_ID=$NET_ID\n
NAC=$NAC_CODE\n
ATG=$SUPER_GROUP\n
FLASH=$FLASH\n\n
CHANNELID=$CHID
VOICECHANNEL=$VCN"



read -p "Are these values correct? [Y/N]: " resp2

case $resp2 in
    Y | y)
      write_log_event "User has elected to continue."
      ;;
    N | n)
      write_log_event "User has elected to exit."
      exit 96
      ;;
    *)
      write_log_event "Invalid entry, displaying help to user."
      usage
      exit 96
      ;;
esac
##### /VARIABLES #####

##### DVM BLOCK #####

write_log_event "Actually starting the install now!"


clean_environment

cd $BASE_DIR

write_log_event "Cloning DVMhost from GitHub..."
git clone $GIT_URL $INSTALL_LOC

cd $INSTALL_LOC

#build the boi

write_log_event "Building dvmhost..."
echo "Building DVMhost...this may take some time..."
make

#fixup perms
write_log_event "Permissions updating..."
chmod +x start-dvm.sh stop-dvm.sh dvm-watchdog.sh stop-watchdog.sh

#install default configs from git

write_log_event "Checking out default configurations from GitHub..."
git clone $CONFIG_REPO $CONFIG_DIR

#handle config based on responsess

case $TYPE in
    VOICE)
      cp $CONFIG_DIR/ct-vc.yml $INSTALL_LOC/config.centrunk.yml
      replace_config "$INSTALL_LOC/config.centrunk.yml"
      ;;
    CONTROL)
      cp $CONFIG_DIR/ct-cc-dedicated.yml $INSTALL_LOC/config.centrunk.yml
      replace_config "$INSTALL_LOC/config.centrunk.yml"
      ;;
    VOC)
      cp $CONFIG_DIR/ct-voc.yml $INSTALL_LOC/config.centrunk.yml
      replace_config "$INSTALL_LOC/config.centrunk.yml"
      ;;
    *)
      write_log_event "User has somehow gotten to a place they shouldn't. See code, line 279."
      echo "How did you get here?"
      exit 69
      ;;
esac


#install the unit file

write_log_event "Installing the P25 systemd Service..."
cp $CONFIG_DIR/p25.service /etc/systemd/system/p25.service
write_log_event "Updating permissions on the Service..."
chmod 664 /etc/systemd/system/p25.service
systemctl daemon-reload

#output commands
write_log_event "!!!DVMhost install completed.!!!"
echo "Done installing DVMhost."

# ollie outie if we aren't flashing
if [[ $FLASH -ne 1 ]]
then
    write_log_event "Not flashing the modem per user input...Quitting..."
    echo "Not flashing the modem...exiting..."
    exit 0
else
    write_log_event "Flashing the modem."
    echo "Flashing the modem. Please standby while we gather some files..."    
fi

write_log_event "Entering the Firmware Block..."
###### FIRMWARE BLOCK #####
#clone out the firmware and tools
write_log_event "Cloning firmware from GitHub..."
cd /opt
git clone $FW_GIT_URL
cd /opt/dvmfirmware-hs/
git clone $FW_TOOLS_F10X

write_log_event "Starting the firmware build process..."
#build the firmware
echo "Building the firmware in 5 seconds..."
sleep 5
make -f Makefile.STM32FX mmdvm-hs-hat-dual
write_log_event "Firmware build completed!"

#flash the firmware
write_log_event "About to flash the firmware...asking for consent..."
read -p "FLASHING THE FIRMWARE NOW. DO YOU WANT TO CONTINUE? [Y/N]: " flashing
case $flashing in
    Y|y)
      write_log_event "User has elected to flash firmware...Proceeding..."
      echo "FLASHING NOW. DO NOT REMOVE POWER!"
      if [[ -f dvm-firmware-hs_f1.bin ]]
        then
        stm32flash -v -w dvm-firmware-hs_f1.bin -i 20,-21,21,-20 -R $PATH_TO_MODEM -b 115200
        write_log_event "Flash completed..."
      fi
      ;;
    N|n)
      write_log_event "User has elected to abort..."
      echo "Aborting flash, but continuing..."
esac

write_log_event "Done with Flash Block..."

##### ZEROTIER BLOCK #####

write_log_event "Entering zerotier installation..."

write_log_event "Ensuring ZeroTier is installed..."
if [ -x "$(command -v zerotier-cli)" ]
then
    write_log_event "ZeroTier is already installed, joining the network..."
    zerotier-cli join $ZEROTIER
else
    write_log_event "ZeroTier is not installed, installing now..."
    curl -s https://install.zerotier.com/ | bash
    zerotier-cli join $ZEROTIER
fi



echo "Everything should be done installing...\\n\\nTo start dvmhost, run \"sudo systemctl start p25.service\""
exit 0

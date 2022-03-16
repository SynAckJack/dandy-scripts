#!/usr/bin/env bash

set -euo pipefail
# -e if any command returns a non-zero status code, exit
# -u don't use undefined vars
# -o pipefall pipelines fails on the first non-zero status code

#Set colours for easy spotting of errors
FAIL=$(echo -en '\033[01;31m[x]')
OKAY=$(echo -en '\033[01;32m[+]')
NC=$(echo -en '\033[0m')
WARN=$(echo -en '\033[1;33m[!]')
INFO=$(echo -en '\033[01;35m[*]')

# Check sudo permissions
echo "${INFO} Checking sudo permissions...${NC}"

if [ "$EUID" -ne 0 ] ; then
	echo "${FAIL} Please run with sudo...${NC}"
 	exit 1
fi


if [ -f AltPlugin.zip ] ; then 
    if ! rm -rf AltPlugin.zip ; then
        echo "${FAIL} Failed to delete old AltPlugin.zip.${NC}"
        exit 1
    fi
fi

if [ -d AltPlugin.mailbundle ] ; then 
    if ! rm -rf AltPlugin.mailbundle ; then
        echo "${FAIL} Failed to delete old AltPlugin.mailbundle.${NC}"
        exit 1
    fi
    
fi

echo "${INFO} Downloading AltPlugin.zip...${NC}"
if ! wget -q https://github.com/rileytestut/AltStore/raw/develop/AltServer/AltPlugin.zip; then 
    echo "${FAIL} Failed to download AltPlugin.zip. Is the URL still up...?${NC}"
    exit 1 
fi

echo "${INFO} Unzipping AltPlugin.zip...${NC}"
if ! unzip -qo AltPlugin.zip ; then 
    echo "${FAIL} Failed to unzip AltPlugin.zip. Is there already something called AltPlugin.mailbundle kicking about?${NC}"
    exit 1 
fi

echo "${INFO} Trying to kill Mail.app...${NC}"
if ! killall -q Mail ; then 
    echo "${WARN} Failed to kill Mail.app. This could be because it wasn't running though. Hopefully it's okay...${NC}"
fi

if [ -d /Library/Mail/Bundles/AltPlugin.mailbundle ] ; then 
    if ! rm -rf  /Library/Mail/Bundles/AltPlugin.mailbundle ; then
        echo "${FAIL} Failed to delete old AltPlugin.zip.${NC}"
        exit 1
    fi
fi

if sudo mv -f AltPlugin.mailbundle /Library/Mail/Bundles/ ; then 
    echo "${OKAY} Finished! Now you need to open Mail.app and enable the plugin. This can be done by going to Preferences > Manage Plug-ins > Tick the box and restart Mail.app...${NC}"
else 
    echo "${FAIL} Failed to move AltPlugin.mailbundle to the Mail plugin folder.You could try move it manually...?${NC}"
fi

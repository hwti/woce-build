#!/bin/bash

ROOTFS=rootfs/armv7
ROOTFS_MANTARAY=rootfs/mantaray

#copy individual files/directories in /usr/lib
USR_LIB_FILES=( libQt* libhal.so libaffinity.so* libqpalm.so libpsc.so luna )
ROOTFS_USR_LIB_FILES=$(echo ${USR_LIB_FILES[@]/#/$ROOTFS/usr/lib/}) #add prefix
mkdir -p $ROOTFS_MANTARAY/usr/lib
cp -af $ROOTFS_USR_LIB_FILES $ROOTFS_MANTARAY/usr/lib
FILES_TO_MOUNT=${ROOTFS_USR_LIB_FILES//$ROOTFS/} #remove prefix

FILES_TO_MOUNT+=" "
#copy full dirs
DIRS="/lib/hal/modules /usr/plugins /usr/palm/sysmgr"
for d in $DIRS; do
    mkdir -p $ROOTFS_MANTARAY$d
    cp -afT $ROOTFS$d $ROOTFS_MANTARAY$d
done
FILES_TO_MOUNT+=$DIRS

mkdir -p $ROOTFS_MANTARAY/usr/bin
cp -af packages/sysmgr/luna-sysmgr/build/custom/armv7-stage/release-mantaray/LunaSysMgr $ROOTFS_MANTARAY/usr/bin
FILES_TO_MOUNT+=" /usr/bin/LunaSysMgr"

cat > $ROOTFS_MANTARAY/mount-overlay.sh <<_EOF
#!/bin/sh

MOUNT_POINT=/tmp/LunaCE
FILES_TO_MOUNT="$FILES_TO_MOUNT"

for file in \$FILES_TO_MOUNT; do
    if [ -d \$MOUNT_POINT\$file ]; then
        mkdir -p \$file
    else
        if [ ! -e \$file ]; then
            mkdir -p \$(dirname \$file)
            touch \$file
        fi
    fi
    mount --bind \$MOUNT_POINT\$file \$file
done
_EOF
chmod 777 $ROOTFS_MANTARAY/mount-overlay.sh

cat > $ROOTFS_MANTARAY/umount-overlay.sh <<_EOF
#!/bin/sh

MOUNT_POINT=/tmp/LunaCE
FILES_TO_MOUNT="$FILES_TO_MOUNT"

for file in \$FILES_TO_MOUNT; do
    umount \$file
done
_EOF
chmod 777 $ROOTFS_MANTARAY/umount-overlay.sh

echo "Mantaray rootfs overlay created in $ROOTFS_MANTARAY"
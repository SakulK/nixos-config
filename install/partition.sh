parted -a opt --script "${ROOT_DISK}" \
    mklabel gpt \
    mkpart primary fat32 0% 512MiB \
    mkpart primary 512MiB 100% \
    set 1 esp on \
    name 1 boot \
    set 2 lvm on \
    name 2 root

cryptsetup luksFormat /dev/disk/by-partlabel/root
cryptsetup luksOpen /dev/disk/by-partlabel/root root
pvcreate /dev/mapper/root
vgcreate vg /dev/mapper/root
lvcreate -L 32G -n swap vg
lvcreate -l '100%FREE' -n root vg

mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/boot
mkfs.ext4 -L root /dev/vg/root
mkswap -L swap /dev/vg/swap

mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/vg/swap

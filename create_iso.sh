#!/bin/bash

create_iso() {
    sudo genisoimage -o custom.iso -V iPXE -r -T -b isolinux.bin -c boot.catalog -no-emul-boot -boot-load-size 4 -boot-info-table -J iso
}

install_deps() {
    sudo apt update
    sudo apt -y install genisoimage kexec-tools
}

update_ipxe_script() {
    local script="$1"

    cp "${script}" iso/user.ipxe
}

do_kexec_load() {
    kexec --load grub.exe \
          --initrd=custom.iso \
          --command-line="--config-file=debug on; map --mem (rd)+1 (0xff); map --hook; chainloader (0xff)"
}

do_kexec_exec() {
    kexec -e
}

main() {
    local script="$1"

    install_deps
    update_ipxe_script "${script}"
    create_iso
    do_kexec_load
    do_kexec_exec
}

main "$1"

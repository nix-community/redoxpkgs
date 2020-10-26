{ runCommandLocal, pkgsCross, qemu }:

let
  redox = pkgsCross.x86_64-unknown-redox;
  inherit (redox) redox-vmdisk;

  vmForDisk = vmdisk: (
    runCommandLocal "redox-vm" {
      nativeBuildInputs = [ qemu ];
      propagatedBuildInputs = [ qemu ];
    } ''
      mkdir -p $out
      qemu-img convert -f raw -O qcow2 ${vmdisk}/harddrive.bin $out/harddrive.qcow2
      cat << EOF > $out/vm.sh
      ${qemu}/bin/qemu-system-x86_64 -serial mon:stdio \
        -d cpu_reset -d guest_errors -smp 4 -m 1024 -s -machine q35 \
        -device ich9-intel-hda -device hda-duplex -net nic,model=e1000 \
        -net user -device nec-usb-xhci,id=xhci -device usb-tablet,bus=xhci.0 \
        -enable-kvm -cpu host -drive file=$out/harddrive.qcow2 -snapshot \
        -nographic -vga none
      EOF
      chmod +x $out/vm.sh
    ''
  );
  vm = vmForDisk redox-vmdisk;
in
vm // {
  withVMDisk = vmForDisk;
  withRootFS = rootfs: vmForDisk (redox-vmdisk.withRootFS rootfs);
  withPackages = rootfs: vmForDisk (redox-vmdisk.withPackages rootfs);
}

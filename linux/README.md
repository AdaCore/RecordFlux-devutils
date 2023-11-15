This folder contains scripts and a Linux kernel binary to transparently run privileged commands as a user inside a virtual machine.

# Usage

The `linux/run` script is the main entry point to the tool:

```console
$ linux/run $(pwd) echo Hello World
Hello World
```

The first argument is the *absolute* path of the *host* working directory to be entered before the command is executed.
The exit code of the `run` script matches the exit code of the command that was executed:

```console
$ linux/run $(pwd) true; echo $?
0
$ linux/run $(pwd) false; echo $?
1
```

Instead of a command, a script or any other binary can be passed to `run`:

```console
$ printf '#!/bin/bash\necho Hello World\nexit 42' > /tmp/myscript
$ chmod 755 /tmp/myscript
$ linux/run $(pwd) /tmp/myscript; echo $?
Hello World
42
```

# Background

Commands are executed inside a Qemu virtual machine directly by the init script (`linux/init`).
Consequently, all scripts are run as the `root` user and there are generally no limitations on what the executed command can do.
The host file system is fully exposed to the guest VM using a 9P virtio root file system.
That means, that paths in the guest match those in the host.
However, access permissions still apply and files to be accessed in the virtual machine must be accessible by the user executing `linux/run`.
The exit code of the script (or the exit code of init in case of errors), is passed back to Qemu using the special `isa-debug-exit` device.
Note, that the kernel used in the virtual machine is stripped down to reduce binary size and build time and it may lack required features.
See the section "Linux Kernel" on how to add new features and rebuild the kernel.

# Prerequisites

The following packages are required on the host system to run the tool:

- qemu-system-x86
- xxd
- iproute2

# Linux Kernel

## Configuration

A new kernel image can be created using the `update_kernel.sh` script.
It requires the usual build dependencies as outlined in the [Linux kernel documentation](https://docs.kernel.org/admin-guide/quickly-build-trimmed-linux.html#install-build-requirements).

```console
$ cd linux/
$ ./update_kernel.sh
```

To change the configuration interactively, set the `MENUCONFIG` environment variable:

```console
$ cd linux/
$ MENUCONFIG=1 ./update_kernel.sh
```

The resulting files `kernel` and `config` contain the newly built Linux kernel and the updated configuration, respectivly.
If you want to retain those changes, commit both files to the repository.

## Update

A different kernel version can be built by setting the `LINUX_URL` environment variable to a download location of a `.tar.xz` archive of the Linux source tree.
For a permanent upgrade, change the respective default in `linux/update_kernel.sh`

# Limitations

- The tool only works on x86_64
- The screen is always cleared when executing `run`

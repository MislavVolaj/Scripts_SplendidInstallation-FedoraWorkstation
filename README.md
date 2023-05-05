# "Splendid installation" scripts for Fedora Workstation

## Summary

  - [Description of purpose](#description-of-purpose)
      - [Modules dissection](#modules-dissection)
  - [Usage instructions](#usage-instructions)
      - [Requirements](#prerequisites)
      - [Deployment](#deployment)
  - [Versioning](#versioning)
      - [Compatibility](#compatibility)
      - [Releases](#releases)
      - [Roadmap](#roadmap)
      - [Release notes](#release-notes)
  - [License](#license)
  - [Contact](#contact)

## Description of purpose

Scripted (semi-automated) (re)installation of *Fedora Workstation*, including exporting and importing operating system's and programs' settings and users' files.

### Modules dissection

  - Pre-installation
      - Configure *Kickstart* answer file
      - Export system's settings
      - Export users' settings
      - Export programs' settings
      - Backup users' folders
  - Installation
      - *Kickstart* answer file
      - Install software from repositories
      - Install software from other sources
  - Post-installation
      - Set up system
      - Set up users
          - Customise interface
      - Set up programs
      - Restore users' folders
  - Maintenance
      - Update
      - Upgrade
      - Clean up
      - Manage file systems
          - Manage Ext4
          - Manage XFS
          - Manage Btrfs
              - Create and restore snapshots

## Usage instructions

### Requirements

Two thumb drives; one to host the *Fedora Everything* ISO, the other to host the *Kickstart* answer file and these scripts.

### Deployment

To clone this repository:
  - run *git clone https://github.com/MislavVolaj/Scripts_SplendidInstallation-FedoraWorkstation.git*

To load a *Kickstart* answer file:
  - boot from a thumb drive with *Fedora Everything* ISO on it
  - select *Install Fedora* by pressing *upwards arrow* and press *e* to modify Kernel boot parameters
  - press *downwards arrow* three times and *leftwards arrow* seven times to position the cursor before the word *quiet* and press *space*
  - type *inst.ks=hd:LABEL=USB:/Scripts_SplendidInstallation-FedoraWorkstation/Installation/Configuration_Kickstart-FedoraWorkstation.cfg*, depending on the thumb drive partition label and a *Kickstart* answer file name and location on the thumb drive, then press *Ctrl* and *x* to start the *Anaconda installer*

To run these scripts:
  - open *Nautilus (GNOME Files)*, navigate to the main menu script named *Script_SplendidInstallation-FedoraWorkstation.sh*
  - right-click the main menu script named *Script_SplendidInstallation-FedoraWorkstation.sh*, click *Run as a program*
  - type a menu number of your choice followed by *enter* key to browse through sub-menus and choose options to run 

### Notices

The options of standard and alternative *snapshotting* and *rolling back* (restoring) logic explained:
  - Standard *snapshotting* logic creates read-only snapshots of subvolumes in a flat layout and continues to use original subvolumes as default. Standard *rolling back* logic creates writeable snapshots of read-only snapshots of original subvolumes in a flat layout and switches to use them as default, with restart.
  - Alternative *snapshotting* logic creates writeable snapshots of subvolumes in a flat layout and switches to use them as default, with restart. Alternative *rolling back* logic switches to use original subvolumes as default, with restart.

WARNING: *Snapshotting* and *rolling back* is supported only for one set of snapshots, making it required to delete all snapshots before taking new snapshots, in line with the *freezing system state* philosophy. Deleting all snapshots is recommended before running Btrfs maintenance tasks.

## Versioning

This project uses **major.minor.revision** numbering scheme in the following manner:

  - **major** numbers reference the Fedora Workstation release targets,
  - **minor** numbers reference feature implementations and do not reset with major numbers increment,
  - **revision** numbers reference code correction and may be omitted.

### Compatibility

Commits pushed under **major** number targeting a stable Fedora Workstation release **may not be compatible** with previous, next or rolling Fedora Workstation releases.

### Releases

To provide historical compatibility, the highest **minor.revision** versions before **major** number increment are tagged as releases.

For the releases available, see the [tags](https://github.com/MislavVolaj/Scripts_SplendidInstallation-FedoraWorkstation/tags).

### Roadmap

  - Continuous compatibility with Fedora Workstation releases
  - Automation of the scripts with an answer file
  - Expansion of software selection
  - Selection of partitioning layouts

### Release notes

For changes in newer versions, see the [release notes](RELEASENOTES.md).

## License

This project is licensed under the version 3.0 of the **[GNU General Public License](LICENSE.md)**.

## Contact

Contact **Mislav Volaj** on [GitHub](https://github.com/MislavVolaj) or [Reddit](https://www.reddit.com/user/HotSauceOnPasta).

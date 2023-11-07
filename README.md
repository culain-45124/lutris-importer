# lutris-importer

Lightweight script designed to import games from [Lutris](https://github.com/lutris/lutris) in to Steam along with corresponding art work uing [Steam ROM Manager](https://github.com/SteamGridDB/steam-rom-manager).

Run the command to create a folder in the current working directory for each "service" registered in Lutris. The command will then make a `.json` manifest file containing the details for each game associated with that service in the respective folders.

These `.json` files can then be parsed by Steam Rom Manager to import them in to Steam with the correct artwork.

The manifest files make use of the [Lutris CLI protocol link](https://github.com/lutris/lutris#command-line-options) functionality, using `lutris:` followed by the service and a game identifier, which will open a game via Lutris if it is installed, or install it if not.

Unfortuantely this doesn't work for all services currently, see the serivce compatibility table below. Hoping to get a PR in to Lutris to make this work universally.

| Service | Working |
| --------- | ----------- |
| egs      | :heavy_check_mark: |
| ea_play      | :heavy_check_mark: |
| gog      | :heavy_check_mark: |
| amazon      | :heavy_check_mark: |
| ubisoft      | Partial Compatibility |

## Installation

Clone the repo using:

`git clone git@github.com:culain-45124/lutris-importer.git`

Create a new bin directory if you don't already have one:

`mkdir ~/bin`

Symlink script in to the bin directory:

`ln -s /home/deck/lutris-importer/lutris-import.sh /home/deck/bin/lutris-import`

Add bin to your path:

`echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc`

Restart your terminal, or open a new tab for changes to take effect

## Usage

Register all the services you want to on Lutris, you need a version >0.5.14 for this to work

Change directory to the location you want to create the folders, for example

`cd /run/media/mmcblk0p1/Emulation`

Run the command

`lutris-import`

This should create all the corresponding files and folders

## Options

| Arguments | Description |
| --------- | ----------- |
| `-f`      | If the script detects a file with the name of the service in the current working directory it will exit so as not to delete anything important. Use `-f` to force the deletion of this file so it can be replaced with a directory |
| `-h`      | Display help text |


## Import via Steam ROM Manager

You'll need to do this for each service that you want to add the games from to Steam

To import via Steam ROM Manager:

1. Open Steam ROM Manager
1. Click "Create Parser"
1. Under "PARSER TYPE" select "Manual"
1. For "MANIFESTS DIRECTORY" select the service directory that you're adding, e.g. `/run/media/mmcblk0p1/Emulation/gog`
1. Fill in the other options as required, click "Test parser" to check it works then "Save" to finish
1. Use the "Preview" pane as usual to select artwork and add to Steam
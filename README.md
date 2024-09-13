# PITS
**Pit Inventory and Tethering System**

PITS is a Java-based utility used to manage robot logs using FTP.
## Usage
Currently only a graphical interface is available.
* **IP Address**: IP address of the robot. For Red Alert's 2024 season, this address is 10.17.41.2.
* **Directory**: The folder in which the logs are stored on the robot. This is usually `/home/lvuser/logs`. For Red Alert's 2024 season, this is `/media/sda1/logs`.
* **Download**: Connect to the robot using the provided settings and retrieve log files.
* **Status section**: View current download progress.

## Modification
You are free to modify this application as you see fit for your own team, for example to change the default configuration options.

## Building
Use the included Gradle executable to build this program. You can also download release jar files from the Releases section of this repository.

## Troubleshooting
* **(macOS) "PITS.jar" cannot be opened because it is from an unidentified developer.**
    * On macOS systems, programs which are not notarized by an authorized developer will not run by default. You can get around this by either right-clicking the jar file in Finder and selecting Open, or by going to System Settings, Privacy & Security, and allowing the app to run.
* **Cannot connect to robot**
    * Ensure the robot is on, connected to Wi-Fi/Ethernet/USB, and the IP address is correct.
    * Ensure that FTP is enabled on the robot.
* **"Robot refused connection".**
    * Ensure that FTP is configured for anonymous login on the robot.
    * Run PITS from a command prompt window and take a look at the error code that is given.
* **FTP connects, but finds no logs.**
    * Ensure the log directory is correct.
    * (Windows) Ensure that Java is allowed through your firewall.
* **"Could not create the download folder".**
    * Ensure Java has write permissions in the directory it is run from.
    * Ensure you have permissions to delete directories if you are trying to overwrite an existing folder.
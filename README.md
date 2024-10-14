# SphereZones
 This project is a mod for Palworld built using UE4SS. It controls what players can do in different zones, like building, dismantling, or attacking, based on a set of rules defined in a `zones.json` file. The mod checks where the player is and applies the right permissions for that zone. It’s a simple way to create custom gameplay mechanics depending on location.

 The author abandoned the project so I'll be taking my time to update it here. The web app has already been updated with the latest Sakurajima update. Click [SphereZones Online Tool](https://palbot.gg/sphere/) for the up to date map.

## Installation
 - Download the latest version of [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases)
 - Extact the contents of your `UE4SS_version.zip` to the `Pal/Binaries/Win64` folder.
 - Download the latest version of [SphereZones](https://github.com/palbot-gg/SphereZones/archive/refs/heads/main.zip)
 - Extract the `SphereZones-main` folder to the `Pal/Binaries/Win64/Mods` folder.
 - Edit the `Pal/Binaries/Win64/UE4SS-settings.txt` and change the `bUseUObjectArrayCache` to `false`.
 - Start up your server and it should work.

## Configuring Zones
 1. You will need to configure the `zones.json` file utilizing the [SphereZones Online Tool](https://palbot.gg/sphere/)
 2. Create your desired zones by following the directions on the website.
 3. Export your `zones.json` and replace the file in `Pal/Binaries/Win64/Mods/SphereZones-main/Scripts/Data` folder.

## Credits
 - [DecioLuvier](https://github.com/DecioLuvier) for creating SphereZones
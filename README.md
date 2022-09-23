# (WIP) Home Assistant - Hitachi airCloud integration

## Prerequisite
1. You need the Dual Mode Generic Thermostat : https://github.com/zacs/ha-dualmodegeneric
2. You need websocat binary on your installation : https://github.com/vi/websocat

## airCloud.sh usage
```shell
./airCloud.sh <action> <room> <mode> <temperature> 

<action> : on (Power On) / off (Power Off) / powerstatus (AC Power Status) / modestatus (AC Mode Status) / roomtemperature (Room Temperature) / idutemperature (AC Thermostat Temperature) / websocatdebug (display Hitachi websocket full result in json)
<room> : Your room named like in your Hitachi airCloud app 
<mode> : COOLING / HEATING / FAN
<temperature> : Target temperature
```



Example : 
```shell
./airCloud.sh <action> <room> <mode> <temperature> 
```

## Installation (Manual)
1. Download this repository as a ZIP (green button, top right) and unzip the archive
2. Copy `/scripts/aircloud.sh` to your `<config_dir>/scripts/` directory
3. Modify aircloud.sh with :
   * your Hitachi airCloud credentials in base64 (or in clear text as you want ...) : 
   ```shell
   hitachiuser=$(echo "dGVzdEB0ZXN0LmNvbQ==" | base64 -d)
   hitachipassword=$(echo "dGVzdA==" | base64 -d)
   #or
   hitachiuser="test@test.com"
   hitachupassword="test"
   ```
   * The path to websocat binary
   ```shell
   websocatbinary="/opt/scripts/websocat.x86_64-unknown-linux-musl"
   ```
   
4. Create a new folder (or reuse it) `<config_dir>/climate` and copy climate folder content
5. Copy packages content folder to your `<config_dir>/packages/`
6. Modify yaml files for your setup
* Change the folder of aircloud.sh in switches yaml, changes
* Change also the name of your rooms named in Hitachi airCloud app (Here : Séjour is the living room name), if your room has a space in name, escape it with \ (Example : Chambre\ 2)
* [![airCloudApp](https://i.ibb.co/0JydKFd/Screenshot-20220923-154652.jpg)](https://i.ibb.co/0JydKFd/Screenshot-20220923-154652.jpg)
* Change the target temp for your AC (NB : See TODO LIST, this is WIP ;) ) 
```yaml
switch:
  - platform: command_line 
    switches:
      ac_salon_heater:
         friendly_name: 'Heater Living Room'
         unique_id: switch_ac_living_room_heater
         command_on: >
             sh /opt/scripts/aircloud.sh on Séjour HEATING 22
         command_off: >
             sh /opt/scripts/aircloud.sh off Séjour HEATING 22
         command_state: >
             sh /opt/scripts/aircloud.sh powerstatus Séjour
         value_template: >
           {% if value == "ON" %}
           true
           {% else %}
           false
           {% endif %}
      ac_salon_cool:
         friendly_name: 'Cooler Living Room'
         unique_id: switch_ac_living_room_cooler
         command_on: >
             sh /opt/scripts/aircloud.sh on Séjour COOLING 22
         command_off: >
             sh /opt/scripts/aircloud.sh off Séjour COOLING 22
         command_state: >
             sh /opt/scripts/aircloud.sh powerstatus Séjour
         value_template: >
           {% if value == "ON" %}
           true
           {% else %}
           false
           {% endif %}

```
## Home Assistant Result
* [![HA Result](https://i.ibb.co/NCFkZ4n/HA-air-Cloud.jpg)](https://i.ibb.co/NCFkZ4n/HA-air-Cloud.jpg)


## TODO LIST
* Send target temperature in Home Assistant Thermostat to aircloud.sh script (At this moment, the temp is manual in switches, 22° in my example)
* Documentation
* HA Best folder pratices (Maybe?) 

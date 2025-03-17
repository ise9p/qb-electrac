# Job: Electrac - Electricity Repair Job

## Overview
This is a custom job script for FiveM where players can take on the role of an electricity repair technician. They can complete missions to repair electrical issues around the city. The job includes different features like progression, rewards, and dynamic mission locations.

## Features
1. NPC manager where players can start and cancel jobs.
2. Random mission locations where players need to repair electrical issues.
3. Player progression system based on completing repairs.
4. Payment upon completion of the task.
5. Ability to earn additional rewards and items.
6. Webhook integration to notify on job completion.

## Configuration

All configurable settings are stored in the `Config.lua` file. Below are the settings you can modify:

### NPC Information
1. Ped Model : The model of the NPC (Ped) who gives the job.
  - `Config.PedModel = 'a_m_m_business_01'`
2. Ped Location : The coordinates where the NPC will be located.
  - `Config.PedCoords = vector4(287.98, -23.37, 74.47, 257.37)`

### Webhook
1. Webhook URL: Used for sending job completion notifications to Discord.
  - `Config.WebHook = 'your_webhook_url_here'`

### Vehicle
1. Vehicle Model: The model of the vehicle that will be used for the job.
  - `Config.VehicleModel = 'utillitruck3'`
2. Vehicle Spawn Location: The location where the vehicle will spawn for the player.
  - `Config.spawncar = vector4(274.2, 1.38, 78.81, 249.89)`

### Mission Locations
1. Mission Locations: A list of potential locations where players will need to go to complete the mission. The location is chosen randomly.

  ```lua
  Config.MissionLocations = {
      vector4(282.55, -32.66, 72.8, 138.69),  -- Mission 1
      vector4(263.63, -20.01, 73.55, 340.71),  -- Mission 2
      vector4(261.35, -19.29, 73.54, 335.35)   -- Mission 3
  }
   ```

### Installation Instructions:

1. Configuring Player Metadata:
Open the qb-core/config.lua file and add the following under the metadata section:

metadata = {
    jobrep = {
        electrac = {
            grade = 1,
            progress = 0,
            payment = 0,
        },
    },
}

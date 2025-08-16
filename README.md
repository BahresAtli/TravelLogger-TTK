# TTK 0.0.1

Download here!

Release:
Debug:

## Important note

This version might not be stable. There might be many bugs other than listed, do not entirely trust this app for saving your travel data, at least for now. Though if you want to test, you are more than welcome!

Also unfortunately, you cannot use this data for this version if you do not have root permission on the phone. In the next update, there will be exporting system for all of your data.

Update: You can actually retrieve your data via using adb backup command (Note that it is deprecated, I'm working on exporting the data.)

## Updates with TTK 0.0.1

Distance, speed and altitude measurements are added.

Label system is changed. You can now label your measurements while measuring. You don't need to stress about putting a label when getting of the bus, you can do it while you're sitting in comfort!

Location data is being collected every second instead of every 5 seconds

To prevent noise, location data won't change if your movement is less than a meter. Helpful for the noise in indoors.

Couple technical, infrastructural improvements.

## The TTK App is here! 

TTK App aims to save your time and location stream data into your phone for following your travel history. Press "Start" and it will save your location into a local database every 10 seconds (every 1 second in Debug mode), also storing total elapsed time. You can also label your measurements after you press finish. 

## What TTK App can do:

Save the elapsed time for a travel

Save your location every 10 seconds into local database

Save distance and speed info


## Known bugs (still persists on 0.0.1)

You need to always enable the location permission. If you disable the location permission, the app will crash. 

App searches for the location data, even after you press "Finish" (even though it does not save the location data after pressing finish)

You cannot access the database without getting help from external application and root permission on your phone.

In places where GPS is in a poor condition and GPS shows you in the random far away directions, TTK App will interpret these as legit locations. Which can result in more distance than the reality.

Sometimes, app will not calculate the distance even if the location changes in the database. Which can result TTK App interpreting as less distance than the reality.

## What's next?

Since it is the first release, there is so much missing from the app for it to be truly an useful Travel Logger app. Here is some features I'm planning to add in the future:

Better location map

Better accuracy

Classifying the type of vehicles (walking, cycling, car, public transport...)

Ability to save your vehicle info such as plate, bus number (for public transit systems) etc.


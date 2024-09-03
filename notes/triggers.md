# Triggers

Triggers are part of the config, where a certain set of actions need to be performed before a particular location is processed.

For example, if we have a server, and we want to do a backup of a couple different folder locations: 
* `/data/content`
* `/data/database`
* `/etc`

The `/data/content` and the `/etc` locations are just plain copies (for now).  However, when doing the `/data/database` location, we need to perform some steps to make it suitable to perform the backup. 

Like:
1. Put a service in maintenance mode
2. Trigger a service which extracts the data
3. Put the service back in normal mode.

Some of the questions might be, would it be better to just trigger all that before the backup begins?  Although possible, also No.. because we want the service to be in maintenance mode for as short as possible, and there can be situations where multiple steps need to be made.

### Expected Solution

Currently using a bash script to perform this, so what a method to store the information in a way that can be easily processed.

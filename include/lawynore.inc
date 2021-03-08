#if defined _lawynore_included
 #endinput
#endif
#define _lawynore_included

/**
 * Get client hours played on this server.
 *
 * @param client    Client name.
 * @return hours    How many hours played this client.
 */
native int GetClientHours(int client);

/**
 * Get client minutes played on this server.
 *
 * @param client    Client name.
 * @return minutes    How many minutes played this client.
 */
native int GetClientMinutes(int client);

/**
 * Get client seconds played on this server.
 *
 * @param client    Client name.
 * @return seconds    How many seconds played this client.
 */
native int GetClientSeconds(int client);

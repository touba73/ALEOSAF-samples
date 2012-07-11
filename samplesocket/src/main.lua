-------------------------------------------------------------------------------
-- Copyright (c) 2012 Sierra Wireless and others.
-- All rights reserved. This program and the accompanying materials
-- are made available under the terms of the Eclipse Public License v1.0
-- which accompanies this distribution, and is available at
-- http://www.eclipse.org/legal/epl-v10.html
--
-- Contributors:
--     Sierra Wireless - initial API and implementation
-------------------------------------------------------------------------------

--
-- Socket sample
--
local log    = require "log"
local os     = require "os"
local sched  = require "sched"
local socket = require "socket"

local LOGMODULENAME = "SOCKET"
local LOGLEVEL      = "INFO"

local function main ()

	log.setlevel(LOGLEVEL)
	log(LOGMODULENAME, LOGLEVEL, "Starting sample...")

	-- Create and open a TCP socket and bind it to the localhost, at any port
	local server = assert(socket.bind("*", 0))

	-- Find out which port ALEOS chose for us
	local _, port = server:getsockname()
	log(LOGMODULENAME, LOGLEVEL, "TCP socket listening on port %s, waiting...", port)
	log(LOGMODULENAME, LOGLEVEL, "Open a telnet connection on the device, for the %s port.", port)

	-- Wait for a connection from clients
	local client = server:accept()
	log(LOGMODULENAME, LOGLEVEL, "Incoming connection accepted.\nType 'stop' to close the sample\n")

	-- Loop forever waiting for clients
	repeat

		-- One client connects, send a welcome message
		client:send("Welcome, you have 15s to type a line here: ")

		-- Wait 15s to for the line.
		client:settimeout(15)

		-- Retreive actual line
		local line, err = client:receive()

		-- Send an acknowledgement message to the client
		if not err then
			log(LOGMODULENAME, LOGLEVEL, "Line correctly received: %s.", line)
			client:send(string.format("Line received: %s.\n", line))
		else
			log(LOGMODULENAME, LOGLEVEL, "Error when receiving message: %s", err)
		end

	until line == "stop"

	-- Close the current connection
	log(LOGMODULENAME, LOGLEVEL, "Closing connection now.")
	client:close()
	log(LOGMODULENAME, LOGLEVEL, "Connection closed.")

	log(LOGMODULENAME, LOGLEVEL, "Closing port.")
	server:close()

	log(LOGMODULENAME, LOGLEVEL, "Sample end.")
	os.exit()
end

sched.run(main)
sched.loop()

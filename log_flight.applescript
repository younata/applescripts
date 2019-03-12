#!/usr/bin/env osascript

on date_to_iso(dt)
	set {year:y, month:m, day:d} to dt
	set y to text 2 through -1 of ((y + 10000) as text)
	set m to text 2 through -1 of ((m + 100) as text)
	set d to text 2 through -1 of ((d + 100) as text)
	return y & "-" & m & "-" & d
end date_to_iso

on run argv
	set date_string to date_to_iso(current date)
	
	try
		set arg_count to (count of argv)
		if arg_count = 0 then error "Must be called from command line"
		if arg_count < 5 then error "Too few arguments (expected at least 5, have " & arg_count & ")"
		if arg_count > 6 then error "Too many arguments (expected at most 6, have " & arg_count & ")"
		
		set flight_time to (item 1 of argv) as number
		set ground_time to (item 2 of argv) as number
		set is_pic to item 3 of argv
		set flight_cost to (item 4 of argv) as number
		set ground_cost to (item 5 of argv) as number
		if arg_count = 6 then
			set notes to item 6 of argv
		else
			set notes to ""
		end if
		
		if is_pic = "y" then set is_pic to "Y"
		if is_pic = "n" then set is_pic to "N"
		
		if is_pic ­ "Y" and is_pic ­ "N" then error "is_pic (third argument) must be either 'y' or 'n'"
	on error errorMessage
		log errorMessage
		set usage_message to "Error: " & errorMessage & return & "Usage: ./add_flight <flight_time> <ground_time> <is_pic?> <flight_cost_per_hour> <ground_cost_per_hour> <notes>"
		error usage_message
	end try
	
	set total_cost to (flight_time * flight_cost) + (ground_time * ground_cost)
	
	tell application "Finder"
		set icloud_path to (path to home folder as text) & "Library:Mobile Documents:"
		set numbers_path to icloud_path & "com~apple~Numbers:Documents:"
		set aviation_costs to numbers_path & "Aviation Costs.numbers"
		open aviation_costs
	end tell
	
	tell application "Numbers"
		activate
		
		if not (exists document 1) then error "No document open"
		
		tell front document
			set doc_name to get name as string
			if doc_name ­ "Aviation Costs" then error "Front document is not 'Aviation Costs' (got " & doc_name & ")"
			
			tell active sheet
				set the selectedTable to the first table
			end tell
			
			tell selectedTable
				add row below last row
				tell last row
					set value of first cell to date_string
					set value of second cell to flight_time
					set value of third cell to ground_time
					set value of fourth cell to total_cost
					set format of fourth cell to currency
					set value of fifth cell to is_pic
					set value of sixth cell to notes
				end tell
			end tell
		end tell
	end tell
end run

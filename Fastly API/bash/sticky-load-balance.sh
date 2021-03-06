#! /bin/bash
#
# sticky-load-balance.sh
# ==========
# This script contains an example script to add and configure load balancing via the Fastly API. 
# It is not designed to be a robust framework for implementing load balancing, but as a starting point
# for your own scripts for deploying.
# They presume some familiarity with Fastly and APIs in general and should be used as examples only.
#
# Additional details on using this script can be found at http://docs.fastly.com/api.
#

if [ "$FASTLY_API_DEBUG" == "true" ]; then
	set -e
	set -x
fi

# Load the configuration file that contains the api key and service id.
# an example configuration file can be seen at 
# https://github.com/jondade/admin/blob/master/Fastly%20API/bash/api-creds-example.sh
source ~/.fastly/api-creds.sh

#TODO: add functions and calls to get get the latest version, clone and use the new version.
export VERSION='3'

# Define a function to display the output nicely.
pretty-out() {
	echo
	echo "$1"
}

# Set up a variable to save re-typing the whole lot for each API call.
export FASTLY_API_URL="https://api.fastly.com/service/$FASTLY_SERVICE_ID"

# The rest of the commands assume you have either got the correct configuration
# version via the API or by accessing https://app.fastly.com/

# First lets create the director
pretty-out "Create a director"
curl -X POST \
	-H "$FASTLY_API_KEY" \
	-H "Content-type: application/json" \
	-H "Accept: application/json" \
"$FASTLY_API_URL/version/$VERSION/director" -d \
'{"name":"load-balancer", "type":"4"}'

# Now lets create two new backends (origin servers) to add to the director
pretty-out "Create the first backend."
curl "$FASTLY_API_URL/version/$VERSION/backend" -H 'Content-Type: application/json' -H "$FASTLY_API_KEY" -d \
'{"hostname":"test-2.test.com","port":"80","name":"test-sticky-lb-1","auto_loadbalance":"false"}'
pretty-out "Create the second backend."
curl "$FASTLY_API_URL/version/$VERSION/backend" -H 'Content-Type: application/json' -H "$FASTLY_API_KEY" -d \
'{"hostname":"test-2.test.com","port":"80","name":"test-sticky-lb-2","auto_loadbalance":"false"}'

# And add those to the director
pretty-out "Add the first backend to the director."
curl -X POST -H "$FASTLY_API_KEY" "$FASTLY_API_URL/version/$VERSION/director/load-balancer/backend/test-sticky-lb-1"
pretty-out "Add the second backend to the director."
curl -X POST -H "$FASTLY_API_KEY" "$FASTLY_API_URL/version/$VERSION/director/load-balancer/backend/test-sticky-lb-2"

# Now lets check all that
pretty-out "Lets show all that is configured."
curl -X GET -H "$FASTLY_API_KEY" -H "Accept: application/json" "$FASTLY_API_URL/version/$VERSION/director"

# That's the load balancing sorted. Now lets make this a sticky load-balancer.
pretty-out "Now add a header for cookie stickiness."
curl -X POST \
	-H "$FASTLY_API_KEY" \
	-H "Content-type: application/json" \
	-H "Accept: application/json" \
"$FASTLY_API_URL/version/$VERSION/header" -d \
'{
	"name":"cookie-lb",
	"type":"request",
	"action":"set",
	"dst":"client.identity",
	"src":"regsub(req.http.cookie, \"session=(.*);/\",\"\\1\")",
	"ignore_if_set":"0",
	"priority":"10"
}'

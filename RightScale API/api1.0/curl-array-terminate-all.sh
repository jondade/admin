#! /bin/bash -ex
#
# This is a template for use testing API functions.
# It relies on a file called user-details.sh to pull in the credentials. This file should contain similar to the following:
#
#USER="user.name@company.com"
#PASSWORD="MySecurePassword"
#ACCT="0000"
#

# This file should setup variables containing the username and password
source ../user-details.sh

# This line sets up the login cookies
curl -c mySavedCookies -u "$USER:$PASSWORD" https://my.rightscale.com/api/acct/$ACCT/login?api_version=1.0

# Terminate all servers in an array
curl -b mySavedCookies -X POST -H 'X-API-VERSION:1.0' "https://my.rightscale.com/api/acct/$ACCT/server_arrays/212501001/terminate_all"

#!/bin/bash
#
# UhostRepo Setup
# https://github.com/uhost/uhostrepo/
#
# version: 0.4.0
#
# License & Authors
#
# Author:: Mark Allen (mark@markcallen.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

KEY_FILE=""
HOSTNAME=""

while getopts h:k: option
do
  case "${option}"
  in
    h) HOSTNAME=${OPTARG};;
    k) KEY_FILE=${OPTARG};;
  esac
done

if [ -z $HOSTNAME ] || [ -z $KEY_FILE ]; then
  echo "$0 -h <hostname> -k <key file>"
  exit 1;
fi

if [ ! -d .chef ]; then
  mkdir .chef
fi

ssh -i $KEY_FILE ubuntu@$HOSTNAME 'sudo cat /etc/chef-server/uhostadmin.pem' > .chef/uhostadmin.pem
ssh -i $KEY_FILE ubuntu@$HOSTNAME 'sudo cat /etc/chef-server/chef-validator.pem' > .chef/chef-validator.pem

cat << EOF >> .chef/knife.rb
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "uhostadmin"
client_key               "#{current_dir}/uhostadmin.pem"
validation_client_name   "chef-validator"
validation_key           "#{current_dir}/chef-validator.pem"
chef_server_url          "https://${HOSTNAME}"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
ssl_verify_mode          :verify_none
EOF





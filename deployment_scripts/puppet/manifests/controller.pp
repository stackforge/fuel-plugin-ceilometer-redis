#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

prepare_network_config(hiera('network_scheme', {}))

# Setup redis servers only on controllers
$redis_roles = ["primary-controller", "controller"]
$redis_nodes = get_nodes_hash_by_roles(hiera('network_metadata'), $redis_roles)

# Use ceilometer network role
$redis_address_map  = get_node_to_ipaddr_map_by_network_role($redis_nodes, 'ceilometer/api')
$redis_bind_address = get_network_role_property('ceilometer/api', 'ipaddr')

$redis_hosts        = values($redis_address_map)
$primary_redis_node = $redis_hosts[0]

class {'::redis::main':
  primary_redis_node => $primary_redis_node,
  redis_hosts        => $redis_hosts,
  redis_bind_address => $redis_bind_address,
  primary_controller => false,
}
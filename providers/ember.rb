#
# Author:: Simon Kaluza <simon@inboxhealth.com>
# Cookbook Name:: application_ruby
# Provider:: rails
#
# Copyright:: 2015, Inbox Health, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

action :before_compile {}

action :before_deploy {}

action :before_migrate {}

action :before_symlink do
  
  deploy_revision ember_deploy_path do
    repo new_resource.repository
    revision new_resource.revision
    symlink_before_migrate.clear
    symlinks.clear
    migrate false
    user new_resource.owner
  end

  execute "npm install && bower install && ember build -e #{new_resource.environment_name}" do
    cwd ember_deploy_path + '/current'
    user new_resource.owner
    environment "HOME" => "/home/" + new_resource.owner
  end
end

action :before_restart do
  link(new_resource.path + "/current/" + new_resource.distribution_link) do
    to(ember_deploy_path + '/current/dist')
  end
end

action :after_restart {}

def ember_deploy_path
  new_resource.path + '/ember'
end
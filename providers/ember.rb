#
# Author:: Simon Kaluza <simon@inboxhealth.com>
# Cookbook Name:: application_ruby
# Provider:: ember
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

action :before_compile do
  unless new_resource.deploy_key.nil?
    directory ember_deploy_path do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
      recursive true
    end
    if ::File.exists?(new_resource.deploy_key)
      deploy_key = open(new_resource.deploy_key, &:read)
    else
      deploy_key = new_resource.deploy_key
    end

    file "#{ember_deploy_path}/id_deploy" do
      content deploy_key
      owner new_resource.owner
      group new_resource.group
      mode '0600'
    end

    template "#{ember_deploy_path}/deploy-ssh-wrapper" do
      source "deploy-ssh-wrapper.erb"
      cookbook "application"
      owner new_resource.owner
      group new_resource.group
      mode "0755"
      variables :id => new_resource.name, :deploy_to => ember_deploy_path
    end
  end
end

action :before_deploy do

  @deploy_resource = send(:deploy_revision, ember_deploy_path) do
    repo new_resource.repository
    revision new_resource.revision
    symlink_before_migrate.clear
    symlinks.clear
    migrate false
    user new_resource.owner
    ssh_wrapper "#{ember_deploy_path}/deploy-ssh-wrapper" if new_resource.deploy_key
  end

  # Store the current Ember app release path for sym linking after a successful build
  provider = @deploy_resource.provider_for_action(:nothing)
  provider.load_current_resource
  provider.release_path
  new_resource.ember_release_path = provider.release_path

  if new_resource.link_dependencies
    new_resource.link_dependencies.each do |d|
      execute "npm link #{d}" do
        cwd ember_deploy_path + '/current'
        user new_resource.owner
        environment 'HOME' => '/home/' + new_resource.owner
      end
    end
  end
  execute "npm install && bower install && npm link && ember build -e #{new_resource.environment_name}" do
    cwd ember_deploy_path + '/current'
    user new_resource.owner
    environment 'HOME' => '/home/' + new_resource.owner
  end

  execute "npm install && bower install && npm link && ember build -e #{new_resource.environment_name}" do
    cwd ember_deploy_path + '/current'
    user new_resource.owner
    environment 'HOME' => '/home/' + new_resource.owner
  end
end

action :before_migrate do
end

action :before_symlink do
  link(new_resource.release_path + '/' + new_resource.distribution_link) do
    to(new_resource.ember_release_path + '/dist')
  end
  if new_resource.index_page_link
    index_source, index_destination = new_resource.index_page_link.first
    link(new_resource.release_path + '/' + index_destination) do
      to(new_resource.ember_release_path + '/' + index_source)
    end
  end
end

action :before_restart do
end

action :after_restart do
end

def ember_deploy_path
  if new_resource.subfolder
    new_resource.path + '/' + new_resource.subfolder
  else
    new_resource.path + '/ember'
  end
end

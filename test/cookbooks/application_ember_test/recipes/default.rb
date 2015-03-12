#
# Cookbook Name:: application_test
# Recipe:: basic_app
#
# Copyright 2012, ZephirWorks
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
#
user_account node['application_test']['owner']
include_recipe "nodejs"
nodejs_npm 'ember-cli'
nodejs_npm 'bower'
include_recipe "application_ember_test::setup"

# Create a local NPM directory to prevent sudo/global path access and permissions requirements
directory "/home/#{node['application_test']['owner']}/npm" do
  owner node['application_test']['owner']
  group node['application_test']['group']
  mode '0755'
  recursive true
end

# Create a .npmrc to specify our npm directory
template "/home/#{node['application_test']['owner']}/.npmrc" do
  source 'npmrc.erb'
  owner node['application_test']['owner']
  group node['application_test']['group']
  variables(npm_dir: "/home/#{node['application_test']['owner']}/npm")
end


app_name = "basic_app"
app_dir = "#{node['application_test']['root_dir']}/#{app_name}"

remove_app(app_name)

application app_name do
  repository  "https://github.com/h5bp/html5-boilerplate.git"
  revision    "0b60046431d14b6615d53ae6d8bd0ac62ae3eb6f"  # v4.0.0 tag
  path        app_dir
  owner       node['application_test']['owner']
  group       node['application_test']['group']
  ember do
    repository "https://github.com/InboxHealth/empty_ember_cli_app.git"
    revision "2dc812a2799906c70188195f8c9e10a2094023cc"
    distribution_link "ember_app_http_directory"
    index_page_link "dist/index.html" => "ember_app.html"
    environment_name "production"
    subfolder 'myemberapp'
  end
end
